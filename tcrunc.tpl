#!/bin/bash
# vim: ft=sh

uid="$(id -u)"
if [[ ${uid} -eq 0 ]]; then
  >&2 echo "don't use root"
  exit 1
fi

DIR="{{DIR}}"

KERNEL="$DIR/vmlinuz"
INITRD="$DIR/initrd.gz"
CMDLINE="earlyprintk=serial console=ttyS0 acpi=off quiet tce=rootfs nfsexport=$(pwd)"

setup_nfs() {
  echo "$(pwd) -network 192.168.64.0 -mask 255.255.255.0 -alldirs -mapall=${uid}:20" \
    | sudo tee -a /etc/exports >/dev/null
  sudo nfsd update
}

setup_nfs

sudo xhyve \
  -m 1G \
  -s 0:0,hostbridge \
  -s 2:0,virtio-net \
  -s 31,lpc \
  -l com1,stdio \
  -f kexec,$KERNEL,$INITRD,"$CMDLINE"

