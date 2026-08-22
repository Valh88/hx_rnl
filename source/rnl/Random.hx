package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;

class Random {
	var _h:Bytes;
	public function new() {
		_h = Bytes.alloc(8);
		RnlError.check(Raw.RNL_random_create(Native.data(_h)));
	}
	public function dispose():Void {
		if (_h != null) { Raw.RNL_random_destroy(Native.data(_h)); _h = null; }
	}
	public function getBytes(n:Int):Bytes {
		var out = Bytes.alloc(n);
		RnlError.check(Raw.RNL_random_get_bytes(Native.data(_h), out, n));
		return out;
	}
	public function getU32():Int return Raw.RNL_random_get_u32(Native.data(_h));
	public function getDouble():Float return Raw.RNL_random_get_double(Native.data(_h));
	public inline function native():Dynamic return Native.data(_h);
}
