package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;

@:headerCode('#include "rnl.h"')
class Address {
	var _buf:Bytes;
	public function new() { _buf = Bytes.alloc(22); }
	public static function parse(s:String):Address {
		var a = new Address();
		var sb = Bytes.ofString(s);
		RnlError.check(Raw.RNL_address_from_string(Native.charData(sb), sb.length, Native.data(a._buf)), 'Address.parse');
		return a;
	}
	public var port(get,set):Int;
	function get_port():Int return _buf.getUInt16(20);
	function set_port(v:Int):Int { _buf.setUInt16(20,v); return v; }
	public var family(get,never):Int;
	function get_family():Int {
		#if cpp
		return untyped __cpp__('RNL_address_get_family(*(struct rnl_address*){0}->b->GetBase())', _buf);
		#else
		return Raw.RNL_address_get_family(Native.data(_buf));
		#end
	}
	public function toString():String {
		var buf = Bytes.alloc(64);
		#if cpp
		untyped __cpp__('RNL_address_to_string(*(struct rnl_address*){0}->b->GetBase(),(char*){1}->b->GetBase(),64)', _buf, buf);
		#else
		Raw.RNL_address_to_string(Native.data(_buf), Native.charData(buf), 64);
		#end
		var len = 0;
		while (len < 63 && buf.get(len) != 0) len++;
		return buf.getString(0, len);
	}
	#if cpp
	public inline function native():cpp.Star<cpp.Void> return Native.data(_buf);
	#else
	public inline function native():Dynamic return Native.data(_buf);
	#end
}
