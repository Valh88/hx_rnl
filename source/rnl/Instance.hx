package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;

class Instance extends HandleWrapper {
	public function new() {
		super();
		var tmp = Bytes.alloc(8);
		RnlError.check(Raw.RNL_instance_create(Native.data(tmp)), "Instance.create");
		readHandle(tmp);
	}
	override public function dispose():Void {
		if (!disposed) { Raw.RNL_instance_destroy(h()); disposed = true; }
		super.dispose();
	}
	public static function selfTestCrypto():Bool {
		var ok = Bytes.alloc(4), chk = Bytes.alloc(8), fail = Bytes.alloc(8);
		Raw.RNL_self_test_cryptography(null, null,
			Native.data(ok), Native.data(chk), Native.data(fail));
		return ok.getInt32(0) != 0;
	}
	#if cpp
	public inline function native():cpp.Star<cpp.Void> return h();
	#else
	public inline function native():Dynamic return h();
	#end
}
