#!/bin/bash
# Builds and runs the Haxe RNL example.
# Usage: ./run.sh [cpp|hl|hlc|all]
#
# Targets:
#   cpp — hxcpp native binary (links librnl.so at compile time)
#   hl  — HashLink bytecode (.hl), runs via `hl` interpreter + rnl.hdll
#   hlc — HashLink compiled to native C (links libhl + rnl.hdll + librnl)
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
RNL_ROOT="$(cd "$DIR/../.." && pwd)"
HL_SRC="${HL_SRC:-/home/vano/.haxe_lib/hashlink/git/src}"
export CPATH="$RNL_ROOT/lib:$CPATH"
TARGET="${1:-all}"
cd "$DIR"

build_cpp() {
	haxe -cp ../source -main Main --cpp bin/cpp -D HXCPP_M64
	# librnl.so is copied into bin/cpp automatically by RnlBuild.hx <copyFile>,
	# and the binary has $ORIGIN rpath baked in — nothing else needed.
	echo "=== hxcpp ==="
	./bin/cpp/Main
}

gen_hl() {
	haxe -cp ../source -main Main --hl bin/hl/Main.hl
	cp "$RNL_ROOT/hx_rnl/ndll/HL64/rnl.hdll" bin/hl/
	cp "$RNL_ROOT/lib/bin/linux-x64/librnl.so" bin/hl/
}

build_hl() {
	gen_hl
	echo "=== hl bytecode ==="
	cd bin/hl && LD_LIBRARY_PATH=. hl Main.hl && cd ../..
}

build_hlc() {
	local HLDIR="/home/vano/.haxe_lib/hashlink/git"
	local RNL="$RNL_ROOT"

	# Step 1: generate C code
	haxe -cp ../source -main Main --hl bin/hlc/Main.c

	# Step 2: copy runtime files
	cp "$RNL/hx_rnl/ndll/HL64/rnl.hdll" bin/hlc/
	cp "$RNL/lib/bin/linux-x64/librnl.so" bin/hlc/

	# Step 3: compile + link (generated C includes everything via #include)
	gcc -O2 -o bin/hlc/Main bin/hlc/Main.c \
		-I"$HLDIR/src" -Ibin/hlc \
		"$HLDIR/libhl.so" \
		"$RNL/hx_rnl/ndll/HL64/rnl.hdll" \
		-L"$RNL/lib/bin/linux-x64" -lrnl \
		-lm -lpthread -ldl \
		-Wl,-rpath,"$RNL/hx_rnl/ndll/HL64:$RNL/lib/bin/linux-x64:\$ORIGIN"

	echo "=== hl/c native ==="
	bin/hlc/Main
}

case "$TARGET" in
	cpp) build_cpp ;;
	hl)  gen_hl; build_hl ;;
	hlc) build_hlc ;;
	all) build_cpp; gen_hl; build_hl; build_hlc ;;
	*)   echo "Usage: $0 [cpp|hl|hlc|all]"; exit 1 ;;
esac
