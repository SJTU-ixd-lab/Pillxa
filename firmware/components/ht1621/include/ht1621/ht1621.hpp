#pragma once

#include <cstdint>
#include "driver/dedic_gpio.h"
#include "soc/gpio_num.h"
#include "command.hpp"

namespace ht1621 {

/**
 * @brief HT1621 configurations.
 */
struct ht1621_config_t {
    gpio_num_t cs_io_num;       /*!< GPIO number for chip select signal. */
    gpio_num_t wr_io_num;       /*!< GPIO number for write clock signal. */
    gpio_num_t rd_io_num;       /*!< GPIO number for read clock signal. */
    gpio_num_t data_io_num;     /*!< GPIO number for data signal, pulled-up internally. */
    uint32_t clk_speed_hz;      /*!< Write/Read clock frequency. */
};

/**
 * @brief Type of HT1621 driver.
 */
class ht1621_driver {
    /*! True if read feature is enabled, i.e. RD signal is connected. */
    bool enable_read;

    /*! Interval for write/read signal to flip, in microseconds. */
    uint32_t clk_half_us;

    /*! Dedicated GPIO bundle handle of CS/RD/WR signal. */
    dedic_gpio_bundle_handle_t output_bundle = nullptr;

    /*! Dedicated GPIO bundle handle of data signal. */
    dedic_gpio_bundle_handle_t data_bundle = nullptr;

public:
    /**
     * @param[in] config HT1621 driver configurations.
     */
    explicit ht1621_driver(const ht1621_config_t &config);
    ht1621_driver(const ht1621_driver &other) = delete;
    ht1621_driver(ht1621_driver &&other) = delete;
    ~ht1621_driver();

    /**
     * @brief Send command to HT1621.
     * @param[in] command HT1621 command.
     */
    void send_command(ht1621_command command) const;

    /**
     * @brief Write data to given address.
     * @param[in] address A 6-bit address to write at.
     * @param[in] data A 4-bit data to write.
     */
    void write_data(uint8_t address, uint8_t data) const;

    /**
     * @brief Write data to given address and its successor‌.
     * @param[in] address The first 6-bit address to write at.
     * @param[in] data Array of 4-bit data to write.
     */
    void write_data(uint8_t address, uint8_t data[], uint32_t count) const;

    /**
     * @brief Read data from given address.
     * @param[in] address A 6-bit address to read from.
     * @param[out] data Buffer to store data.
     */
    void read_data(uint8_t address, uint8_t *data) const;

    /**
     * @brief Read data from given address and its successor.
     * @param[in] address The first 6-bit address to read from.
     * @param[out] data Buffer to store data.
     * @param[out] count Number of address to read.
     */
    void read_data(uint8_t address, uint8_t *data, uint32_t count) const;
};

}
