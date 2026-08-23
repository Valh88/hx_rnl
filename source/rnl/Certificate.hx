package rnl;

import haxe.io.Bytes;
import rnl.raw.Raw;

/**
 * Single-stage certificate helpers (104-byte Ed25519 certificates).
 * Certificates authenticate servers without X.509 infrastructure.
 *
 * Layout: subject(32) + issuer_signature(64) + valid_from_minutes(u32) +
 *         valid_until_minutes(u32) + reserved = 104 bytes.
 */
@:headerCode('#include "rnl.h"')
class Certificate
{
	public static inline var SIZE = 104;
	public static inline var SUBJECT_SIZE = 32;
	public static inline var KEY_SIZE = 32;

	/**
		Issue a certificate signed by the authority key pair.
		subject: 32 bytes (opaque identity — compared byte-for-byte by peers).
		pubKey: 32 bytes, the certified party's long-term public key.
		validFromMin / validUntilMin: minutes since 2026-01-01 UTC.
		authorityPriv/pubKey: 32-byte Ed25519 keypair of the issuing authority.
		Returns 104-byte certificate or null on failure.
	**/
	public static function issue(subject:Bytes, pubKey:Bytes, validFromMin:Int, validUntilMin:Int, authorityPrivKey:Bytes, authorityPubKey:Bytes):Null<Bytes>
	{
		var cert = Bytes.alloc(SIZE);
		var status = Raw.RNL_certificate_issue(Native.data(cert), Native.data(subject), Native.data(pubKey), validFromMin, validUntilMin,
			Native.data(authorityPrivKey), Native.data(authorityPubKey));
		return status == 0 ? cert : null;
	}

	/** True if the certificate area is all zeros (= no certificate). */
	public static function isAbsent(cert:Bytes):Bool
		return Raw.RNL_certificate_is_absent(Native.data(cert)) != 0;

	/** Convert Unix seconds to certificate minutes-since-2026-01-01. */
	public static function minutesFromUnixTime(unixSeconds:haxe.Int64):Int
		return Raw.RNL_certificate_minutes_from_unix_time(unixSeconds);

	/** Check if a DER-encoded X.509 certificate matches a hostname (SAN). */
	public static function x509MatchesHostName(derCert:Bytes, hostname:String):Bool
	{
		var hn = Bytes.ofString(hostname);
		return Raw.RNL_x509_matches_host_name(Native.data(derCert), derCert.length, Native.charData(hn), hn.length) != 0;
	}
}
