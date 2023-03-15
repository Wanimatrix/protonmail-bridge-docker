#!/bin/bash

set -ex

VERSION=v3

# Clone new code
git clone -b $VERSION --single-branch https://github.com/ProtonMail/proton-bridge.git
cd proton-bridge
git checkout $VERSION
sed -i 's/127.0.0.1/0.0.0.0/g' internal/constants/constants.go

ARCH=$(uname -m)
if [[ $ARCH == "armv7l" ]] ; then
	# This is expected to fail, and we use the following patch to fix
	make build-nogui || true
	# For 32bit architectures, there was a overflow error on the parser
	# This is a workaround for this problem found at:
	#   https://github.com/antlr/antlr4/issues/2433#issuecomment-774514106
	find $(go env GOPATH)/pkg/mod/github.com/\!proton\!mail/go-rfc5322*/ -type f -exec sed -i.bak 's/(1<</(int64(1)<</g' {} +
fi

# Build
make build-nogui
