#!/bin/bash

# This script takes care of building your crate and packaging it for release

set -ex

main() {
    local src=$(pwd) \
          stage=

    case $TRAVIS_OS_NAME in
        linux)
            stage=$(mktemp -d)
            ;;
        osx)
            stage=$(mktemp -d -t tmp)
            ;;
    esac

    case $TARGET in
        x86_64-pc-windows-gnu)
            BINARY_NAME=zokrates.exe
            ;;
        *)
            BINARY_NAME=zokrates
            ;;
    esac

    test -f Cargo.lock || cargo generate-lockfile

    case $TRAVIS_OS_NAME in
        linux)
            cross build --bin zokrates --package zokrates_cli --features="libsnark" --target $TARGET --release
            ;;
        *)
            cross build --bin zokrates --package zokrates_cli --target $TARGET --release
            ;;
    esac

    # Package artifacts
    # Binary
    cp target/$TARGET/release/$BINARY_NAME $stage/
    # Standard library
    cp -r zokrates_stdlib/stdlib $stage

    cd $stage
    tar czf $src/$CRATE_NAME-$TRAVIS_TAG-$TARGET.tar.gz *
    cd $src

    rm -rf $stage
}

main
