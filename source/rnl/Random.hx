package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;

class Random {
	var _buf:Bytes;
	var _lo:Int;
	var _hi:Int;
	public function new() {
		_buf = Bytes.alloc(8);
		RnlError.check(Raw.RNL_random_create(Native.data(_buf)));
		readHandle();
	}
	function readHandle():Void {
		_lo = _buf.getInt32(0);
		_hi = _buf.getInt32(4);
	}
	inline function h():Dynamic return Native.i64ToPtr(_lo, _hi);
	public function dispose():Void {
		if (_buf != null) { Raw.RNL_random_destroy(h()); _buf = null; }
	}
	public function getBytes(n:Int):Bytes {
		var out = Bytes.alloc(n);
		RnlError.check(Raw.RNL_random_get_bytes(h(), Native.data(out), n));
		return out;
	}
	public function getU32():Int return Raw.RNL_random_get_u32(h());
	public function getDouble():Float return Raw.RNL_random_get_double(h());
	public inline function native():Dynamic return h();
}
