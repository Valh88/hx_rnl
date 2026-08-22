package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;

class Channel {
	var _buf:Bytes;
	public function new(buf:Bytes) {
		_buf = Bytes.alloc(rnl.raw.Types.PTR_BYTES);
		_buf.blit(0, buf, 0, rnl.raw.Types.PTR_BYTES);
	}
	public function send(data:Bytes, flags:Int = 0):Void {
		RnlError.check(Raw.RNL_channel_send_message_data(Native.data(_buf), data, data.length, flags));
	}
	public function sendString(s:String, flags:Int = 0):Void send(Bytes.ofString(s), flags);
	public var pendingOutgoing(get,never):Int;
	function get_pendingOutgoing():Int return Raw.RNL_channel_get_count_pending_outgoing(Native.data(_buf));
}
