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

| Distribution     | Boot Loader  | Init System | Install Method       | Result                         |
|------------------|--------------|-------------|----------------------|--------------------------------|
| Alpine Linux     | GRUB         | openrc      | Service Integeration | OK                             |
| Alpine Linux     | GRUB         | openrc      | Init System Wrapper  | OK                             |
| Arch Linux       | GRUB         | systemd     | Service Integeration | OK                             |
| Arch Linux       | GRUB         | systemd     | Init System Wrapper  | OK                             |
| Debian GNU/Linux | GRUB         | systemd     | Service Integeration | OK (GRUB savedefault required) |
| Debian GNU/Linux | GRUB         | systemd     | Init System Wrapper  | OK (GRUB savedefault required) |
| Fedora Linux     | systemd-boot | systemd     | Service Integeration | OK (no boot entry)             |
| Fedora Linux     | systemd-boot | systemd     | Init System Wrapper  | OK (no boot entry)             |

When running on another distribution, please be prepared for fixing the
boot process, especially directly after the first reboot after
installation; it is possible that the service dependencies as set up in
the files do not work on your system. You can usually get to a shell in
which you can examine and fix the situation (or uninstall this software
by using `uninstall.sh`) by appending ` init=/bin/sh` to your boot
command line and running `mount / -o remount,rw` on the shell appearing
from that.

On distributions listed as "GRUB savedefault required", the boot loader
would boot the backup kernel by default, which is undesired. Thus, run:

``` sh
root# vi /etc/default/grub
```

and add/update the following lines:

``` sh
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
```

Then finally, run:

``` sh
root# update-grub
```

On distributions listed as "no boot entry", the boot loader is not able
to automatically detect the backup kernel, however it is easy to boot
the backup kernel anyway:

- systemd-boot: select the main boot entry, hit `e`, and replace both
  places that contain the kernel version by `backup_kernel`. In case the
  init system wrapper method of installation was used, also append
  ` init=/sbin/init.backup_kernel`. Then boot using `^X`.

## Installation (Service Integration)

To install the init script support for backup kernels:

``` sh
root# ./install.sh
```

## Installation (Init System Wrapper)

Instead, you can install this as an init wrapper:

``` sh
root# ./install.sh --init-wrapper
```

Also, configure your boot loader:

``` sh
root# vi /etc/default/grub
```

and add/update (do not remove current value of `GRUB_CMDLINE_LINUX` but
append to it, if any):

``` sh
GRUB_CMDLINE_LINUX="init=/sbin/init.backup_kernel"
```

This should work with every init system. In case your init system isn't
installed to `/sbin/init`, you can pass its path as
`backup_kernel_init=/path/to/your/init`.

## Usage

Then, to make a backup of the current kernel:

``` sh
root# ./backup-kernel.sh
```

This will always overwrite your current kernel backup by the kernel
currently running.

On next boot, you can select the desired kernel, including the backup
kernel.

If support for multiple kernel backups is desired, please file a feature
request issue - it should not be particularly hard to add, but is
currently not a goal.

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
