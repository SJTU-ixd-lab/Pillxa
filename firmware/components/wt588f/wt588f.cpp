#include "wt588f/wt588f.hpp"

#include <utility>
#include "esp_err.h"
#include "esp_rom_sys.h"
#include "driver/gpio.h"
#include "hal/gpio_types.h"
#include "soc/gpio_num.h"
#include "freertos/FreeRTOS.h"
#include "freertos/idf_additions.h"
#include "freertos/projdefs.h"

#include "utils/critical_mutex.hpp"

using namespace wt588f;

wt588f_driver::wt588f_driver(const wt588f_config_t &config): config(config) {
    this->configure();
}

bool wt588f_driver::is_busy() const {
    if (this->config.busy_io_num != GPIO_NUM_NC) {
        return gpio_get_level(this->config.busy_io_num);
    }

    ESP_ERROR_CHECK(ESP_ERR_NOT_ALLOWED);
    std::unreachable();
}

void wt588f_driver::play(uint8_t slot) const {
    if (slot >= 0xE0) {
        ESP_ERROR_CHECK(ESP_ERR_INVALID_ARG);
    }

    this->send_data(slot);
}

void wt588f_driver::stop() const {
    this->send_data(0xFE);
}

void wt588f_driver::set_volume(uint8_t volume) const {
    if (volume > 15) {
        ESP_ERROR_CHECK(ESP_ERR_INVALID_ARG);
    }

    this->send_data(0xE0 | volume);
}

void wt588f_driver::configure() const {
    // Setup BUSY signal if valid.
    if (this->config.busy_io_num != GPIO_NUM_NC) {
        gpio_config_t busy_config = {
            .pin_bit_mask = 1ull << this->config.busy_io_num,
            .mode = GPIO_MODE_INPUT,
            .pull_up_en = GPIO_PULLUP_DISABLE,      // PC2/BUSY should not be pulled up.
            .pull_down_en = GPIO_PULLDOWN_DISABLE,
            .intr_type = GPIO_INTR_DISABLE
        };
        ESP_ERROR_CHECK(gpio_config(&busy_config));
    }

    // Configuration for 1/2-wire communication.
    if (
        this->config.data2_io_num != GPIO_NUM_NC &&
        this->config.sck2_io_num != GPIO_NUM_NC
    ) {
        this->configure_two_wire();
        this->mode = wt588f_mode::TWO_WIRE;
        return;
    }

    if (this->config.data1_io_num != GPIO_NUM_NC) {
        this->configure_one_wire();
        this->mode = wt588f_mode::ONE_WIRE;
        return;
    }

    ESP_ERROR_CHECK(ESP_ERR_INVALID_ARG);
}

void wt588f_driver::configure_one_wire() const {
    ESP_ERROR_CHECK(ESP_ERR_NOT_SUPPORTED);     // TODO
}

void wt588f_driver::configure_two_wire() const {
    // Initialize GPIO for two-wire communication.
    gpio_config_t output_config = {
        .pin_bit_mask = (1ull << this->config.data2_io_num) | (1ull << this->config.sck2_io_num),
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE
    };
    ESP_ERROR_CHECK(gpio_config(&output_config));

    gpio_set_level(this->config.data2_io_num, 1);
    gpio_set_level(this->config.sck2_io_num, 1);

    vTaskDelay(pdMS_TO_TICKS(100));             // Delay for 100ms after power-up.
}

void wt588f_driver::configure_download() const {
    ESP_ERROR_CHECK(ESP_ERR_NOT_SUPPORTED);     // TODO
}

void wt588f_driver::send_data(uint8_t data) const {
    gpio_set_level(this->config.sck2_io_num, 0);
    vTaskDelay(pdMS_TO_TICKS(10));

    utils::critical_mutex mutex;

    for (int i = 0; i < 8; ++i) {
        gpio_set_level(this->config.data2_io_num, data & 0x01);
        gpio_set_level(this->config.sck2_io_num, 0);
        esp_rom_delay_us(wt588f_driver::clk_half_us);

        gpio_set_level(this->config.sck2_io_num, 1);
        esp_rom_delay_us(wt588f_driver::clk_half_us);

        data >>= 1;
    }

    gpio_set_level(this->config.data2_io_num, 1);
    gpio_set_level(this->config.sck2_io_num, 1);
}
