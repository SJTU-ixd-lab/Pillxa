#ifdef ULP_CODEBASE
#include "ulp_lp_core_gpio.h"
#else
#include "soc/gpio_num.h"
#endif


namespace periph {

#ifdef ULP_CODEBASE

#define IO_NUM(x) (LP_IO_NUM_ ## x)
using io_num_t = lp_io_num_t;

#else

#define IO_NUM(x) (GPIO_NUM_ ## x)
using io_num_t = gpio_num_t;

#endif

/* GPIO configures used by both main core and ulp core. */

//! GPIO number for LED.
constexpr io_num_t led_io_num = IO_NUM(2);

//! GPIO number for hall sensor.
constexpr io_num_t hall_io_num = IO_NUM(3);

}
