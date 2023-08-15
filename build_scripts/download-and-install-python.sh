#!/bin/bash

# Stop at any error, show all commands
set -exuo pipefail

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

ABI_TAG=$1
DOWNLOAD_URL=$2
SHA256=$3

TMPDIR=/tmp/manylinux-download/
TARBALL=${TMPDIR}/archive
PREFIX="/opt/_internal/${ABI_TAG}"

mkdir -p ${TMPDIR}

curl -fsSLo ${TARBALL} ${DOWNLOAD_URL}
echo "${SHA256} ${TARBALL}" > ${TARBALL}.sha256
sha256sum -c ${TARBALL}.sha256

mkdir ${PREFIX}
tar -C ${PREFIX} --strip-components 1 -xf ${TARBALL}

# add a generic "python" symlink
if [ ! -f "${PREFIX}/bin/python" ]; then
	ln -s python3 ${PREFIX}/bin/python
fi

# remove debug symbols if any
find ${PREFIX}/bin -name '*.debug' -delete

rm -rf ${TMPDIR}

${MY_DIR}/finalize-one.sh ${PREFIX}
