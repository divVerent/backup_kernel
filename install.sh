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
	install -m755 init-wrapper/init.backup_kernel /sbin/init.backup_kernel
	echo >&2 'Please add init=/sbin/init.backup_kernel to your kernel parameters.'
elif [ -e /run/systemd/notify ]; then
	install -m644 systemd/backup_kernel.service /etc/systemd/system/backup_kernel.service
	systemctl daemon-reload
	systemctl enable backup_kernel.service
elif [ -e /run/openrc/softlevel ]; then
	install -m755 openrc/backup_kernel /etc/init.d/backup_kernel
	rc-update add backup_kernel sysinit
else
	echo >&2 'Init system not detected. Please add installation here.'
	exit 1
fi
