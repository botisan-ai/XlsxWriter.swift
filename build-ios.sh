#!/bin/bash

set -ex

rm -rf ./build
rm -rf ./out

cargo build
cargo run --bin uniffi-bindgen generate --library ./target/debug/libxlsxwriter.dylib --language swift --out-dir ./out

mv ./out/xlsxwriterFFI.modulemap ./out/module.modulemap

cargo build --release --target aarch64-apple-ios
cargo build --release --target aarch64-apple-ios-sim
cargo build --release --target aarch64-apple-darwin

rm -rf ./build
mkdir -p ./build/Headers/xlsxwriterFFI
cp ./out/xlsxwriterFFI.h ./build/Headers/xlsxwriterFFI/
cp ./out/module.modulemap ./build/Headers/xlsxwriterFFI/

cp ./out/xlsxwriter.swift ./Sources/XlsxWriterFFI/

xcodebuild -create-xcframework \
-library ./target/aarch64-apple-ios/release/libxlsxwriter.a -headers ./build/Headers \
-library ./target/aarch64-apple-ios-sim/release/libxlsxwriter.a -headers ./build/Headers \
-library ./target/aarch64-apple-darwin/release/libxlsxwriter.a -headers ./build/Headers \
-output ./build/libxlsxwriter-rs.xcframework

ditto -c -k --sequesterRsrc --keepParent ./build/libxlsxwriter-rs.xcframework ./build/libxlsxwriter-rs.xcframework.zip
checksum=$(swift package compute-checksum ./build/libxlsxwriter-rs.xcframework.zip)
version=$(cargo metadata --format-version 1 | jq -r --arg pkg_name "xlsxwriter-swift" '.packages[] | select(.name==$pkg_name) .version')
sed -i "" -E "s/(let releaseTag = \")[^\"]*(\")/\1$version\2/g" ./Package.swift
sed -i "" -E "s/(let releaseChecksum = \")[^\"]*(\")/\1$checksum\2/g" ./Package.swift
