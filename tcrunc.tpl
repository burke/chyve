#!/bin/bash

DIR="{{DIR}}"

KERNEL="$DIR/vmlinuz"
INITRD="$DIR/initrd.gz"
CMDLINE="earlyprintk=serial console=ttyS0 acpi=off quiet tce=rootfs"

sudo xhyve \
  -m 1G \
  -s 0:0,hostbridge \
  -s 2:0,virtio-net \
  -s 31,lpc \
  -l com1,stdio \
  -f kexec,$KERNEL,$INITRD,"$CMDLINE"
