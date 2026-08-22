package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;

class Address {
	var _buf:Bytes;
	public function new() { _buf = Bytes.alloc(22); }
	public static function parse(s:String):Address {
		var a = new Address();
		var sb = Bytes.ofString(s);
		RnlError.check(Raw.RNL_address_from_string(sb, sb.length, a._buf), 'Address.parse');
		return a;
	}
	public var port(get,set):Int;
	function get_port():Int return _buf.getUInt16(20);
	function set_port(v:Int):Int { _buf.setUInt16(20,v); return v; }
	public var family(get,never):Int;
	function get_family():Int return Raw.RNL_address_get_family(_buf);
	public function toString():String {
		var buf = Bytes.alloc(64);
		Raw.RNL_address_to_string(_buf, buf, 64);
		var len = 0;
		while (len < 63 && buf.get(len) != 0) len++;
		return buf.getString(0, len);
	}
	public inline function native():Dynamic return Native.data(_buf);
}
