#!/bin/bash
# vim: ft=sh
DIR="{{DIR}}" # templated by installer

mkdir -p "/tmp/tcrunc-exports"

SRCDIR="$(pwd)"

setup_nfs() {
  echo "${SRCDIR} -network 192.168.64.0 -mask 255.255.255.0 -alldirs -mapall=${UID}:20" \
    | sudo tee -a /etc/exports >/dev/null
  sudo nfsd update
}

teardown_nfs() {
  sudo sed -i '' "/${SRCDIR//\//\\/}/d" /etc/exports
  sudo nfsd update
  rmdir /tmp/tcrunc-exports 2>/dev/null
}

main() {
  if [[ "${UID}" -eq 0 ]]; then
    >&2 echo "don't use root"
    exit 1
  fi

  setup_nfs
  trap teardown_nfs EXIT

  local kernel="${DIR}/vmlinuz"
  local initrd="${DIR}/initrd.gz"
  local cmdline="earlyprintk=serial console=ttyS0 acpi=off quiet tce=rootfs nfsexport=${SRCDIR}"
  sudo xhyve \
    -m 1G \
    -s 0:0,hostbridge \
    -s 2:0,virtio-net \
    -s 31,lpc \
    -l com1,stdio \
    -f kexec,${kernel},${initrd},"${cmdline}"
}
main "$@"
