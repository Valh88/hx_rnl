package rnl;

import haxe.io.Bytes;
import rnl.raw.Raw;

class Instance {
	var _lo:Int;
	var _hi:Int;
	var _created:Bool;

	public function new() {
		var buf = Bytes.alloc(8);
		RnlError.check(Raw.RNL_instance_create(Native.data(buf)), "Instance.create");
		_lo = buf.getInt32(0);
		_hi = buf.getInt32(4);
		_created = true;
	}

	public function dispose():Void {
		if (_created) {
			var h = Native.i64ToPtr(_lo, _hi);
			Raw.RNL_instance_destroy(h);
			_created = false;
		}
	}

	public var time(get, set):haxe.Int64;
	function get_time():haxe.Int64 {
		var h = Native.i64ToPtr(_lo, _hi);
		var out = Bytes.alloc(8);
		RnlError.check(Raw.RNL_instance_time(h, Native.data(out)));
		return out.getInt64(0);
	}
	function set_time(v:haxe.Int64):haxe.Int64 {
		var h = Native.i64ToPtr(_lo, _hi);
		var t = Native.data(Bytes.alloc(8));
		Bytes.alloc(8).setInt64(0, v); // write value
		var tmp = Bytes.alloc(8);
		tmp.setInt64(0, v);
		RnlError.check(Raw.RNL_instance_set_time(h, Native.data(tmp)));
		return v;
	}

	public static function selfTestCrypto():Bool {
		var ok = Bytes.alloc(4);
		var chk = Bytes.alloc(8);
		var fail = Bytes.alloc(8);
		Raw.RNL_self_test_cryptography(null, null, Native.data(ok), Native.data(chk), Native.data(fail));
		return ok.getInt32(0) != 0;
	}

	public inline function native():Dynamic {
		return Native.i64ToPtr(_lo, _hi);
	}
}
