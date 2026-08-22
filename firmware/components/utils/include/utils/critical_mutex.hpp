#pragma once

#include "portmacro.h"

namespace utils {

class critical_mutex {
    inline static portMUX_TYPE mutex = portMUX_INITIALIZER_UNLOCKED;

public:
    critical_mutex() {
        portENTER_CRITICAL(&critical_mutex::mutex);
    }

    critical_mutex(const critical_mutex &other) = delete;
    critical_mutex(critical_mutex &&other) = delete;

    ~critical_mutex() {
        portEXIT_CRITICAL(&critical_mutex::mutex);
    }
};

}
