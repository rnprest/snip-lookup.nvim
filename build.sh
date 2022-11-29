#!/bin/bash

cargo build --release

cp target/release/libsnip_lookup_rust.dylib lua/snip_lookup_rust.so
cp lua/snip_lookup_rust.so lua/snip_lookup_rust.dll
