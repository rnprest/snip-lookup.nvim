#!/usr/bin/env bash

# ---------------------------------------------------------------------
# Taken from https://github.com/krivahtoo/silicon.nvim;
# You should absolutely check out their plugin if you often
# find yourself taking screenshots of your code to share!
# I use it all the time.

# If you do want to use their plugin, my configuration for it is below:

# use {
# 	'krivahtoo/silicon.nvim',
# 	run = './install.sh',
# 	config = function()
# 		require('silicon').setup {
# 			font = 'Iosevka Nerd Font Mono=20',
# 			background = '#ffffff',
# 			line_number = true,
# 			shadow = {
# 				blur_radius = 7.0,
# 			},
# 			pad_horiz = 20,
# 			pad_vert = 20,
# 		}
# 		vim.keymap.set('v', '<leader>ss', [[:Silicon<CR>]])
# 	end,
# }
# ---------------------------------------------------------------------

set -e

# get current version from Cargo.toml
get_version() {
	cat Cargo.toml | grep '^version =' | sed -E 's/.*"([^"]+)".*/\1/'
}

# compile from source
build() {
	echo "Building snip-lookup.nvim from source..."

	cargo build --release --target-dir ./target

	# Place the compiled library where Neovim can find it.
	mkdir -p lua

	if [ "$(uname)" == "Darwin" ]; then
		mv target/release/libsnip_lookup.dylib lua/snip_lookup.so
	elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
		mv target/release/libsnip_lookup.so lua/snip_lookup.so
	elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
		mv target/release/snip_lookup.dll lua/snip_lookup.dll
	fi
}

# download the snip-lookup.nvim (of the specified version) from Releases
download() {
	echo "Downloading snip-lookup.nvim library: $1"
	if [ "$(uname)" == "Darwin" ]; then
		arch_name="$(uname -m)"
		curl -fsSL https://github.com/rnprest/snip-lookup.nvim/releases/download/$1/snip-lookup-mac-${arch_name}.tar.gz | tar -xz
	elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
		curl -fsSL https://github.com/rnprest/snip-lookup.nvim/releases/download/$1/snip-lookup-linux.tar.gz | tar -xz
	elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
		echo "Windows build is not available yet."
		build
	fi
}

case "$1" in
build)
	build
	;;
*)
	version="v$(get_version)"
	download "$version"

	;;
esac
