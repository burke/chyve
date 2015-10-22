#!/bin/bash

DIR="{{DIR}}"

KERNEL="$DIR/vmlinuz"
INITRD="$DIR/initrd.gz"
CMDLINE="earlyprintk=serial console=ttyS0 acpi=off quiet"

sudo xhyve \
  -m 1G \
  -s 2:0,virtio-net \
  -s 31,lpc \
  -s 0:0,hostbridge \
  -l com1,stdio \
  -f kexec,$KERNEL,$INITRD,"$CMDLINE"

# -c 2
