# Developing User Programs in xv6

This guide provides a basic overview of how to create and run simple user-level programs in the xv6 operating system.

## Introduction

User programs in xv6 are written in C and run in their own address space, separate from the kernel. They interact with the kernel through system calls, which are wrappers around functions like `printf`, `fork`, `exec`, etc.

The typical workflow for creating a new user program involves:
1. Writing the C source code for your program.
2. Adding your program to the `Makefile` so it can be compiled and linked.
3. Rebuilding xv6 to include your new program in the file system image.
4. Running your program within the xv6 environment (usually via QEMU).

User programs typically reside in the root directory of the xv6 project (e.g., alongside files like `cat.c`, `ls.c`, etc.).

## Program Structure

A basic C program in xv6 usually has the following structure:

```c
#include "types.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  // Your program logic here

  // Example: Print to console
  // printf(1, "Output message\n"); // 1 is the file descriptor for standard output

  exit(); // Terminate the program
}
```

### Key Components:

*   **Includes**:
    *   `types.h`: This header file defines various basic data types used throughout xv6, such as `uint` (unsigned integer), `ushort` (unsigned short), `uchar` (unsigned char), and `stat` (structure for file status). This header file is located in the `include/` directory. Because the xv6 `Makefile` configures the C compiler with an include path option (`-Iinclude`), you should use the direct form `#include "types.h"` in your C code.
    *   `user.h`: This is a crucial header for user programs. It declares user-level functions provided by the xv6 C library (`ulib.c`, `usys.S`). This includes functions for system calls like `fork()`, `exec()`, `pipe()`, `read()`, `write()`, `open()`, `close()`, as well as utility functions like `printf()`, `gets()`, `strlen()`, `strcpy()`, `malloc()`, `free()`, etc. This file is also located in the `include/` directory and should be included as `#include "user.h"` due to the Makefile's include path configuration.

*   **`main` function**:
    *   This is the entry point for your user program, just like in standard C programs.
    *   `argc` (argument count) and `argv` (argument vector) are provided, allowing you to pass command-line arguments to your program.

*   **`printf()`**:
    *   The `printf` function in xv6 is a user-level library function that eventually uses the `write` system call to output formatted strings to a file descriptor.
    *   The first argument to `printf` in xv6 is the file descriptor. For standard output (the console), this is `1`.

*   **`exit()`**:
    *   This function terminates the current program and releases its resources. It's important to call `exit()` at the end of your `main` function to ensure a clean shutdown. It does not take a return code argument like in standard C; it's simply `exit()`.

## "Hello, world!" Example

Here's a simple "Hello, world!" program for xv6:

```c
#include "types.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  printf(1, "Hello, xv6 world!\n");
  exit();
}
```

To compile and run this (assuming you name it `myhello.c`):
1.  Place `myhello.c` in the root of your xv6 directory.
2.  Add `_myhello\` to the `UPROGS` list in the `Makefile`.
3.  Run `make qemu` (or `make clean && make qemu`).
4.  At the xv6 shell prompt, type `myhello`. You should see "Hello, xv6 world!" printed.

This covers the basics of creating a simple user program in xv6. Remember to consult existing user programs in the xv6 source for more examples of how to use various system calls and library functions.

## Adding Your Program to the Build System

Once you have written your C source file (e.g., `myprogram.c`), you need to tell the xv6 build system about it so it can be compiled and included in the file system image. This is done by editing the `Makefile`.

1.  **Locate and Open the `Makefile`**: The `Makefile` is in the root directory of the xv6 project. Open it with a text editor.

2.  **Find the `UPROGS` List**: Search for the line that starts with `UPROGS=`. This variable lists all the user programs that will be built. It typically looks like this (order and specific programs might vary):

    ```makefile
    UPROGS=\
        _cat\
        _echo\
        _forktest\
        _grep\
        _init\
        _kill\
        _ln\
        _ls\
        _mkdir\
        _rm\
        _sh\
        _stressfs\
        _usertests\
        _wc\
        _zombie\
    ```

3.  **Add Your Program**: Add the name of your program, prefixed with an underscore, to this list. For example, if your C file is `myprogram.c`, you would add `_myprogram\`. Make sure to add a backslash (`\`) at the end of the line because all entries in the `UPROGS` list in the standard xv6 Makefile are followed by a backslash, and then typically a newline, before the next entry or the closing blank line of the variable definition.

    **Example**: Adding `_myprogram` to the list:

    *Before:*
    ```makefile
    UPROGS=\
        _cat\
        ...
        _wc\
        _zombie\
    ```

    *After (adding at the end):*
    ```makefile
    UPROGS=\
        _cat\
        ...
        _wc\
        _zombie\
        _myprogram\
    ```

4.  **Save the `Makefile`**.

**No Need for New Rules (Usually)**

For most simple user programs that consist of a single `.c` file and use standard libraries, you do **not** need to add any new compilation rules to the `Makefile`. The existing generic rules are set up to compile `yourprogram.c` into `yourprogram.o` and then link it with the user library to create an executable named `_yourprogram`. This executable is then added to the file system image.

## Building Your Program and the OS Image

After writing your program and adding it to the `Makefile`, you need to compile it and ensure it's part of the xv6 file system image (`fs.img`).

1.  **Compile Your Specific Program (Optional but Recommended for Testing)**:
    You can compile your program individually to catch errors early. If your program is `myprogram.c` and you added `_myprogram` to `UPROGS`, you can compile it by running:
    ```bash
    make _myprogram
    ```
    This will compile `myprogram.c` to `myprogram.o` and then link it to create the executable `_myprogram`. Remember the underscore prefix for the make target.

2.  **Rebuild the File System Image**:
    For your program to be available when xv6 boots, it must be included in the `fs.img` file. The `mkfs` program (also built by `make`) creates this image and includes all programs listed in `UPROGS`. To update `fs.img` with your new program (after it has been compiled or if you're doing a full build), run:
    ```bash
    make fs.img
    ```
    This command depends on all programs in `UPROGS`, so it will compile any that haven't been compiled yet, and then rebuild `fs.img`.

3.  **Build and Run xv6 in QEMU**:
    To build everything (kernel, user programs) and run xv6 in QEMU, you can use:
    ```bash
    make qemu
    ```
    This command will compile the kernel, all user programs (including yours if it's in `UPROGS`), rebuild `fs.img` if necessary, and then launch QEMU with the xv6 image.
    If you prefer to run QEMU without a graphical window (output to the terminal), use:
    ```bash
    make qemu-nox
    ```

4.  **Cleaning the Build (Optional)**:
    If you want to perform a full rebuild from scratch, you can clean all compiled files and build artifacts using:
    ```bash
    make clean
    ```
    After running `make clean`, you would typically run `make qemu` or just `make` to rebuild everything.

Once xv6 is running in QEMU, you should be able to type the name of your program (without the underscore, e.g., `myprogram`) at the xv6 shell prompt to execute it.
