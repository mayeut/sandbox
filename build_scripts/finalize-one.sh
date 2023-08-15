#!/bin/bash

# Stop at any error, show all commands
set -exuo pipefail

PREFIX=$1

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

# Some python's install as bin/python3. Make them available as
# bin/python.
if [ -e ${PREFIX}/bin/python3 ] && [ ! -e ${PREFIX}/bin/python ]; then
	ln -s python3 ${PREFIX}/bin/python
fi
PY_VER=$(${PREFIX}/bin/python -c "import sys; print('.'.join(str(v) for v in sys.version_info[:2]))")
PY_IMPL=$(${PREFIX}/bin/python -c "import sys; print(sys.implementation.name)")

#time ${PREFIX}/bin/python /tmp/get-pip.py --no-setuptools --no-wheel

# Since we fall back on a canned copy of pip, we might not have
# the latest pip and friends. Upgrade them to make sure.
time /usr/local/bin/python${PY_VER} -m pip -V
time /usr/local/bin/python${PY_VER} -m pip --python ${PREFIX}/bin/python install -U --require-hashes -r ${MY_DIR}/requirements${PY_VER}.txt
if [ -e ${PREFIX}/bin/pip3 ] && [ ! -e ${PREFIX}/bin/pip ]; then
	ln -s pip3 ${PREFIX}/bin/pip
fi
# Create a symlink to PREFIX using the ABI_TAG in /opt/python/
ABI_TAG=$(${PREFIX}/bin/python ${MY_DIR}/python-tag-abi-tag.py)
ln -s ${PREFIX} /opt/python/${ABI_TAG}
# Make versioned python commands available directly in environment.
if [[ "${PY_IMPL}" == "cpython" ]]; then
	ln -s ${PREFIX}/bin/python /usr/local/bin/python${PY_VER}
fi
ln -s ${PREFIX}/bin/python /usr/local/bin/${PY_IMPL}${PY_VER}
