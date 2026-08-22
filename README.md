# hx_rnl — Haxe bindings for RNL

Haxe bindings over `librnl.so` / `RNL.dll` / `librnl.so` (Android) for
**hxcpp** and **HashLink (hl)** targets.

## Layout

    source/rnl/raw/Raw.hx      generated 1:1 bindings (458 functions)
    source/rnl/internal/RnlBuild.hx   @:buildXml helper for hxcpp linking
    project/hdll/rnl_hdll.c    HashLink shim → compile to rnl.hdll
    tools/gen_raw.py           regenerates all of the above from lib/rnl.h
    ndll/Linux64/librnl.so     prebuilt binaries (copied from ../lib/bin)
    ndll/HL64/rnl.hdll         compiled HashLink shim
    example/Main.hx            minimal usage example

## Quick start (hxcpp)

### build.hxml

    -cp source
    -main Main
    --cpp bin/cpp
    -D HXCPP_M64

### Main.hx

```haxe
import rnl.raw.Raw;
import rnl.internal.RnlBuild;

// Include rnl.h so C++ compiler sees declarations.
// Use absolute path or configure -I in your BuildXml.
@:headerCode('#include "/absolute/path/to/rnl.h"')

// Link against librnl.so / RNL.dll.
// Libraries go inside <target id="haxe">, NOT <files id="haxe">!
@:buildXml('<target id="haxe">
	<libpath name="/path/to/dir/containing/librnl.so" />
	<lib name="-lrnl" />
</target>')
class Main {
	public static function main() {
		var v = Raw.RNL_protocol_version();
		trace('version: ${v.high}.${(v.low >> 16) & 0xFFFF}.${v.low & 0xFFFF}');
	}
}
```

### Runtime

Copy `librnl.so` next to the binary or set `LD_LIBRARY_PATH`:

    LD_LIBRARY_PATH=./bin/cpp ./bin/cpp/Main

## Targets

| Target | Command | Runtime deps | Status |
|---|---|---|---|
| **hxcpp** | `--cpp bin/cpp` | librnl.so next to binary or LD_LIBRARY_PATH | ✅ working |
| **hl bytecode** | `--hl bin/hl/app.hl` | hl interpreter + rnl.hdll + librnl.so | ✅ working |
| **hl/c native** | `--hl bin/hl/app.c` then gcc | rnl.hdll + librnl.so; requires HL SDK sources | ⏳ needs hlc |
| **macOS/iOS stubs** | `--cpp` on mac/ios | throws RawUnavailable | 🔒 placeholder |

## Quick start (HashLink)

### build.hxml (hl section)

    -cp source
    -main Main
    --hl bin/hl/app.hl

### Runtime files

Place these next to the `.hl` bytecode (or in `HL_PATH`):

| File | Purpose |
|---|---|
| `rnl.hdll` | HashLink shim (compiled from `project/hdll/rnl_hdll.c`) |
| `librnl.so` / `RNL.dll` | the actual RNL library |

Run:

    hl bin/hl/app.hl

## How linking works — hxcpp

hxcpp generates C++ code that calls RNL functions directly. Two things are needed:

1. **Declarations** — via `@:headerCode('#include "rnl.h"')` on a NON-extern class.
2. **Linking** — via `@:buildXml` on any class. Libraries go inside `<target id="haxe">`.

```haxe
@:headerCode('#include "rnl.h"')
@:buildXml('<files id="haxe">
	<compilerflag value="-I/path/to/rnl/headers" />
</files>
<target id="haxe">
	<libpath name="/path/to/dir/with/so" />
	<lib name="-lrnl" />
</target>')
class Main { ... }
```

Key points:
- `<compilerflag>` goes in `<files>`; `<libpath>` and `<lib>` go in `<target>`
- `<lib name="-lrnl">` — include the `-l` prefix
- The class with `@:buildXml` must be imported/referenced so hxcpp processes it

## How linking works — HashLink

HL loads `.hdll` files at startup. Each `.hdll` is a C shared library built
against the HashLink SDK (`hl.h`) that wraps the target library's API.

1. Generate the shim: `python3 tools/gen_raw.py`
2. Compile: `cc -shared -fPIC -I/usr/include project/hdll/rnl_hdll.c -lrnl -o rnl.hdll`
3. Place `rnl.hdll` + `librnl.so` next to your `.hl` file or in `HL_PATH`

HL resolves functions by name: `@:hlNative("rnl","RNL_free")` looks up prim
`RNL_free` in lib `rnl`. The HDLL registers each prim via `DEFINE_PRIM`.

## Regenerating bindings

When `lib/rnl.h` changes:

    python3 tools/gen_raw.py ../lib/rnl.h

This regenerates `Raw.hx` and `rnl_hdll.c`. Recompile the hdll after.

## Android

Copy `ndll/Android64/librnl.so` (arm64) or `ndll/Android/librnl.so` (armv7)
to your APK's `jniLibs/` directory. Use only the hxcpp target (HL is not
supported on Android).
