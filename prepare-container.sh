#!/bin/bash

# move stderr to stdout
exec 2>&1

# Stop at any error
set -euo pipefail

id

if [ "${RUNNER_TOOL_CACHE:-}" != "" ]; then
	CPYTHON_DIR="${RUNNER_TOOL_CACHE}/Python"
	if [ -d "${CPYTHON_DIR}" ]; then
		echo "::group::Removing existing CPython tool cache"
		set -x
		rm -rf "${CPYTHON_DIR}"
		set +x
		echo "::endgroup::"
	fi
	for SOURCE_DIR in /opt/_internal/cpython-*; do
		echo "::group::Adding '${SOURCE_DIR}' to the tool cache"
		set -x
		VERSION_MANYLINUX=${SOURCE_DIR:23}
		case "${VERSION_MANYLINUX}" in
			*-nogil) ARCH="${RUNNER_ARCH,,}-freethreaded";;
			*) ARCH="${RUNNER_ARCH,,}";;
		esac
		VERSION=${VERSION_MANYLINUX%%-*}
		case "${VERSION}" in
			*a*) VERSION=${VERSION/a/-alpha.};;
			*b*) VERSION=${VERSION/b/-beta.};;
			*rc*) VERSION=${VERSION/rc/-rc.};;
		esac
		DEST_DIR="${CPYTHON_DIR}/${VERSION}"
		mkdir -p "${DEST_DIR}"
		ln -s ${SOURCE_DIR} "${DEST_DIR}/${ARCH}"
		touch "${DEST_DIR}/${ARCH}.complete"
		set +x
		echo "::endgroup::"
	done
fi
