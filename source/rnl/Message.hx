package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;

@:headerCode('#include "rnl.h"')
class Message {
	var _buf:Bytes;
	var _lo:Int;
	var _hi:Int;
	public function new(host:Host, buf:Bytes, offset:Int) {
		var ps = rnl.raw.Types.PTR_BYTES;
		_buf = Bytes.alloc(ps);
		_buf.blit(0, buf, offset, ps);
		readHandle();
		// event owns a ref; take our own so payload stays valid past event_free
		Raw.RNL_message_inc_ref(h());
	}
	public static function fromData(data:Bytes):Message {
		var m = new Message(null, null, 0);
		m._buf = Bytes.alloc(rnl.raw.Types.PTR_BYTES);
		RnlError.check(Raw.RNL_message_create(Native.data(data), data.length, 0, Native.data(m._buf)));
		m.readHandle();
		return m;
	}
	function readHandle():Void {
		_lo = _buf.getInt32(0);
		_hi = _buf.getInt32(4);
	}
	/** The native message handle (by value), reconstructed from lo/hi. */
	inline function h():Dynamic {
		return Native.i64ToPtr(_lo, _hi);
	}
	public var length(get,never):Int;
	function get_length():Int return _buf != null ? Raw.RNL_message_data_length(h()) : 0;
	/** Copy of the message payload bytes. */
	public function getBytes():Bytes {
		if (_buf == null) return Bytes.alloc(0);
		return Native.readPtr(Raw.RNL_message_data(h()), get_length());
	}
	public function dispose():Void {
		if (_buf != null) { Raw.RNL_message_dec_ref(h()); _buf = null; }
	}
	public inline function native():Dynamic return h();
}
