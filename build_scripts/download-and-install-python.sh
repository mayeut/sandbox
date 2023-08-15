#!/bin/bash

# Stop at any error, show all commands
set -exuo pipefail

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

ABI_TAG=$1
DOWNLOAD_URL=$2
SHA256=$3

TMPDIR=/tmp/manylinux-download
PREFIX="/opt/_internal/${ABI_TAG}"

case ${DOWNLOAD_URL} in
  *.tar) COMP=;;
  *.tar.gz) COMP=z;;
  *.tar.bz2) COMP=j;;
  *.tar.xz) COMP=J;;
  *) echo "unsupported archive"; exit 1;;
esac

mkdir ${PREFIX}

mkdir -p ${TMPDIR}

echo "${SHA256} -" > ${TMPDIR}/sha256
time curl -fsSL ${DOWNLOAD_URL} | tee >(tar -C ${PREFIX} --strip-components 1 -x${COMP}f -) | sha256sum -c ${TMPDIR}/sha256

# remove debug symbols if any
time find ${PREFIX}/bin -name '*.debug' -delete

rm -rf ${TMPDIR}

time ${MY_DIR}/finalize-one.sh ${PREFIX}
