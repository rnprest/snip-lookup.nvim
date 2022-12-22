#!/bin/bash

cargo build --release

cp target/release/libsnip_lookup.dylib lua/snip_lookup.so
cp lua/snip_lookup.so lua/snip_lookup.dll
