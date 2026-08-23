package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;

class Peer extends HandleWrapper {
	public function new(host:Host, buf:Bytes, offset:Int = 0) {
		super();
		var ps = rnl.raw.Types.PTR_BYTES;
		_lo = buf.getInt32(offset);
		_hi = buf.getInt32(offset + 4);
	}
	override public function dispose():Void {
		if (!disposed) { disposed = true; }
		super.dispose();
	}
	public function incRef():Void Raw.RNL_peer_inc_ref(h());
	public function decRef():Void Raw.RNL_peer_dec_ref(h());
	public var localPeerId(get,never):Int;
	function get_localPeerId():Int return Raw.RNL_peer_get_local_peer_id(h());
	public var remotePeerId(get,never):Int;
	function get_remotePeerId():Int return Raw.RNL_peer_get_remote_peer_id(h());
	public var mtu(get,never):Int;
	function get_mtu():Int return Raw.RNL_peer_get_mtu(h());
	public var minRtt(get,never):Int;
	function get_minRtt():Int return Raw.RNL_peer_get_minimum_round_trip_time(h());
	public var countChannels(get,set):Int;
	function get_countChannels():Int return Raw.RNL_peer_get_count_channels(h());
	function set_countChannels(v:Int):Int { Raw.RNL_peer_set_count_channels(h(),v); return v; }
	public function getChannel(i:Int):Null<Channel> {
		var cb = Bytes.alloc(rnl.raw.Types.PTR_BYTES);
		return Raw.RNL_peer_get_channel(h(), i, cb) == 0 ? new Channel(cb) : null;
	}
}
