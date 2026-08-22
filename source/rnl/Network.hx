package rnl;

import haxe.io.Bytes;
import rnl.raw.Raw;

class Network {
	var _buf:Bytes;
	public var disposed(default,null):Bool = false;
	function new(buf:Bytes) { _buf = buf; }
	public function dispose():Void { disposed = true; }
	public inline function native():Dynamic return _buf;
}

class RealNetwork extends Network {
	public function new(inst:Instance) {
		var b = Native.buf(8);
		RnlError.check(Raw.RNL_network_real_create(inst.native(), Native.data(b)), "RealNetwork");
		super(b);
	}
	override public function dispose():Void {
		if (!disposed) { Raw.RNL_network_real_destroy(Native.data(_buf)); disposed = true; }
		super.dispose();
	}
}

class VirtualNetwork extends Network {
	public function new(inst:Instance) {
		var b = Native.buf(8);
		RnlError.check(Raw.RNL_network_virtual_create(inst.native(), Native.data(b)), "VirtualNetwork");
		super(b);
	}
	override public function dispose():Void {
		if (!disposed) { Raw.RNL_network_virtual_destroy(Native.data(_buf)); disposed = true; }
		super.dispose();
	}
}
