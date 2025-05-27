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

set -ex

if [ x"$1" = x'--init-wrapper' ]; then
	echo >&2 'Please remove init=/sbin/init.backup_kernel from your kernel parameters.'
	rm -f /sbin/init.backup_kernel
elif [ -e /run/systemd/notify ]; then
	systemctl disable backup_kernel.service
	rm -f /etc/systemd/system/backup_kernel.service
	systemctl daemon-reload
elif [ -e /run/openrc/softlevel ]; then
	rc-update del backup_kernel sysinit
	rm -f /etc/init.d/backup_kernel
else
	echo >&2 'Init system not detected. Please add uninstallation here.'
	exit 1
fi
