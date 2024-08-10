# alpine-custom-setup

This is a Buildroot external tree for installing Alpine Linux on some hardware that I own. There is also some info about getting the most of Alpine by configuring it properly.

Also see: [alpine-home-assistant](https://github.com/kuba2k2/alpine-home-assistant)

## Usage

1. Clone this repository somewhere, in this example `/work/acs`.
2. Install Buildroot. Then, execute the following command in Buildroot's directory:

```bash
make BR2_EXTERNAL=/work/acs <target>
```

The `<target>` can be one of:

- [`a10-bc1077`](board/a10-bc1077/README.md) - BC1077 (MID06N/Inet1/Protab2XXL)
- [`exynos4412-i9300`](board/exynos4412-i9300/README.md) - Samsung Galaxy S3 (GT-I9300)
- [`h3-banana-pi-m2-plus`](board/h3-banana-pi-m2-plus/README.md) - Banana Pi M2+
- [`h3-fingbox-v1`](board/h3-fingbox-v1/README.md) - Fingbox v1
- [`rk2926-tac-70072`](board/rk2926-tac-70072/README.md) - Denver TAC-70072 Rockchip RK2926 Tablet

3. Run `make all` to compile all packages. Also, make sure to run `make clean` before configuring a different target.
4. Go to the chosen board's README file to follow the installation guide.

## Configure - post-install

See [`docs/alpine.md`](docs/alpine.md) for various tips for best usability.

## License

```
MIT License

Copyright (c) 2023 Kuba Szczodrzyński

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

The Linux kernel and U-Boot are licensed under the GPL.
