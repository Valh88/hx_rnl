package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;
import rnl.Enums.WorkMode;
import rnl.Enums.EventType;

class Host {
	var _inst:Instance;
	var _buf:Bytes;
	var _evBuf:Bytes;
	var _stBuf:Bytes;
	public var disposed(default,null):Bool = false;

	public function new(inst:Instance, network:Network) {
		_inst = inst;
		_buf = Native.buf(8);
		_evBuf = Native.buf(64);
		_stBuf = Native.buf(4);
		RnlError.check(
			Raw.RNL_host_create(inst.native(), network.native(), Native.data(_buf)),
			"Host.create"
		);
	}

	public function dispose():Void {
		if (!disposed) { Raw.RNL_host_destroy(Native.data(_buf)); disposed = true; }
	}

	public function setAddress(addr:Address):Void {
		RnlError.check(Raw.RNL_host_set_address(Native.data(_buf), addr.native()));
	}

	public function start(mode:WorkMode):Void {
		RnlError.check(Raw.RNL_host_start(Native.data(_buf), cast mode), "Host.start");
	}

	public function service(timeoutMs:Int):Null<RnlEvent> {
		var tmo = Bytes.alloc(8);
		Native.setI64(tmo, 0, haxe.Int64.ofInt(timeoutMs));
		Raw.RNL_host_service(_buf, Native.data(_evBuf),
			haxe.Int64.ofInt(timeoutMs), _stBuf);
		var st:Int = _stBuf.getInt32(0);
		return st == 3 ? new RnlEvent(this, _evBuf) : null;
	}

	public function eventFree():Void Raw.RNL_host_event_free(Native.data(_buf));

	public function connect(addr:Address, channels:Int = 1, ?data:haxe.Int64):Peer {
		if (data == null) data = haxe.Int64.ofInt(0);
		var pb = Bytes.alloc(8);
		var tok:haxe.io.Bytes = null;
		RnlError.check(
			Raw.RNL_host_connect(Native.data(_buf), addr.native(), channels, data,
				tok, tok, tok, tok, pb),
			"Host.connect"
		);
		return new Peer(this, pb);
	}

	public function broadcast(channel:Int, data:Bytes):Void {
		Raw.RNL_host_broadcast_message_data(Native.data(_buf), channel, data, data.length, 0);
	}

	public function flush():Void {
		var ok = Native.buf(4);
		Raw.RNL_host_flush(Native.data(_buf), ok);
	}

	public function interrupt():Void Raw.RNL_host_interrupt(Native.data(_buf));

	public var allowIncoming(get,set):Bool;
	function get_allowIncoming():Bool return Raw.RNL_host_get_allow_incoming_connections(Native.data(_buf)) != 0;
	function set_allowIncoming(v:Bool):Bool {
		Raw.RNL_host_set_allow_incoming_connections(Native.data(_buf), v?1:0); return v;
	}

	public var countPeers(get,never):Int;
	function get_countPeers():Int return Raw.RNL_host_get_count_peers(Native.data(_buf));
}
