#include "ulp_lp_core.h"
#include "ulp_lp_core_utils.h"
#include "ulp_lp_core_gpio.h"

#include "../peripherals.hpp"

static int debounce_count = 0;
bool gpio_level_previous = false;

int main() {
    bool gpio_level = ulp_lp_core_gpio_get_level(periph::hall_io_num);

    if (gpio_level != gpio_level_previous) {
        ++debounce_count;
    } else {
        debounce_count = 0;
    }

    if (debounce_count >= 5) {
        gpio_level_previous = gpio_level;
        ulp_lp_core_wakeup_main_processor();
    }

    return 0;
}
