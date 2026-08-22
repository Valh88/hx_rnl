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
		var dOff = pOff + PS() * 2;
		switch (type) {
			case EventType.PeerConnect | EventType.PeerDisconnect:
				data = Native.getI64(buf, dOff);
			case EventType.PeerDenial:
				denialReason = cast buf.getInt32(dOff);
			case EventType.PeerMtu:
				mtu = Native.getU16(buf, dOff);
			default:
		}
	}
}
