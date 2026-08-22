#pragma once

#include "soc/gpio_num.h"
#include <cstdint>

namespace wt588f {

/**
 * @brief WT588F configurations.
 */
struct wt588f_config_t {
    union {
        gpio_num_t pc1_io_num;     /*!< GPIO number for DATA1/CLK2 signal, or SO for downloader. */
        gpio_num_t data1_io_num;
        gpio_num_t sck2_io_num;
        gpio_num_t so_io_num;
    };

    union {
        gpio_num_t pc2_io_num;      /*!< GPIO number for BUSY signal, or CS for downloader. */
        gpio_num_t busy_io_num;
        gpio_num_t cs_io_num;
    };

    union {
        gpio_num_t pi0_io_num;     /*!< GPIO number for DATA2 signal, or SI for downloader. */
        gpio_num_t data2_io_num;
        gpio_num_t si_io_num;
    };

    union {
        gpio_num_t pi1_io_num;     /*!< GPIO number for SCK signal for downloader. */
        gpio_num_t sck_io_num;
    };
};

/**
 * @brief Type of WT588F running mode.
 */
enum class wt588f_mode {
    INVALID,
    TWO_WIRE,
    ONE_WIRE,
    DOWNLOAD
};

/**
 * @brief Type of WT588F driver.
 */
class wt588f_driver {
    wt588f_config_t config;
    mutable wt588f_mode mode = wt588f_mode::INVALID;

    static constexpr uint32_t clk_half_us = 350;

public:
    /**
     * @param[in] config WT588F driver configurations.
     *
     * @note For 2-wire communication, SCK2 and DATA2 must be configured.
     * @note 1-wire communication mode and download mode is not supported currently.
     * @note Configuration for BUSY signal is optional.
     */
    wt588f_driver(const wt588f_config_t &config);
    wt588f_driver(const wt588f_driver &other) = delete;
    wt588f_driver(wt588f_driver &&other) = delete;
    ~wt588f_driver() = default;

    /**
     * @brief Check BUSY signal.
     * @return bool The state of BUSY signal.
     *
     * @note GPIO for BUSY signal should be configured before calling this function.
     */
    bool is_busy() const;

    /**
     * @brief Play the specific voice.
     * @param[in] slot The number of voice, maximum valid slot is 0xDF.
     */
    void play(uint8_t slot) const;

    /**
     * @brief Stop current voice.
     */
    void stop() const;

    /**
     * @brief Set volume.
     * @param[in] volume Volume level between 0 and 15.
     */
    void set_volume(uint8_t volume) const;

private:
    void configure() const;
    void configure_one_wire() const;
    void configure_two_wire() const;
    void configure_download() const;

    void send_data(uint8_t data) const;
};

}
