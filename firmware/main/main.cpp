#include <cstdint>
#include <cstdio>

#include "esp_err.h"
#include "esp_log.h"
#include "esp_sleep.h"
#include "ulp_lp_core.h"
#include "driver/rtc_io.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "peripherals.hpp"

constexpr const char *TAG = "core";

extern "C" void app_main() {
    // Check wakeup cause and initialize ulp core program if necessary.
    auto cause = esp_sleep_get_wakeup_cause();
    if (cause != ESP_SLEEP_WAKEUP_ULP) {
        extern const uint8_t ulp_main_bin_start[] asm("_binary_ulp_main_bin_start");
        extern const uint8_t ulp_main_bin_end[] asm("_binary_ulp_main_bin_end");
        ESP_ERROR_CHECK(ulp_lp_core_load_binary(ulp_main_bin_start, ulp_main_bin_end - ulp_main_bin_start));

        ulp_lp_core_cfg_t ulp_config = {
            .wakeup_source = ULP_LP_CORE_WAKEUP_SOURCE_LP_TIMER,
            .lp_timer_sleep_duration_us = 10'000
        };
        ESP_ERROR_CHECK(ulp_lp_core_run(&ulp_config));
    } else {
        // Main cpu is woken up by ULP.
        ESP_LOGI(TAG, "Main CPU is woken up by ULP.");
    }

    // Initialize hall sensor as RTC IO.
    ESP_ERROR_CHECK(rtc_gpio_init(periph::hall_io_num));
    ESP_ERROR_CHECK(rtc_gpio_set_direction(periph::hall_io_num, RTC_GPIO_MODE_INPUT_ONLY));
    ESP_ERROR_CHECK(rtc_gpio_pulldown_dis(periph::hall_io_num));
    ESP_ERROR_CHECK(rtc_gpio_pulldown_dis(periph::hall_io_num));

    // Enter deep-sleep mode after 2s, for test only.
    vTaskDelay(pdMS_TO_TICKS(2000));
    ESP_ERROR_CHECK(esp_sleep_enable_ulp_wakeup());
    esp_deep_sleep_start();
}
