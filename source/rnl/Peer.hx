package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;

class Peer {
	var _buf:Bytes;
	public function new(host:Host, buf:Bytes, offset:Int = 0) {
		var ps = rnl.raw.Types.PTR_BYTES;
		_buf = Bytes.alloc(ps);
		_buf.blit(0, buf, offset, ps);
	}
	public function incRef():Void Raw.RNL_peer_inc_ref(Native.data(_buf));
	public function decRef():Void Raw.RNL_peer_dec_ref(Native.data(_buf));
	public function disconnect(data:haxe.Int64, delayed:Bool = false):Void {
		Raw.RNL_peer_disconnect(Native.data(_buf), data, delayed?1:0);
	}
	public var localPeerId(get,never):Int;
	function get_localPeerId():Int return Raw.RNL_peer_get_local_peer_id(Native.data(_buf));
	public var remotePeerId(get,never):Int;
	function get_remotePeerId():Int return Raw.RNL_peer_get_remote_peer_id(Native.data(_buf));
	public var mtu(get,never):Int;
	function get_mtu():Int return Raw.RNL_peer_get_mtu(Native.data(_buf));
	public var minRtt(get,never):Int;
	function get_minRtt():Int return Raw.RNL_peer_get_minimum_round_trip_time(Native.data(_buf));
	public var countChannels(get,set):Int;
	function get_countChannels():Int return Raw.RNL_peer_get_count_channels(Native.data(_buf));
	function set_countChannels(v:Int):Int { Raw.RNL_peer_set_count_channels(Native.data(_buf),v); return v; }
	public function getChannel(i:Int):Null<Channel> {
		var cb = Bytes.alloc(rnl.raw.Types.PTR_BYTES);
		return Raw.RNL_peer_get_channel(Native.data(_buf), i, cb) == 0 ? new Channel(cb) : null;
	}
}
