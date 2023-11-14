[![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/nkito/i960_SBC/docker-image.yml?label=docker-image&logo=github&style=flat-square)](https://github.com/nkito/i960_SBC/actions?workflow=docker-image)
[![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/nkito/i960_SBC/build-test.yml?label=sample-binary&logo=github&style=flat-square)](https://github.com/nkito/i960_SBC/actions?workflow=build-test)

# i960 Single Board Computer

Under construction. It is a hobby project.

## Hardware

### Parts

* Processor: Intel i960 (N80960SA16 or N80960SB16)
* Peripheral: Motorola MC68901P (UART, Timer, and GPIO)
* Controller: Altera EPM7032SLC44-10 (or Atmel ATF1502AS-7JX44)

## Software

### Cross compiler

Docker container image of cross compiler is available. 

* binutils 2.21.1
* gcc 2.95.3
* newlib 1.8.2

Install from the command line
```
$ docker pull ghcr.io/nkito/i960_sbc:latest
$ docker run -it --rm -v /path_to_src_folder_in_host:/src -u (host uid):(host gid) ghcr.io/nkito/i960_sbc:latest
```
Compiler binaries are in /usr/local/cross/bin.
