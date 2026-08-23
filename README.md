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

Nothing to do for hxcpp: `RnlBuild.hx` copies `librnl.so` into the build
output automatically (`<copyFile>`), and the binary carries
`-rpath $ORIGIN:<package>/ndll/Linux64` — just run it:

    ./bin/cpp/Main

## Targets

| Target | Command | Runtime deps | Status |
|---|---|---|---|
| **hxcpp** | `--cpp bin/cpp` | nothing — auto-copied + rpath baked in | ✅ working |
| **hl bytecode** | `--hl bin/hl/app.hl` | rnl.hdll + librnl.so next to .hl; run with `LD_LIBRARY_PATH=bin/hl` | ✅ working |
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

---

## Authentication & Token Checking

RNL has built-in encryption on every packet (XChaCha20-Poly1305, X25519
handshake). Token checking is an **additional** layer that protects against
DDoS amplification and unauthorised connections.

### Two token types

| Token | Size | When checked | Purpose |
|---|---|---|---|
| **Connection token** | 128 B | At first packet, in cleartext | Reject garbage before wasting CPU on handshake |
| **Authentication token** | 128 B | After key exchange, encrypted | Verify the client is authorised to connect |

Both are opaque 128-byte blobs. RNL does not interpret them — the application
decides what goes inside and how to validate it.

### Where tokens come from

Tokens are issued by a **master server** (login backend) — a separate HTTPS
service that authenticates users out-of-band:

```
Player ──HTTPS──▶ Master Server          "I'm user X, password Y"
                  │
                  ▼ issues 128-byte blob
                 Player
                  │
                  ▼ presents token when connecting
              Game Server ──▶ validates → accepts or rejects
```

The master server signs each token with its Ed25519 private key.
The game server holds the matching public key and verifies signatures.

### Server-side setup

```haxe
var srv = new Host(inst, net);

// Enable synchronous C-level token checking (accept-all).
// This rejects malformed/garbage first packets — DDoS protection.
srv.enableTokenCheck();

// Fine-grained validation happens post-handshake:
srv.onPeerConnect = function(ev) {
    // ev.data is the u64 the client passed in connect()
    // For full token validation, use Raw.RNL_host_connect's token params
    if (!isAuthorisedUser(ev.data)) {
        ev.peer.disconnect(0);  // reject after handshake
        return;
    }
    // ... accept player into game
};

srv.start(WorkMode.WmV4Only);
```

### Client-side connection

```haxe
var cli = new Host(inst, net);
cli.start(WorkMode.WmV4Only);
// data field carries an application-defined session key or player ID
var peer = cli.connect(serverAddr, 1, haxe.Int64.ofInt(playerId));
```

For full 128-byte token blobs, use `Raw.RNL_host_connect` directly with
`connection_token` and `authentication_token` pointers:

```haxe
var connToken = Bytes.alloc(128); // fill from master server response
var authToken = Bytes.alloc(128); // fill from master server response
Raw.RNL_host_connect(hostHandle, addrPtr, channels,
    playerId,                          // u64 data
    Native.data(connToken),            // connection token
    Native.data(authToken),            // authentication token
    null,                              // expected remote LTPK (pinning)
    null,                              // expected subject
    peerBuf);
```

### Validation strategies

| Level | Mechanism | When |
|---|---|---|
| **Protocol** | `enableTokenCheck()` — C callback accepts well-formed tokens | Synchronous, during handshake |
| **Post-connect** | `onPeerConnect` + check `ev.data` / disconnect | After handshake completes |
| **Application** | Custom auth message on reliable channel | After connection established |

For most games: enable protocol-level checking + validate in onPeerConnect.
The C-level callback protects against DDoS floods; the Haxe-level check
handles business logic (bans, subscriptions, etc.).
