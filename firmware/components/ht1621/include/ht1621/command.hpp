#pragma once

#include <cstdint>

namespace ht1621 {

/**
 * @brief Type of all valid HT1621 commands.
 */
enum class ht1621_command: uint8_t {
    SYS_DIS     = 0b0000'0000,      /*!<  (Default) Turn off both system oscillator and LCD bias generator. */
    SYS_EN      = 0b0000'0001,      /*!<  Turn on system oscillator. */
    LCD_OFF     = 0b0000'0010,      /*!<  (Default) Turn off LCD bias generator. */
    LCD_ON      = 0b0000'0011,      /*!<  Turn on LCD bias generator. */
    TIMER_DIS   = 0b0000'0100,      /*!<  Disable time base output. */
    WDT_DIS     = 0b0000'0101,      /*!<  Disable WDT time-out flag output. */
    TIMER_EN    = 0b0000'0110,      /*!<  Enable time base output. */
    WDT_EN      = 0b0000'0111,      /*!<  Enable WDT time-out flag output. */
    TONE_OFF    = 0b0000'1000,      /*!<  (Default) Turn off tone outputs. */
    TONE_ON     = 0b0000'1001,      /*!<  Turn on tone outputs. */
    CLR_TIMER   = 0b0000'1100,      /*!<  Clear the contents of time base generator. */
    CLR_WDT     = 0b0000'1110,      /*!<  Clear the contents of WDT stage. */
    XTAL_32K    = 0b0001'0111,      /*!<  System clock source, crystal oscillator. */
    RC_256K     = 0b0001'1011,      /*!<  (Default) System clock source, on-chip RC oscillator. */
    EXT_256K    = 0b0001'1111,      /*!<  System clock source, external clock source. */
    BIAS2_COM2  = 0b0010'0010,      /*!<  LCD 1/2 bias, 2 COMs. */
    BIAS2_COM3  = 0b0010'0110,      /*!<  LCD 1/2 bias, 3 COMs. */
    BIAS2_COM4  = 0b0010'1010,      /*!<  LCD 1/2 bias, 4 COMs. */
    BIAS3_COM2  = 0b0010'0011,      /*!<  LCD 1/3 bias, 2 COMs. */
    BIAS3_COM3  = 0b0010'0111,      /*!<  LCD 1/3 bias, 3 COMs. */
    BIAS3_COM4  = 0b0010'1011,      /*!<  LCD 1/3 bias, 4 COMs. */
    TONE_4K     = 0b0101'1111,      /*!<  Tone frequency, 4kHz. */
    TONE_2K     = 0b0111'1111,      /*!<  Tone frequency, 2kHz */
    IRQ_DIS     = 0b1001'0111,      /*!<  (Default) Disable IRQ output. */
    IRQ_EN      = 0b1001'1111,      /*!<  Enable IRQ output. */
    F1          = 0b1011'1000,      /*!<  1Hz clock, WDT time-out after 4s. */
    F2          = 0b1011'1001,      /*!<  2Hz clock, WDT time-out after 2s. */
    F4          = 0b1011'1010,      /*!<  4Hz clock, WDT time-out after 1s. */
    F8          = 0b1011'1011,      /*!<  8Hz clock, WDT time-out after 1/2s. */
    F16         = 0b1011'1100,      /*!<  16Hz clock, WDT time-out after 1/4s. */
    F32         = 0b1011'1101,      /*!<  32Hz clock, WDT time-out after 1/8s. */
    F64         = 0b1011'1110,      /*!<  64Hz clock, WDT time-out after 1/16s. */
    F128        = 0b1011'1111,      /*!<  (Default) 128Hz clock, WDT time-out after 1/32s. */
    TEST        = 0b1110'0000,      /*!<  Test mode, user don′t use. */
    NORMAL      = 0b1110'0011       /*!<  (Default) Normal mode. */
};

}
