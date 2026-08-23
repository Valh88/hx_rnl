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

/** Fault-injecting decorator over another network.
 *  Simulates loss/duplication/reordering/latency/jitter. */
class InterferenceNetwork extends Network {
	public function new(inst:Instance, underlying:Network) {
		super();
		var tmp = Bytes.alloc(8);
		RnlError.check(
			Raw.RNL_network_interference_create(inst.native(), underlying.native(), Native.data(tmp)),
			"InterferenceNetwork"
		);
		readHandle(tmp);
	}
	override public function dispose():Void {
		if (!disposed) { Raw.RNL_network_interference_destroy(h()); disposed = true; }
		super.dispose();
	}
	/** probability 0..1; outgoing=true affects packets we send. */
	public function setLoss(probability:Float, outgoing:Bool = true):Void {
		var v = Std.int(Math.min(1, Math.max(0, probability)) * 4294967296.0);
		Raw.RNL_network_interference_set_simulated_factor(h(), outgoing ? 1 : 0, v);
	}
}
