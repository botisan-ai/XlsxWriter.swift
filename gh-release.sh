#!/bin/bash

set -ex

gh release upload $1 ./build/libxlsxwriter-rs.xcframework.zip --clobber