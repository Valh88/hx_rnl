package rnl;
import haxe.io.Bytes;
import rnl.Enums.EventType;
import rnl.Enums.DenialReason;

class RnlEvent {
	public var type(default,null):EventType;
	public var peer(default,null):Null<Peer>;
	public var message(default,null):Null<Message>;
	public var channel(default,null):Int;
	public var data(default,null):haxe.Int64;
	public var denialReason(default,null):DenialReason;
	public var mtu(default,null):Int;
	static inline function PS():Int return rnl.raw.Types.PTR_BYTES;

	public function new(host:Host, buf:Bytes) {
		type = cast buf.getInt32(0);
		#if rnl_event_dump
		if (type == EventType.PeerDisconnect) {
			var hex = new StringBuf();
			for (i in 0...40) hex.add(StringTools.hex(buf.get(i), 2) + " ");
			trace('event t=$type: ${hex.toString()}');
		}
		#end
		channel = 0; data = haxe.Int64.ofInt(0);
		denialReason = cast 0; mtu = 0;
		peer = null; message = null;
		var pOff = 4, mOff = 4 + PS();
		var hasPeer = buf.length > pOff + PS();
		switch (type) {
			case EventType.PeerConnect, EventType.PeerDisconnect,
			     EventType.PeerApproval, EventType.PeerDenial,
			     EventType.PeerBandwidthLimits, EventType.PeerMtu,
			     EventType.PeerReceive:
				if (hasPeer) peer = new Peer(host, buf, pOff);
			default:
		}
		if (type == EventType.PeerReceive && buf.length > mOff + PS())
			message = new Message(host, buf, mOff);
		// packed struct (verified by byte-dump):
		// [i32 type@0][ptr peer@4][ptr msg@12][u8 ch@20][u64 data@21][i32 denial@29][u16 mtu@33]
		var chOff = pOff + PS() * 2;
		var dOff = chOff + 1;
		if (buf.length > chOff)
			channel = buf.get(chOff);
		var denOff = dOff + 8, mtuOff = denOff + 4;
		switch (type) {
			case EventType.PeerConnect | EventType.PeerDisconnect:
				if (buf.length >= dOff + 8) data = Native.getI64(buf, dOff);
			case EventType.PeerDenial:
				if (buf.length >= denOff) denialReason = cast buf.getInt32(denOff);
			case EventType.PeerMtu:
				if (buf.length >= mtuOff) mtu = Native.getU16(buf, mtuOff);
			default:
		}
	}
}
