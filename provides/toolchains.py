from pathlib import Path
import sys
from textwrap import dedent

assert sys.version_info >= (3, 9)

TOOLCHAINS_LINARO = [
    ("4.9", "4.9", "2016.02", "arm-linux-gnueabihf", "4.0"),
]

PROVIDES_PATH = Path(__file__).parent / "toolchains.in"
TOOLCHAINS_PATH = Path(__file__).parents[1] / "toolchain"
SOURCES_PATH = TOOLCHAINS_PATH / "Config.in"

PROVIDES = []
SOURCES = []


def write_linaro():
    global PROVIDES, SOURCES

    for gcc, gcc_full, version, prefix, linux in TOOLCHAINS_LINARO:
        arch = prefix.split("-")[0]
        title = f"Linaro GCC {prefix} {gcc}-{version}"
        opt = "_".join(
            [
                "TOOLCHAIN_EXTERNAL_LINARO",
                version.replace(".", "_"),
                prefix.replace("-", "_").upper(),
            ]
        )

        path = TOOLCHAINS_PATH / f"toolchain-external-linaro-{version}-{prefix}"
        path.mkdir(parents=True, exist_ok=True)

        PROVIDES += [
            f"config BR2_{opt}",
            f'\tbool "{title}"',
            f"\tdepends on BR2_{arch}",
            f'\tdepends on BR2_HOSTARCH = "x86_64" || BR2_HOSTARCH = "x86"',
            f"\tselect BR2_TOOLCHAIN_EXTERNAL_GLIBC",
            f"\tselect BR2_TOOLCHAIN_HAS_SSP",
            f"\tselect BR2_INSTALL_LIBSTDCPP",
            f"\tselect BR2_TOOLCHAIN_GCC_AT_LEAST_{version.replace('.', '_')}",
            f"\tselect BR2_TOOLCHAIN_HEADERS_AT_LEAST_{linux.replace('.', '_')}",
            "",
        ]

        SOURCES += [
            f'source "$BR2_EXTERNAL_ACS_PATH/toolchain/{path.name}/Config.in.options"',
            "",
        ]

        (path / "Config.in.options").write_text(
            dedent(
                f"""\
                if BR2_{opt}

                config BR2_TOOLCHAIN_EXTERNAL_PREFIX
                \tdefault "{prefix}"

                config BR2_PACKAGE_PROVIDES_TOOLCHAIN_EXTERNAL
                \tdefault "{path.name}"

                endif
                """
            )
        )

        (path / f"{path.name}.mk").write_text(
            dedent(
                f"""\
                {opt}_VERSION = {version}
                {opt}_SITE = https://releases.linaro.org/components/toolchain/binaries/{gcc}-{version}/{prefix}

                ifeq ($(HOSTARCH),x86)
                {opt}_SOURCE = gcc-linaro-{gcc_full}-{version}-i686_{prefix}.tar.xz
                else
                {opt}_SOURCE = gcc-linaro-{gcc_full}-{version}-x86_64_{prefix}.tar.xz
                endif

                $(eval $(toolchain-external-package))
                """
            )
        )


if __name__ == "__main__":
    write_linaro()

    PROVIDES_PATH.write_text("\n".join(PROVIDES))
    SOURCES_PATH.write_text("\n".join(SOURCES))
