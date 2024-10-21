# RetroArch Patch Management and Build System

[![Build](https://github.com/OnionUI/RetroArch-patch/actions/workflows/build.yml/badge.svg)](https://github.com/OnionUI/RetroArch-patch/actions/workflows/build.yml)

This repository contains a [Makefile](Makefile) for managing the RetroArch submodule, applying patches, and building the project for different platforms. The project is structured to facilitate easy management of the RetroArch source code, application of custom patches, and building for specific hardware targets.

## Prerequisites

- Git
- Make
- A Unix-like environment (Linux, macOS, or Windows with WSL)

## Directory Structure

- `submodules/RetroArch`: Contains the RetroArch submodule with the main source code.
- `src`: Contains additional source files that are part of the project.
- `patches`: Contains patch files that modify the RetroArch source code.
- `scripts`: Contains utility scripts.

## Project Contents

- **Makefile**: The [Makefile](Makefile) includes various targets for copying files, applying patches, and building the project. It automates the workflow to ensure consistency and ease of use.
- **Submodule**: The `submodules/RetroArch` directory contains the RetroArch source code as a Git submodule, allowing the RetroArch source code to be kept separate from custom modifications.
- **Patches**: The `patches` directory contains patch files that apply custom modifications to the RetroArch source code.
- **Source Files**: The `src` directory contains additional source files that are part of the project. These files are copied into the build directory during the assembly process.

## Building the Project

Running the following command will perform all the necessary steps to build the project:

```sh
make build
```

This command is equivalent to running the following steps individually:

1. **Copy the submodule files to the build directory**:

    ```sh
    make copy-submodule
    ```

2. **Apply patches**:

    ```sh
    make apply-patches
    ```

3. **Assemble the source files**:

    ```sh
    make assemble
    ```

4. **Build the project**:

    ```sh
    make build
    ```

## Contributing

To contribute to this project, follow these steps:

1. **Make changes to the `build/` folder:**  
   After running `make build`, make your changes directly in the `build/` folder.

2. **Create a patch:**  
   Once you have made your changes, run the following command to create a patch file:
   ```sh
   make create-patch
   ```
   This will generate a patch file in the `patches/` directory with your changes.

3. **Submit your patch:**  
   Submit the generated patch file by creating a pull request.

**Note:** Changes to files in the `src/` directory will not create a patch. These changes should be committed directly to the repository.
