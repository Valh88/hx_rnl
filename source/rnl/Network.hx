package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;

class Network extends HandleWrapper {
	override public function dispose():Void { disposed = true; }
	function new() { super(); }
	#if cpp
	public inline function native():cpp.Star<cpp.Void> return h();
	#else
	public inline function native():Dynamic return h();
	#end
}

class RealNetwork extends Network {
	public function new(inst:Instance) {
		super();
		var tmp = Bytes.alloc(8);
		RnlError.check(Raw.RNL_network_real_create(inst.native(), Native.data(tmp)), "RealNetwork");
		readHandle(tmp);
	}
	override public function dispose():Void {
		if (!disposed) { Raw.RNL_network_real_destroy(h()); disposed = true; }
		super.dispose();
	}
}

class VirtualNetwork extends Network {
	public function new(inst:Instance) {
		super();
		var tmp = Bytes.alloc(8);
		RnlError.check(Raw.RNL_network_virtual_create(inst.native(), Native.data(tmp)), "VirtualNetwork");
		readHandle(tmp);
	}
	override public function dispose():Void {
		if (!disposed) { Raw.RNL_network_virtual_destroy(h()); disposed = true; }
		super.dispose();
	}
}
