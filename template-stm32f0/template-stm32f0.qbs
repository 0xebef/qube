/*
 * qube - Qt Creator BareMetal QBS Templates for STM32CubeMX
 *
 * Copyright (c) 2017-2018 0xebef, all rights reserved, https://github.com/0xebef
 *
 * License: MIT
 */

import qbs
import "qbs/stm32f0.qbs" as stm32f0

Project {
    minimumQbsVersion: "1.6"

    /*
     * microcontroller series
     *
     * supported definitions are:
     * - STM32F030x6
     * - STM32F030x8
     * - STM32F031x6
     * - STM32F038xx
     * - STM32F042x6
     * - STM32F048xx
     * - STM32F051x8
     * - STM32F058xx
     * - STM32F070x6
     * - STM32F070xB
     * - STM32F071xB
     * - STM32F072xB
     * - STM32F078xx
     * - STM32F091xC
     * - STM32F098xx
     * - STM32F030xC
     */
    readonly property string microcontroller_series: "STM32F030x6"

    /*
     * common properties for all build types
     */
    readonly property string c_std      : "gnu11"
    readonly property string cpp_std    : "gnu++14"
    readonly property bool   libc       : true  // use the Newlib C Standard library
    readonly property bool   libc_nano  : true  // use the Newlib Nano specs
    readonly property bool   libc_math  : false // use the Standard Math library
    readonly property bool   cmsis      : true  // use the CMSIS library
    readonly property bool   cmsis_math : false // use the CMSIS Math library (DSP)
    readonly property bool   hal        : true  // use ST's HAL library
    readonly property bool   ll         : true  // use ST's LL library
    readonly property bool   audio      : false // use ST's Audio library
    readonly property bool   usb_device : false // use ST's USB Device library
    readonly property bool   usb_host   : false // use ST's USB Host library
    readonly property bool   stm_touch  : false // use ST's STMTouch library
    readonly property bool   stemwin    : false // use ST's STemWin library
    readonly property string stemwin_v  : "532" // ST's STemWin library version
    readonly property bool   freertos   : false // use the FreeRTOS real-time operating system
    readonly property bool   fatfs      : false // use ChaN's FatFs library
    readonly property bool   libjpeg    : false // use the LibJPEG library
    readonly property bool   lwip       : false // use the LwIP library
    readonly property bool   mbedtls    : false // use the mbedTLS library
    readonly property bool   libs       : false // use own libraries in /Lib

    /*
     * properties for the debug build
     */
    Properties {
        condition: qbs.buildVariant === "debug"

        // set the libc system interface: "nosys", "semihosting" or "custom"
        readonly property string libc_sys          : "nosys"
        readonly property bool   libc_printf_float : false // enable float support for printed formatted strings
        readonly property bool   libc_scanf_float  : false // enable float support for scanned formatted strings

        readonly property bool   optimize_small    : false // use the compiler's "small" code optimizations, otherwise "none" will be used
        readonly property bool   lto               : false // use link time optimizations
        readonly property bool   pic               : false // position independent code
        readonly property bool   full_assert       : true  // enable full assert mode
    }

    /*
     * properties for the release build
     */
    Properties {
        condition: qbs.buildVariant === "release"

        // set the libc system interface: "nosys", "semihosting" or "custom"
        readonly property string libc_sys          : "nosys"
        readonly property bool   libc_printf_float : false // enable float support for printed formatted strings
        readonly property bool   libc_scanf_float  : false // enable float support for scanned formatted strings

        readonly property bool   optimize_small    : true  // use the compiler's "small" code optimizations, otherwise "fast" will be used
        readonly property bool   lto               : false // use link time optimizations
        readonly property bool   pic               : false // position independent code
        readonly property bool   full_assert       : false // enable full assert mode
    }

    stm32f0 {
        property string basePath      : project.sourceDirectory
        property string appPath       : basePath
        property string startupPath   : basePath
        property string cmsisPath     : basePath + "/Drivers/CMSIS"
        property string halPath       : basePath + "/Drivers/STM32F0xx_HAL_Driver"
        property string utilitiesPath : basePath + "/Utilities"
        property string audioPath     : basePath + "/Middlewares/ST/STM32_Audio"
        property string usbDevicePath : basePath + "/Middlewares/ST/STM32_USB_Device_Library"
        property string usbHostPath   : basePath + "/Middlewares/ST/STM32_USB_Host_Library"
        property string stmTouchPath  : basePath + "/Middlewares/ST/STM32_TouchSensing_Library"
        property string stemwinPath   : basePath + "/Middlewares/ST/STemWin"
        property string freertosPath  : basePath + "/Middlewares/Third_Party/FreeRTOS"
        property string fatfsPath     : basePath + "/Middlewares/Third_Party/FatFs"
        property string libjpegPath   : basePath + "/Middlewares/Third_Party/LibJPEG"
        property string lwipPath      : basePath + "/Middlewares/Third_Party/LwIP"
        property string mbedtlsPath   : basePath + "/Middlewares/Third_Party/mbedTLS"
        property string libPath       : basePath + "/Lib"
        property string linkerPath    : basePath
        property string openocdPath   : basePath + "/openocd"
        property string outPath       : basePath + "/bin/" + qbs.buildVariant
        property string targetFile    : "firmware.elf"

        type: ["application", "elf", "bin", "hex", "assembly", "size"]
        name: "firmware"
        consoleApplication: true

        cpp.defines: {
            var defines = base

            defines.push("STM32")
            defines.push("STM32F0")
            defines.push(project.microcontroller_series)

            if (project.hal) {
                defines.push("USE_HAL_DRIVER")
            }

            if (project.ll) {
                defines.push("USE_FULL_LL_DRIVER")
            }

            if (project.libc_sys === "semihosting") {
                defines.push("USING_SEMIHOSTING")
            }

            return defines
        }

        cpp.includePaths: {
            var includePaths = base

            includePaths.push(appPath   + "/Inc")

            if (project.cmsis) {
                includePaths.push(cmsisPath + "/Include")
                includePaths.push(cmsisPath + "/Device/ST/STM32F0xx/Include")
            }

            if (project.hal || project.ll) {
                includePaths.push(halPath + "/Inc")
                includePaths.push(halPath + "/Inc/Legacy")
                includePaths.push(halPath + "/Utilities/CPU")
                includePaths.push(halPath + "/Utilities/Fonts")
                includePaths.push(halPath + "/Utilities/JPEG")
                includePaths.push(halPath + "/Utilities/Log")
            }

            if (project.audio) {
                includePaths.push(audioPath + "/Addons/PDM")
            }

            if (project.usb_device) {
                includePaths.push(usbDevicePath + "/Core/Inc")
                includePaths.push(usbDevicePath + "/Class/AUDIO/Inc")
                includePaths.push(usbDevicePath + "/Class/CDC/Inc")
                includePaths.push(usbDevicePath + "/Class/CustomHID/Inc")
                includePaths.push(usbDevicePath + "/Class/DFU/Inc")
                includePaths.push(usbDevicePath + "/Class/HID/Inc")
                includePaths.push(usbDevicePath + "/Class/MSC/Inc")
            }

            if (project.usb_host) {
                includePaths.push(usbHostPath + "/Core/Inc")
                includePaths.push(usbHostPath + "/Class/AUDIO/Inc")
                includePaths.push(usbHostPath + "/Class/CDC/Inc")
                includePaths.push(usbHostPath + "/Class/HID/Inc")
                includePaths.push(usbHostPath + "/Class/MSC/Inc")
                includePaths.push(usbHostPath + "/Class/MTP/Inc")
            }

            if (project.stm_touch) {
                includePaths.push(stmTouchPath + "/inc")
            }

            if (project.stemwin) {
                includePaths.push(stemwinPath + "/Config")
                includePaths.push(stemwinPath + "/inc")
            }

            if (project.freertos) {
                includePaths.push(freertosPath + "/Source/CMSIS_RTOS")
                includePaths.push(freertosPath + "/Source/include")
                includePaths.push(freertosPath + "/Source/portable/GCC/ARM_CM0")
            }

            if (project.fatfs) {
                includePaths.push(fatfsPath + "/src")
                includePaths.push(fatfsPath + "/src/drivers")
            }

            if (project.libjpeg) {
                includePaths.push(libjpegPath + "/include")
            }

            if (project.lwip) {
                includePaths.push(lwipPath + "/src/include")
                includePaths.push(lwipPath + "/system")
            }

            if (project.mbedtls) {
                includePaths.push(mbedtlsPath + "/configs")
                includePaths.push(mbedtlsPath + "/include")
            }

            if (project.libs) {
                includePaths.push(libPath)
            }

            return includePaths
        }

        cpp.libraryPaths: {
            var libraryPaths = base

            if (project.cmsis_math) {
                libraryPaths.push(cmsisPath + "/Lib/GCC")
            }

            if (project.audio) {
                libraryPaths.push(audioPath + "/Addons/PDM")
            }

            if (project.stemwin) {
                libraryPaths.push(stemwinPath + "/Lib")
            }

            return libraryPaths
        }

        cpp.staticLibraries: {
            var staticLibraries = base

            if (project.libc_sys === "semihosting") {
                staticLibraries.push("rdimon")
            } else if (project.libc_sys === "nosys") {
                staticLibraries.push("nosys")
            }

            if (project.cmsis_math) {
                staticLibraries.push("arm_cortexM0l_math")
            }

            if (project.audio) {
                staticLibraries.push("PDMFilter_CM0_GCC")
            }

            if (project.stemwin) {
                if (project.freertos) {
                    staticLibraries.push("STemWin" + project.stemwin_v + "_CM0_OS_GCC")
                } else {
                    staticLibraries.push("STemWin" + project.stemwin_v + "_CM0_GCC")
                }
            }

            staticLibraries.push("gcc")
            staticLibraries.push("c")

            if (project.libc_math) {
                staticLibraries.push("m")
            }

            return staticLibraries
        }

        Group {
            name: "Startup"
            prefix: startupPath
            fileTags: ["asm"]
            files: [
                "/*.s",
                "/*.S"
            ]
        }

        Group {
            name: "App"
            prefix: appPath
            files: [
                "/Src/**/*.c",
                "/Src/**/*.cpp",
                "/Inc/**/*.h"
            ]
        }

        Group {
            name: "Drivers/CMSIS"
            prefix: cmsisPath
            files: [
                "/**/*.h"
            ]
            excludeFiles: [
                "*template*",
                "*Template*"
            ]
        }

        Group {
            condition: project.hal === true || project.ll === true

            name: "Drivers/HAL"
            prefix: halPath
            files: [
                "/**/*.c",
                "/**/*.h"
            ]
            excludeFiles: [
                "*template*",
                "*Template*"
            ]
        }

        Group {
            condition: project.hal === true || project.ll === true

            name: "Utilities"
            prefix: utilitiesPath
            files: [
                "/**/*.c",
                "/**/*.c",
                "/**/*.h"
            ]
            excludeFiles: [
                "*template*",
                "*Template*"
            ]
        }

        Group {
            condition: project.audio === true

            name: "Middleware/Audio"
            prefix: audioPath
            files: [
                "/**/*.c",
                "/**/*.h"
            ]
            excludeFiles: [
                "*template*",
                "*Template*"
            ]
        }

        Group {
            condition: project.usb_device === true

            name: "Middleware/USBDevice"
            prefix: usbDevicePath
            files: [
                "/**/*.c",
                "/**/*.h"
            ]
            excludeFiles: [
                "*template*",
                "*Template*"
            ]
        }

        Group {
            condition: project.usb_host === true

            name: "Middleware/USBHost"
            prefix: usbHostPath
            files: [
                "/**/*.c",
                "/**/*.h"
            ]
            excludeFiles: [
                "*template*",
                "*Template*"
            ]
        }

        Group {
            condition: project.stm_touch === true

            name: "Middleware/STMTouch"
            prefix: usbDevicePath
            files: [
                "/src/*.c",
                "/inc/*.h"
            ]
            excludeFiles: [
                "*template*",
                "*Template*"
            ]
        }

        Group {
            condition: project.stemwin === true

            name: "Middleware/STemWin"
            prefix: stemwinPath
            files: [
                "/Config/**/*.c",
                "/Config/**/*.h",
                "/OS/**/*.c",
                "/OS/**/*.h",
                "/inc/**/*.h"
            ]
            excludeFiles: [
                "*template*",
                "*Template*"
            ]
        }

        Group {
            condition: project.freertos === true

            name: "Middleware/FreeRTOS"
            prefix: freertosPath
            files: [
                "/Source/**/*.c",
                "/Source/**/*.h"
            ]
            excludeFiles: [
                "*template*",
                "*Template*"
            ]
        }

        Group {
            condition: project.fatfs === true

            name: "Middleware/FatFs"
            prefix: fatfsPath
            files: [
                "/src/**/*.c",
                "/src/**/*.h"
            ]
            excludeFiles: [
                "*template*",
                "*Template*"
            ]
        }

        Group {
            condition: project.libjpeg === true

            name: "Middleware/LibJPEG"
            prefix: libjpegPath
            files: [
                "/include/**/*.h",
                "/source/**/*.c"
            ]
            excludeFiles: [
                "*template*",
                "*Template*"
            ]
        }

        Group {
            condition: project.lwip === true

            name: "Middleware/LwIP"
            prefix: lwipPath
            files: [
                "/src/**/*.c",
                "/src/**/*.h",
                "/system/**/*.c",
                "/system/**/*.h"
            ]
            excludeFiles: [
                "*template*",
                "*Template*"
            ]
        }

        Group {
            condition: project.mbedtls === true

            name: "Middleware/mbedTLS"
            prefix: lwipPath
            files: [
                "/configs/*.h",
                "/include/**/*.h",
                "/library/**/*.c"
            ]
            excludeFiles: [
                "*template*",
                "*Template*"
            ]
        }

        Group {
            condition: project.libs === true

            name: "Lib"
            prefix: libPath
            files: [
                "/**/*.c",
                "/**/*.cpp",
                "/**/*.h"
            ]
            excludeFiles: [
                "*template*",
                "*Template*"
            ]
        }

        Group {
            name: "Linker"
            prefix: linkerPath
            fileTags: ["linkerscript"]
            files: [
                "/*.ld"
            ]
        }

        Group {
            name: "OpenOCD"
            prefix: openocdPath
            files: [
                "/*.cfg"
            ]
        }
    }
}
