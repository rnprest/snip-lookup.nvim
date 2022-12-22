#!/bin/bash

cargo build --all --release && mv target/release/libsnip_lookup.dylib lua/snip_lookup.so
