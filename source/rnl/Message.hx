package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;

class Message {
	var _buf:Bytes;
	public function new(host:Host, buf:Bytes, offset:Int) {
		var ps = rnl.raw.Types.PTR_BYTES;
		_buf = Bytes.alloc(ps);
		_buf.blit(0, buf, offset, ps);
	}
	public static function fromData(data:Bytes):Message {
		var m = new Message(null, null, 0);
		m._buf = Bytes.alloc(rnl.raw.Types.PTR_BYTES);
		RnlError.check(Raw.RNL_message_create(Native.data(data), data.length, 0, m._buf));
		return m;
	}
	public var length(get,never):Int;
	function get_length():Int return _buf != null ? Raw.RNL_message_data_length(Native.data(_buf)) : 0;
	public function dispose():Void {
		if (_buf != null) { Raw.RNL_message_dec_ref(Native.data(_buf)); _buf = null; }
	}
	public inline function native():Dynamic return _buf;
}
