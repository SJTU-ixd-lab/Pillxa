#include "ht1621/ht1621.hpp"

#include <utility>
#include <sys/cdefs.h>
#include "esp_rom_sys.h"
#include "driver/gpio.h"
#include "driver/dedic_gpio.h"

#include "utils/critical_mutex.hpp"

using namespace ht1621;

#define WRITE_BIT(bit)  (write_bit((bit), this->output_bundle, this->data_bundle, this->clk_half_us))
#define READ_BIT()      (read_bit(this->output_bundle, this->data_bundle, this->clk_half_us))
#define RELEASE_DATA()  (dedic_gpio_bundle_write(this->data_bundle, 0x01, 0x01))
#define SELECT_CS()     do { \
    dedic_gpio_bundle_write(this->output_bundle, 0x01, 0x01); \
    esp_rom_delay_us(this->clk_half_us << 1); \
    dedic_gpio_bundle_write(this->output_bundle, 0x01, 0x00); \
} while (false)
#define RELEASE_CS()    (dedic_gpio_bundle_write(this->output_bundle, 0x01, 0x01))

/**
 * @brief Utility function to write a bit to HT1621 data signal.
 */
static __always_inline void write_bit(
    uint32_t bit,
    dedic_gpio_bundle_handle_t output_bundle,
    dedic_gpio_bundle_handle_t data_bundle,
    uint32_t clk_half_us
) {
    dedic_gpio_bundle_write(output_bundle, 0x02, 0x00);
    dedic_gpio_bundle_write(data_bundle, 0x01, bit);
    esp_rom_delay_us(clk_half_us);

    dedic_gpio_bundle_write(output_bundle, 0x02, 0x02);
    esp_rom_delay_us(clk_half_us);
}

/**
 * @brief Utility function to read a bit from HT1621 data signal.
 */
static __always_inline uint32_t read_bit(
    dedic_gpio_bundle_handle_t output_bundle,
    dedic_gpio_bundle_handle_t data_bundle,
    uint32_t clk_half_us
) {
    dedic_gpio_bundle_write(output_bundle, 0x04, 0x00);
    esp_rom_delay_us(clk_half_us);

    dedic_gpio_bundle_write(output_bundle, 0x04, 0x04);
    uint32_t value = dedic_gpio_bundle_read_in(data_bundle);
    esp_rom_delay_us(clk_half_us);

    return value & 0x01;
}

ht1621_driver::ht1621_driver(const ht1621_config_t &config):
    enable_read(config.rd_io_num != GPIO_NUM_NC),
    clk_half_us(1'000'000 / config.clk_speed_hz / 2)
{
    // Initialize GPIO.
    gpio_config_t output_config = {
        .pin_bit_mask = (1ull << config.cs_io_num) | (1ull << config.wr_io_num),
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE
    };

    if (this->enable_read) {
        output_config.pin_bit_mask |= (1ull << config.rd_io_num);

        gpio_config_t data_config = {
            .pin_bit_mask = 1ull << config.data_io_num,
            .mode = GPIO_MODE_INPUT_OUTPUT_OD,
            .pull_up_en = GPIO_PULLUP_ENABLE,
            .pull_down_en = GPIO_PULLDOWN_DISABLE,
            .intr_type = GPIO_INTR_DISABLE
        };

        ESP_ERROR_CHECK(gpio_config(&data_config));
        gpio_set_level(config.rd_io_num, 1);
    } else {
        output_config.pin_bit_mask |= (1ull << config.data_io_num);
    }

    ESP_ERROR_CHECK(gpio_config(&output_config));

    gpio_set_level(config.cs_io_num, 1);
    gpio_set_level(config.wr_io_num, 1);
    gpio_set_level(config.data_io_num, 1);

    // Initialize dedicated GPIO.
    int gpio_array[] = {
        // GPIO(s) for output bundle.
        config.cs_io_num,
        config.wr_io_num,
        config.rd_io_num, // Only valid when it is not GPIO_NUM_NC

        // GPIO for data bundle
        config.data_io_num
    };

    dedic_gpio_bundle_config_t output_bundle_config = {
        .gpio_array = gpio_array,
        .array_size = enable_read ? 3uz : 2uz,
        .flags = {
            .in_en = false,
            .in_invert = false,
            .out_en = true,
            .out_invert = false
        }
    };
    ESP_ERROR_CHECK(dedic_gpio_new_bundle(&output_bundle_config, &this->output_bundle));

    dedic_gpio_bundle_config_t data_bundle_config = {
        .gpio_array = gpio_array + 3,
        .array_size = 1,
        .flags = {
            .in_en = enable_read,
            .in_invert = false,
            .out_en = true,
            .out_invert = false
        }
    };
    ESP_ERROR_CHECK(dedic_gpio_new_bundle(&data_bundle_config, &this->data_bundle));
}

ht1621_driver::~ht1621_driver() {
    if (this->data_bundle) {
        dedic_gpio_del_bundle(this->data_bundle);
    }

    if (this->output_bundle) {
        dedic_gpio_del_bundle(this->output_bundle);
    }
}

void ht1621_driver::send_command(ht1621_command command) const {
    utils::critical_mutex mutex;

    SELECT_CS();

    WRITE_BIT(1);
    WRITE_BIT(0);
    WRITE_BIT(0);

    uint32_t data = std::to_underlying(command);
    for (int i = 0; i < 8; ++i) {
        WRITE_BIT((data & 0x80) >> 7);
        data <<= 1;
    }
    WRITE_BIT(1);

    RELEASE_CS();
}

void ht1621_driver::write_data(uint8_t address, uint8_t data) const {
    this->write_data(address, &data, 1);
}

void ht1621_driver::write_data(uint8_t address, uint8_t data[], uint32_t count) const {
    utils::critical_mutex mutex;

    SELECT_CS();

    WRITE_BIT(1);
    WRITE_BIT(0);
    WRITE_BIT(1);

    for (int i = 0; i < 6; ++i) {
        WRITE_BIT((address & 0x20) >> 5);
        address <<= 1;
    }


    while (count--) {
        for (int i = 0; i < 4; ++i) {
            WRITE_BIT((*data & 0x08) >> 3);
            *data <<= 1;
        }
        ++data;
    }

    RELEASE_CS();
}

void ht1621_driver::read_data(uint8_t address, uint8_t *data) const {
    this->read_data(address, data, 1);
}

void ht1621_driver::read_data(uint8_t address, uint8_t *data, uint32_t count) const {
    utils::critical_mutex mutex;

    SELECT_CS();

    WRITE_BIT(1);
    WRITE_BIT(1);
    WRITE_BIT(0);

    for (int i = 0; i < 6; ++i) {
        WRITE_BIT((address & 0x20) >> 5);
        address <<= 1;
    }


    while (count--) {
        *data = 0x00;
        for (int i = 0; i < 4; ++i) {
            *data <<= 1;
            *data |= READ_BIT();
        }
        ++data;
    }

    RELEASE_CS();
}
