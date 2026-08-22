idf_component_register(
    SRCS
        main.cpp
    INCLUDE_DIRS
        .
    REQUIRES
        ulp
    PRIV_REQUIRES
        esp_driver_gpio
)

ulp_add_project("ulp_main" "${CMAKE_CURRENT_SOURCE_DIR}/ulp")
