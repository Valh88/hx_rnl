package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;
import rnl.Enums.WorkMode;
import rnl.Enums.EventType;

class Host extends HandleWrapper {
	var _evBuf:Bytes;
	var _stBuf:Bytes;

	public function new(inst:Instance, network:Network) {
		super();
		_evBuf = Bytes.alloc(64);
		_stBuf = Bytes.alloc(4);
		var tmp = Bytes.alloc(8);
		RnlError.check(
			Raw.RNL_host_create(inst.native(), network.native(), Native.data(tmp)),
			"Host.create"
		);
		readHandle(tmp);
	}

	override public function dispose():Void {
		if (!disposed) { Raw.RNL_host_destroy(h()); disposed = true; }
		super.dispose();
	}

	public function setAddress(addr:Address):Void {
		RnlError.check(Raw.RNL_host_set_address(h(), addr.native()));
	}

	public function start(mode:WorkMode):Void {
		RnlError.check(Raw.RNL_host_start(h(), cast mode), "Host.start");
	}

	public function service(timeoutMs:Int):Null<RnlEvent> {
		var st = Bytes.alloc(4);
		Raw.RNL_host_service(h(), Native.data(_evBuf),
			haxe.Int64.ofInt(timeoutMs), Native.data(st));
		if (st.getInt32(0) == 3) return new RnlEvent(this, _evBuf);
		return null;
	}

	public function eventFree():Void Raw.RNL_host_event_free(h());

	public function connect(addr:Address, channels:Int = 1, ?data:Null<haxe.Int64>):Peer {
		if (data == null) data = haxe.Int64.ofInt(0);
		var pb = Bytes.alloc(8);
		var tok:Dynamic = null;
		RnlError.check(
			Raw.RNL_host_connect(h(), addr.native(), channels,
				data, tok, tok, tok, tok, pb),
			"Host.connect"
		);
		return new Peer(this, pb);
	}

	public function broadcast(channel:Int, data:Bytes):Void {
		Raw.RNL_host_broadcast_message_data(h(), channel, data, data.length, 0);
	}
}
