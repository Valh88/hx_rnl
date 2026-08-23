package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;

class Channel extends HandleWrapper {
	public function new(buf:Bytes) {
		super();
		_lo = buf.getInt32(0);
		_hi = buf.getInt32(4);
	}
	public function send(data:Bytes, flags:Int = 0):Void {
		RnlError.check(Raw.RNL_channel_send_message_data(h(), Native.data(data), data.length, flags));
	}
	public function sendString(s:String, flags:Int = 0):Void send(Bytes.ofString(s), flags);
	public var pendingOutgoing(get,never):Int;
	function get_pendingOutgoing():Int return Raw.RNL_channel_get_count_pending_outgoing(h());
	/** Largest payload that fits a single datagram on this channel. */
	public var maximumUnfragmented(get,never):Int;
	function get_maximumUnfragmented():Int return Raw.RNL_channel_get_maximum_unfragmented_message_size(h());
	/** Window-bound total message size (reliable channels). */
	public var maximumMessage(get,never):Int;
	function get_maximumMessage():Int return Raw.RNL_channel_get_maximum_message_size(h());
}
