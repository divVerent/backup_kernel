#!/bin/sh
# The Kernel Backer-Upper
# Copyright 2025 Google LLC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

set -e

fail() {
	echo >&2 "$*"
	exit 1
}

# Detect the currently running kernel version.
r=$(uname -r)

# Parse kernel command line.
BOOT_IMAGE=/boot/vmlinuz-$r
for opt in $(cat /proc/cmdline); do
	case "$opt" in
		*=*)
			var=${opt%%=*}
			value=${opt#*=}
			case "$var" in
				*.*)
					;;
				*)
					eval "$var=\$value"
					;;
			esac
			;;
	esac
done

# Locate the file system the image is likely on.
found=false
for prefix in /boot ''; do
	for image in "$BOOT_IMAGE" "/${BOOT_IMAGE#*/}" /"${BOOT_IMAGE#*/*/}"; do
		image=$prefix$BOOT_IMAGE
		if [ -e "$image" ]; then
			$found && fail "Multiple files found for image $BOOT_IMAGE."
			found=true
			break
		fi
	done
done
$found || fail "Kernel image $image not found on file system."

# Find the associated initrd/initramfs.
imagedir=${image%/*}
imagebase=${image##*/}
case "${imagebase##*/}" in
	*-*)
		;;
	*)
		fail "Kernel image $image has no dash."
		;;
esac
found=false
for initrd in "$imagedir"/initr*-"${imagebase#*-}" "$imagedir"/initr*-"${imagebase#*-}".img; do
	if [ -e "$initrd" ]; then
		$found && fail "Multiple initramfs found for image $image."
		found=true
		break
	fi
done
$found || fail "Did not find initramfs for image $image."

# Find the associated modules directory.
modules=/lib/modules/$r
[ -d "$modules" ] || fail "Modules not found in $modules."

# Show what we got.
cat >&2 <<EOF
Detected:
  Kernel image: $image
  Init Ramdisk: $initrd
  Modules:      $modules
EOF

verbose() {
	(
		set -x
		"$@"
	)
}

# Step 1: check we're not already running a backup kernel.
check() {
	[ x"$1" != x"$2" ] || fail "$1 and $2 are the same place!"
}

# Step 2: copy the files to the backup kernel location.
save() {
	if [ -e "$1/" ]; then
		verbose rm -rf "$2"
		verbose mkdir -p "$2"
		verbose cp -Lr "$1/." "$2"
	else
		verbose cp -L "$1" "$2"
	fi
}

for step in check save; do
	$step "$image" "$imagedir/vmlinuz-backup_kernel"
	$step "$initrd" "$imagedir/initrd-backup_kernel"
	$step "$modules" "/lib/modules/backup_kernel"
done

# Step 3: reconfigure the boot loader.
if which update-grub >/dev/null 2>&1; then
	update-grub
elif [ -f /boot/grub/grub.cfg ]; then
	grub-mkconfig -o /boot/grub/grub.cfg
else
	cat >&2 <<EOF

Boot loader not detected.

Please add the backup kernel to the boot loader configuration yourself!

It is at:            $imagedir/vmlinuz-backup_kernel.
Its initramfs is at: $imagedir/initrd-backup_kernel.
EOF
fi
