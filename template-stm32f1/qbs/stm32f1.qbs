/*
 * qube - Qt Creator BareMetal QBS Templates for STM32CubeMX
 *
 * Copyright (c) 2017-2018 0xebef, all rights reserved, https://github.com/0xebef
 *
 * License: MIT
 */

import qbs
import qbs.FileInfo
import qbs.File
import "utils.js" as utils

Product {
    name: "STM32F1 Firmware"
    Depends {
        name: "cpp"
    }

    targetName: targetFile

    cpp.warningLevel: "all"
    cpp.visibility: "internal"
    cpp.cLanguageVersion: project.c_std
    cpp.cxxLanguageVersion: project.cpp_std
    cpp.positionIndependentCode: project.pic

    Properties {
        condition: qbs.buildVariant === "debug"

        cpp.defines: {
            var defines = base

            defines.push("DEBUG")
            if (project.full_assert) {
                defines.push("USE_FULL_ASSERT")
            }

            return defines
        }

        cpp.driverFlags: {
            var driverFlags = base

            driverFlags.push("-mcpu=cortex-m3")
            driverFlags.push("-mthumb")
            driverFlags.push("-mlittle-endian")
            driverFlags.push("-mfloat-abi=soft")

            if (project.lto) {
                driverFlags.push("-flto")
            }

            driverFlags.push("-fstack-usage")
            driverFlags.push("-ffunction-sections")
            driverFlags.push("-fdata-sections")
            driverFlags.push("-fno-strict-aliasing")

            if (project.libc) {
                if (project.libc_nano) {
                    driverFlags.push("--specs=nano.specs")
                }

                if (project.libc_sys === "semihosting") {
                    driverFlags.push("--specs=rdimon.specs")
                } else if (project.libc_sys === "nosys") {
                    driverFlags.push("--specs=nosys.specs")
                }

                if (project.libc_printf_float) {
                    driverFlags.push("-u_printf_float")
                }

                if (project.libc_scanf_float) {
                    driverFlags.push("-u_scanf_float")
                }
            }

            return driverFlags
        }

        cpp.commonCompilerFlags: {
            var compilerFlags = base

            compilerFlags.push("-Wformat")
            compilerFlags.push("-Wformat-security")
            compilerFlags.push("-Wno-unused-function")
            compilerFlags.push("-Wno-unused-but-set-variable")
            compilerFlags.push("-Wundef")

            return compilerFlags
        }

        cpp.linkerFlags: {
            var linkerFlags = base

            linkerFlags.push("-Map")
            linkerFlags.push(outPath + "/" + targetFile + ".map")
            linkerFlags.push("--cref")
            linkerFlags.push("--gc-sections")
            linkerFlags.push("--no-wchar-size-warning")

            return linkerFlags
        }

        cpp.debugInformation: true
        cpp.optimization: project.optimize_small ? "small" : "none"
    }

    Properties {
        condition: qbs.buildVariant === "release"

        cpp.defines: {
            var defines = base

            if (project.full_assert) {
                defines.push("USE_FULL_ASSERT")
            }

            return defines
        }

        cpp.driverFlags: {
            var driverFlags = base

            driverFlags.push("-mcpu=cortex-m3")
            driverFlags.push("-mthumb")
            driverFlags.push("-mlittle-endian")
            driverFlags.push("-mfloat-abi=soft")

            if (project.lto) {
                driverFlags.push("-flto")
            }

            driverFlags.push("-fstack-usage")
            driverFlags.push("-ffunction-sections")
            driverFlags.push("-fdata-sections")
            driverFlags.push("-fno-strict-aliasing")

            if (project.libc) {
                if (project.libc_nano) {
                    driverFlags.push("--specs=nano.specs")
                }

                if (project.libc_sys === "semihosting") {
                    driverFlags.push("--specs=rdimon.specs")
                } else if (project.libc_sys === "nosys") {
                    driverFlags.push("--specs=nosys.specs")
                }

                if (project.libc_printf_float) {
                    driverFlags.push("-u_printf_float")
                }

                if (project.libc_scanf_float) {
                    driverFlags.push("-u_scanf_float")
                }
            }

            return driverFlags
        }

        cpp.commonCompilerFlags: {
            var compilerFlags = base

            compilerFlags.push("-Wformat")
            compilerFlags.push("-Wformat-security")
            compilerFlags.push("-Wno-unused-function")
            compilerFlags.push("-Wno-unused-but-set-variable")
            compilerFlags.push("-Wundef")

            return compilerFlags
        }

        cpp.linkerFlags: {
            var linkerFlags = base

            linkerFlags.push("-Map")
            linkerFlags.push(outPath + "/" + targetFile + ".map")
            linkerFlags.push("--cref")
            linkerFlags.push("--gc-sections")
            linkerFlags.push("--no-wchar-size-warning")

            return linkerFlags
        }

        cpp.debugInformation: false
        cpp.optimization: project.optimize_small ? "small" : "fast"
    }

    Rule {
        id: elf
        inputs: ["application"]
        Artifact {
            fileTags: ["elf"]
            filePath: utils.generate_build_path(input.filePath) + "/" + FileInfo.baseName(input.filePath) + ".elf"
        }
        prepare: {
            var cmd = new JavaScriptCommand()

            cmd.sourceCode = function() {
                File.copy(input.filePath, output.filePath)
            }
            cmd.description = "copying the \"elf\" file"
            cmd.highlight = "linker"

            return cmd
        }
    }

    Rule {
        id: bin
        inputs: ["application"]
        Artifact {
            fileTags: ["bin"]
            filePath: utils.generate_build_path(input.filePath) + "/" + FileInfo.baseName(input.filePath) + ".bin"
        }
        prepare: {
            var args = ["-O", "binary", input.filePath, output.filePath]
            var cmd = new Command("arm-none-eabi-objcopy", args)

            cmd.description = "generating the \"binary\" file"
            cmd.highlight = "linker"

            return cmd
        }
    }

    Rule {
        id: hex
        inputs: ["application"]
        Artifact {
            fileTags: ["hex"]
            filePath: utils.generate_build_path(input.filePath) + "/" + FileInfo.baseName(input.filePath) + ".hex"
        }
        prepare: {
            var args = ["-O", "ihex", input.filePath, output.filePath]
            var cmd = new Command("arm-none-eabi-objcopy", args)

            cmd.description = "generating the \"hex\" file"
            cmd.highlight = "linker"

            return cmd
        }
    }

    Rule {
        id: assembly
        inputs: ["application"]
        Artifact {
            fileTags: ["assembly"]
            filePath: utils.generate_build_path(input.filePath) + "/" + FileInfo.baseName(input.filePath) + ".lst"
        }
        prepare: {
            var args = [input.filePath, "-D", "-S"]
            var cmd = new Command("arm-none-eabi-objdump", args)

            cmd.stdoutFilePath = output.filePath
            cmd.description = "generating the assembly listing"
            cmd.highlight = "codegen"

            return cmd
        }
    }

    Rule {
        id: size
        inputs: ["application"]
        Artifact {
            fileTags: ["size"]
        }
        prepare: {
            var args = [input.filePath]
            var cmd = new Command("arm-none-eabi-size", args)

            cmd.description = "generating the size statistics"
            cmd.highlight = "linker"

            return cmd
        }
    }
}
