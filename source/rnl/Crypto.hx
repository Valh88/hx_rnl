package rnl;

import haxe.io.Bytes;
import rnl.raw.Raw;


/**
 * Cryptographic utility functions over RNL's built-in primitives.
 * All static; no state to manage.
 */
@:headerCode('#include "rnl.h"')
class Crypto {

	// ---------------------------------------------------------- encoding

	public static function base64Encode(data:Bytes):String {
		var cap = Math.ceil(data.length * 4 / 3) + 8;
		var out = Bytes.alloc(cap);
		Raw.RNL_base64_encode(Native.data(data), data.length,
			Native.charData(out), cap);
		var len = 0;
		while (len < cap - 1 && out.get(len) != 0) len++;
		return out.getString(0, len);
	}

	public static function base64Decode(text:String):Null<Bytes> {
		var tb = Bytes.ofString(text);
		var cap = Math.ceil(tb.length * 3 / 4) + 8;
		var out = Bytes.alloc(cap);
		var outSize = Bytes.alloc(8), ok = Bytes.alloc(4);
		Raw.RNL_base64_decode(Native.charData(tb), tb.length,
			Native.data(out), cap, Native.data(outSize), Native.data(ok));
		return ok.getInt32(0) != 0 ? out.sub(0, outSize.getInt32(0)) : null;
	}

	public static function hash32(data:Bytes):Int
		return Raw.RNL_hash32(Native.data(data), data.length);

	// ------------------------------------------------------ secure compare

	public static function secureEquals(a:Bytes, b:Bytes):Bool {
		if (a.length != b.length) return false;
		return Raw.RNL_memory_secure_is_equal(Native.data(a), Native.data(b), a.length) != 0;
	}

	public static function isZero(data:Bytes):Bool
		return Raw.RNL_memory_secure_is_zero(Native.data(data), data.length) != 0;

	// ------------------------------------------------------------ hashing

	public static function sha256(data:Bytes):Bytes {
		var out = Bytes.alloc(32);
		Raw.RNL_sha256_process(Native.data(out), Native.data(data), data.length);
		return out;
	}

	public static function sha512(data:Bytes):Bytes {
		var out = Bytes.alloc(64);
		Raw.RNL_sha512_process(Native.data(out), Native.data(data), data.length);
		return out;
	}

	public static function sha1(data:Bytes):Bytes {
		var out = Bytes.alloc(20);
		Raw.RNL_sha1_process(Native.data(out), Native.data(data), data.length);
		return out;
	}

	public static function md5(data:Bytes):Bytes {
		var out = Bytes.alloc(16);
		Raw.RNL_md5_process(Native.data(out), Native.data(data), data.length);
		return out;
	}

	// ---------------------------------------------------------------- HMAC

	public static inline var HASH_MD5 = 0;
	public static inline var HASH_SHA1 = 1;
	public static inline var HASH_SHA256 = 2;
	public static inline var HASH_SHA512 = 3;

	public static function hmac(hashId:Int, key:Bytes, data:Bytes):Null<Bytes> {
		var macLen = switch hashId { case 0: 16; case 1: 20; case 2: 32; case 3: 64; default: return null; };
		var mac = Bytes.alloc(macLen), ok = Bytes.alloc(4);
		Raw.RNL_hmac_process(hashId,
			Native.data(mac), Native.data(key), key.length,
			Native.data(data), data.length, Native.data(ok));
		return ok.getInt32(0) != 0 ? mac : null;
	}

	// --------------------------------------------------------------- HKDF

	public static function hkdfExtract(hashId:Int, salt:Bytes, ikm:Bytes):Null<Bytes> {
		var prkLen = switch hashId { case 2: 32; case 3: 64; default: return null; };
		var prk = Bytes.alloc(prkLen), ok = Bytes.alloc(4);
		Raw.RNL_hkdf_extract(hashId, Native.data(prk),
			Native.data(salt), salt.length,
			Native.data(ikm), ikm.length, Native.data(ok));
		return ok.getInt32(0) != 0 ? prk : null;
	}

	public static function hkdfExpand(hashId:Int, prk:Bytes, info:Bytes, outLen:Int):Null<Bytes> {
		var out = Bytes.alloc(outLen), ok = Bytes.alloc(4);
		Raw.RNL_hkdf_expand(hashId,
			Native.data(out), outLen,
			Native.data(prk), prk.length,
			Native.data(info), info.length, Native.data(ok));
		return ok.getInt32(0) != 0 ? out : null;
	}

	// ------------------------------------------------------------- AEAD

	/** RFC 8439 ChaCha20-Poly1305 encrypt. Returns {cipherText, tag(16)}. */
	public static function aeadEncrypt(key32:Bytes, nonce12:Bytes, plain:Bytes, ?aad:Bytes)
		:{cipherText:Bytes, tag:Bytes} {
		if (aad == null) aad = Bytes.alloc(0);
		var ct = Bytes.alloc(plain.length);
		var tag = Bytes.alloc(16);
		Raw.RNL_chacha20_poly1305_encrypt(
			Native.data(ct), Native.data(tag),
			Native.data(key32), Native.data(nonce12),
			Native.data(aad), aad.length,
			Native.data(plain), plain.length);
		return {cipherText: ct, tag: tag};
	}

	/** RFC 8439 ChaCha20-Poly1305 decrypt. Returns plaintext or null if auth fails. */
	public static function aeadDecrypt(key32:Bytes, nonce12:Bytes, cipherText:Bytes, tag:Bytes, ?aad:Bytes):Null<Bytes> {
		if (aad == null) aad = Bytes.alloc(0);
		var pt = Bytes.alloc(cipherText.length);
		var ok = Bytes.alloc(4);
		Raw.RNL_chacha20_poly1305_decrypt(
			Native.data(pt),
			Native.data(key32), Native.data(nonce12),
			Native.data(tag),
			Native.data(aad), aad.length,
			Native.data(cipherText), cipherText.length,
			Native.data(ok));
		return ok.getInt32(0) != 0 ? pt : null;
	}

	// ------------------------------------------------------- X25519 / Ed25519

	/** Generate X25519 key pair. Returns {publicKey[32], privateKey[32]}. */
	public static function x25519KeyPair(rand:rnl.Random)
		:{publicKey:Bytes, privateKey:Bytes} {
		var pub = Bytes.alloc(32), priv = Bytes.alloc(32), ok = Bytes.alloc(4);
		Raw.RNL_x25519_generate_public_private_key_pair(
			rand.native(), Native.data(pub), Native.data(priv), Native.data(ok));
		if (ok.getInt32(0) == 0) throw new RnlError(-1, "X25519 keygen failed");
		return {publicKey: pub, privateKey: priv};
	}

	/** Compute shared secret from own private + remote public. Returns 32 bytes. */
	public static function x25519SharedSecret(privKey:Bytes, remotePub:Bytes):Null<Bytes> {
		var secret = Bytes.alloc(32), ok = Bytes.alloc(4);
		Raw.RNL_x25519_generate_shared_secret_key(
			Native.data(secret),
			Native.data(remotePub), Native.data(privKey),
			Native.data(ok));
		return ok.getInt32(0) != 0 ? secret : null;
	}

	/** Generate Ed25519 signing key pair. Returns {publicKey[32], privateKey[32]}. */
	public static function ed25519KeyPair(rand:rnl.Random)
		:{publicKey:Bytes, privateKey:Bytes} {
		var pub = Bytes.alloc(32), priv = Bytes.alloc(32);
		Raw.RNL_ed25519_generate_public_private_key_pair(
			rand.native(), Native.data(pub), Native.data(priv));
		return {publicKey: pub, privateKey: priv};
	}

	/** Ed25519 sign. Signature is 64 bytes. */
	public static function ed25519Sign(privKey:Bytes, pubKey:Bytes, message:Bytes):Bytes {
		var sig = Bytes.alloc(64);
		Raw.RNL_ed25519_sign(
			Native.data(privKey), pubKey != null ? Native.data(pubKey) : null,
			Native.data(message), message.length,
			Native.data(sig));
		return sig;
	}

	/** Ed25519 verify. */
	public static function ed25519Verify(signature:Bytes, pubKey:Bytes, message:Bytes):Bool
		return Raw.RNL_ed25519_verify(
			Native.data(signature), Native.data(pubKey),
			Native.data(message), message.length) != 0;
}
