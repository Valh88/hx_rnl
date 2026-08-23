package rnl;

import haxe.io.Bytes;
import haxe.Int64;

class Native {
	public static inline function buf(size:Int):Bytes return Bytes.alloc(size);

	#if hl
	public static inline function data(b:Bytes):hl.Bytes return b.getData();
	public static inline function charData(b:Bytes):hl.Bytes return b.getData();
	public static inline function i64ToPtr(lo:Int, hi:Int):hl.Bytes
		return rnl.raw.Raw.ptrFromI64(lo, hi);
	#elseif cpp
	public static inline function data(b:Bytes):cpp.Star<cpp.Void>
		return untyped __cpp__('(void*){0}->b->GetBase()', b);
	public static inline function charData(b:Bytes):rnl.raw.Types.CharPtr
		return untyped __cpp__('(void*){0}->b->GetBase()', b);
	public static inline function i64ToPtr(lo:Int, hi:Int):cpp.Star<cpp.Void>
		return untyped __cpp__('(void*)(uintptr_t)((uint64_t)(uint32_t){1} << 32 | (uint32_t){0})', lo, hi);
	#end

	public static inline function mkI64(lo:Int, hi:Int):Int64 return Int64.make(hi, lo);
	public static inline function lo(v:Int64):Int return v.low;
	public static inline function hi(v:Int64):Int return v.high;

	public static inline function getU16(b:Bytes, o:Int):Int return b.get(o) | (b.get(o+1) << 8);

	public static inline function getI64(b:Bytes, o:Int):Int64 {
		var l = b.get(o) | (b.get(o+1) << 8) | (b.get(o+2) << 16) | (b.get(o+3) << 24);
		var h = b.get(o+4) | (b.get(o+5) << 8) | (b.get(o+6) << 16) | (b.get(o+7) << 24);
		return Int64.make(h, l);
	}

	public static inline function setI64(b:Bytes, o:Int, v:Int64):Void {
		var l = Int64.getLow(v); var h = Int64.getHigh(v);
		b.set(o, l & 0xFF); b.set(o+1, (l>>8)&0xFF);
		b.set(o+2, (l>>16)&0xFF); b.set(o+3, (l>>24)&0xFF);
		b.set(o+4, h & 0xFF); b.set(o+5, (h>>8)&0xFF);
		b.set(o+6, (h>>16)&0xFF); b.set(o+7, (h>>24)&0xFF);
	}
}
