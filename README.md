# The Kernel Backer-Upper

Utility to back up the currently running Linux kernel.

## Dependencies

You need the usual shell utilities, plus a supported boot loader. The
system *should* support file system namespaces (`CONFIG_NAMESPACES`) to
allow manipulation of the system via the package manager.

The kernel currently must use an initrd or initramfs (most distros use
that).

The boot loader can currently be:

- GRUB
- or any other boot loader if you know how to add a boot entry manually

The init system can currently be:

- OpenRC
- systemd
- any other system by using the init system wrapper method

This software has been tested on the following distributions:

| Distribution     | Boot Loader | Init System | Install Method       | Result |
|------------------|-------------|-------------|----------------------|--------|
| Debian GNU/Linux | GRUB        | systemd     | Service Integeration | OK     |
| Debian GNU/Linux | GRUB        | systemd     | Init System Wrapper  | OK     |
| Alpine Linux     | GRUB        | openrc      | Service Integeration | OK     |
| Alpine Linux     | GRUB        | openrc      | Init System Wrapper  | OK     |

When running on another system, please be prepared for fixing the boot
process, especially directly after the first reboot after installation;
it is possible that the service dependencies as set up in the files do
not work on your system. You can usually get to a shell in which you can
examine and fix the situation (or uninstall this software by using
`uninstall.sh`) by appending ` init=/bin/sh` to your boot command line
and running `mount / -o remount,rw` on the shell appearing from that.

## Installation (Service Integration)

To install the init script support for backup kernels:

``` sh
root# ./install.sh
```

Then, set up your boot loader to save the last selected kernel option
(necessary as on some distributions, the backup kernel may otherwise
become the default):

``` sh
root# vi /etc/default/grub
```

and add:

``` sh
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
```

## Installation (Init System Wrapper)

Instead, you can install this as an init wrapper:

``` sh
root# ./install.sh --init-wrapper
```

And, as before, configure your boot loader:

``` sh
root# vi /etc/default/grub
```

and add/update (do not remove current value of `GRUB_CMDLINE_LINUX` but
append to it, if any):

``` sh
GRUB_CMDLINE_LINUX="init=/sbin/init.backup_kernel"
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
```

This should work with every init system. In case your init system isn't
installed to `/sbin/init`, you can pass its path as
`backup_kernel_init=/path/to/your/init`.

## Usage

Then, to make a backup of the current kernel:

``` sh
root# ./backup-kernel.sh
```

On next boot, you can select the desired kernel, including the backup
kernel.

## Updating the System

Updating the system while on the backup kernel will run into trouble if
the running kernel version matches the current distribution-installed
kernel. Thus, in case you ever need to use your package manager while
having booted the backup kernel, use the following commands:

``` sh
root# unshare -m
root-unshared# umount /lib/modules/$(uname -r)
root-unshared# # ... your package management commands ...
```

Alternatively, if `unshare` is not available, you can try:

``` sh
root# umount -l /lib/modules/$(uname -r)
root# # ... your package management commands ...
```

However, when doing this, loading further modules after the start of
this operation will no longer work.

## License

This software is licensed under the [GNU General Public License, version
2 or any later version](LICENSE).

## Disclaimer

This is not an officially supported Google product. This project is not
eligible for the [Google Open Source Software Vulnerability Rewards
Program](https://bughunters.google.com/open-source-security).

BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR
THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH
YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR OR CORRECTION.
