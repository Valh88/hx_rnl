package rnl;

import haxe.io.Bytes;
import rnl.raw.Raw;

/**
 * DTLS transport security: verification config + DTLS 1.2/1.3 clients.
 * For use over TURN relay or custom UDP sockets when the built-in
 * RNL handshake encryption is not sufficient.
 */
@:headerCode('#include "rnl.h"')
class DtlsVerification
{
	var _buf:Bytes;

	public var disposed(default, null):Bool = false;

	function lo():Int
		return _buf != null ? _buf.getInt32(0) : 0;

	function hi():Int
		return _buf != null ? _buf.getInt32(4) : 0;

	public inline function native():Dynamic
		return Native.i64ToPtr(lo(), hi());

	public function new()
	{
		_buf = Bytes.alloc(8);
		RnlError.check(Raw.RNL_dtls_verification_create(Native.data(_buf)), "DtlsVerification.create");
	}

	/** Verify via certificate chain (RFC 5280). hostname for SAN check, nowUnixSec for validity. */
	public function setChain(hostname:String, nowUnixSec:Int):Void
	{
		var hn = Bytes.ofString(hostname);
		untyped __cpp__('RNL_dtls_verification_set_chain({0}, (const char*){1}->b->GetBase(), {2}, {3})', native(), hn, hn.length, nowUnixSec);
	}

	/** Or verify by fingerprint pinning. Set allowRawPubKey for RFC 7250. */
	public function setFingerprints(allowRawPubKey:Bool):Void
		Raw.RNL_dtls_verification_set_fingerprints(native(), allowRawPubKey ? 1 : 0);

	public function addTrustedRoot(derCert:Bytes):Bool
	{
		return Raw.RNL_dtls_verification_add_trusted_root(native(), Native.data(derCert), derCert.length) == 0;
	}

	public function addFingerprint(sha256Bytes:Bytes):Bool
	{
		if (sha256Bytes.length != 32)
			return false;
		return Raw.RNL_dtls_verification_add_fingerprint(native(), Native.data(sha256Bytes)) == 0;
	}

	public function dispose():Void
	{
		if (!disposed && _buf != null)
		{
			Raw.RNL_dtls_verification_destroy(native());
			_buf = null;
			disposed = true;
		}
	}
}

enum abstract DtlsState(Int)
{
	var Idle;
	var AwaitingHelloVerify;
	var AwaitingServerFlight;
	var AwaitingServerFinished;
	var Established;
	var Failed;
}

/**
 * DTLS 1.2 client (RFC 6347) for encrypted datagram transport.
 * Feed wire data in via processDatagram(), pop outgoing via popOutgoing().
 */
@:headerCode('#include "rnl.h"')
class Dtls12Client
{
	var _buf:Bytes;

	public var disposed(default, null):Bool = false;

	function lo():Int
		return _buf != null ? _buf.getInt32(0) : 0;

	function hi():Int
		return _buf != null ? _buf.getInt32(4) : 0;

	inline function h():Dynamic
		return Native.i64ToPtr(lo(), hi());

	public function new(rand:rnl.Random, serverName:String, verification:DtlsVerification)
	{
		var sn = Bytes.ofString(serverName);
		_buf = Bytes.alloc(8);
		RnlError.check(Raw.RNL_dtls12_client_create(rand.native(), Native.charData(sn), sn.length, verification.native(), Native.data(_buf)),
			"Dtls12Client.create");
	}

	public function start(nowUnixMs:haxe.Int64):Void
		Raw.RNL_dtls12_client_start(h(), nowUnixMs);

	/** Feed an incoming UDP payload into the DTLS state machine. */
	public function processDatagram(data:Bytes, nowUnixMs:haxe.Int64):Void
		Raw.RNL_dtls12_client_process_datagram(h(), Native.data(data), data.length, nowUnixMs);

	/** Drive retransmission timers; call periodically. */
	public function update(nowUnixMs:haxe.Int64):Void
		Raw.RNL_dtls12_client_update(h(), nowUnixMs);

	/** Pop a datagram that needs to be sent over the wire. Null if none pending. */
	public function popOutgoing():Null<Bytes>
	{
		var buf = Bytes.alloc(4096);
		var size = Bytes.alloc(8), ok = Bytes.alloc(4);
		Raw.RNL_dtls12_client_pop_outgoing_datagram(h(), Native.data(buf), buf.length, Native.data(size), Native.data(ok));
		if (ok.getInt32(0) == 0 || size.getInt32(0) <= 0)
			return null;
		return buf.sub(0, size.getInt32(0));
	}

	/** Send application data (after handshake established). */
	public function send(data:Bytes):Bool
	{
		var ok = Bytes.alloc(4);
		Raw.RNL_dtls12_client_send(h(), Native.data(data), data.length, Native.data(ok));
		return ok.getInt32(0) != 0;
	}

	/** Pop decrypted application data from the peer. Null if none available. */
	public function popApplicationData(maxSize:Int = 65536):Null<Bytes>
	{
		var buf = Bytes.alloc(maxSize);
		var size = Bytes.alloc(8), ok = Bytes.alloc(4);
		Raw.RNL_dtls12_client_pop_application_data(h(), Native.data(buf), maxSize, Native.data(size), Native.data(ok));
		if (ok.getInt32(0) == 0 || size.getInt32(0) <= 0)
			return null;
		return buf.sub(0, size.getInt32(0));
	}

	public var state(get, never):DtlsState;

	function get_state():DtlsState
		return cast Raw.RNL_dtls12_client_get_state(h());

	public var failureCode(get, never):Int;

	function get_failureCode():Int
		return Raw.RNL_dtls12_client_get_failure(h());

	public function dispose():Void
	{
		if (!disposed && _buf != null)
		{
			Raw.RNL_dtls12_client_destroy(h());
			_buf = null;
			disposed = true;
		}
	}
}
