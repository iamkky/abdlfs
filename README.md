# ABD Linux From Scratch (ABD-LFS)

ABD-LFS is a minimalist Linux system designed as a base for embedded environments. Built from the ground up using the **Linux From Scratch (LFS)** methodology, it operates entirely in memory using an initial ramdisk (`initrd`).

This project is tailored for complete control and optimization, focusing on flexibility and simplicity for creating deployable embedded systems.

---

## Features

- **Minimalist Design**: No package managers; built as a monolithic system.
- **Memory Operation**: System runs entirely from an initial ramdisk (`cpio`) in memory.
- **Customizable Builds**: 
  - Development (`dev`) and Production (`pro`) variants.
  - Extensions for both common and development-specific tools.
- **Script-Driven Automation**: Build process fully managed by shell scripts.
- **Output Formats**: Compressed `cpio` archives suitable for use as `initrd` during kernel compilation.

---

## System Architecture

### Build Phases
The build process is divided into the following stages:

1. **Toolchain**: (`lfs-s1.sh`)
   - Configures and builds the necessary toolchain.
2. **Basic System**: (`lfs-s2.sh`)
   - Builds the core Linux system.
3. **Common Extensions**: (`lfs-s3-ext.sh`)
   - Installs extensions used by both `dev` and `pro` versions.
4. **Development-Only Extensions**: (`lfs-s4.sh`)
   - Adds tools and libraries exclusive to the development environment.

### Output Variants
The build process generates the following `cpio` archives:

- **Development Variants**:
  - `dev-full`: Complete development environment.
  - `dev-noopt`: Development environment excluding optional tools installed in `/opt`.
- **Production Variants**:
  - `dev-prepro`: Optimized production system, stripped of documentation, localization files, and unnecessary components.
  - `dev-prepro-devmount`: A more extensible production system.

#### Naming Convention:
`abd-lfs-<version>-<date>-<time>.<arch>-<type>.cpio.gz`

- `<arch>`: Architecture (`i686` or `x86_64`).
- `<type>`: Build type (`dev-full`, `dev-noopt`, `dev-prepro`, `dev-prepro-devmount`).

---

## How to Build

### Prerequisites
Ensure all required packages are available in a cache directory. The default package lists are:

- `list-sources.txt`
- `list-dev.txt`
- `list-extensions.txt`

### Building the System
Run the main build script from the root directory:

```bash
./lfs.sh
```

For diagnostic purposes, redirect the output to a log file:

```bash
./lfs.sh &> lfs.log
```

---

## Kernel Integration

Use the `mkdevimg.sh` script to create a bootable kernel image that includes the generated `cpio`:

### Example Command

```bash
./mkdevimg.sh -abl <home>/abl \
              -c kconfig/config.kernel.x86_64.5.19.9.dev \
              -kver 5.19.9 \
              -karch x86_64 \
              -w <home>/wcache \
              abd-lfs-2.1.0-20250127-114448.x86_64-dev-full.cpio.gz
```

#### Parameters:
- `-abl`: Path to the compiled **ABL** bootloader.
- `-c`: Kernel configuration file.
- `-kver`: Kernel version.
- `-karch`: Architecture (`i686` or `x86_64`).
- `-w`: Working directory for temporary files.

The output is a bootable `bzImage` kernel.

---

## Combining with ABL Bootloader

ABD-LFS can be seamlessly integrated with the **ABL bootloader** to produce a fully bootable kernel+initrd image. Use the `-abl` parameter to specify the location of the ABL binary during the `mkdevimg.sh` process.

---

## Contributing

We welcome contributions to improve ABD-LFS! If you have ideas, fixes, or enhancements, feel free to open a pull request or issue.

---

## License

This project is distributed under the [MIT License](LICENSE).

---

## Acknowledgments

This project is inspired by the principles of **Linux From Scratch**, providing a robust foundation for building customized and optimized embedded systems

