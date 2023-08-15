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

mkdir ${PREFIX}

mkdir -p ${TMPDIR}

echo "${SHA256} -" > ${TMPDIR}/sha256
time curl -fsSL ${DOWNLOAD_URL} | tee >(tar -C ${PREFIX} --strip-components 1 -xf -) | sha256sum -c ${TMPDIR}/sha256

# add a generic "python" symlink
if [ ! -f "${PREFIX}/bin/python" ]; then
	ln -s python3 ${PREFIX}/bin/python
fi

# remove debug symbols if any
time find ${PREFIX}/bin -name '*.debug' -delete

rm -rf ${TMPDIR}

time ${MY_DIR}/finalize-one.sh ${PREFIX}
