package rnl;

import haxe.io.Bytes;
import rnl.raw.Raw;

enum abstract CompressionAlgorithm(Int) {
	var Deflate;
	var Lzbrrc;
	var Brrc;
}

/** Stream compressor/decompressor (Deflate / LZBRRC / BRRC). */
@:headerCode('#include "rnl.h"')
class Compressor {
	var _lo:Int;
	var _hi:Int;
	var _alive:Bool;
	public var algorithm(default,null):CompressionAlgorithm;

	public function new(algorithm:CompressionAlgorithm = Deflate) {
		this.algorithm = algorithm;
		_alive = false;
		var buf = Bytes.alloc(8);
		var status = switch (algorithm) {
			case Deflate: Raw.RNL_compressor_create_deflate(Native.data(buf));
			case Lzbrrc:  Raw.RNL_compressor_create_lzbrrc(Native.data(buf));
			case Brrc:    Raw.RNL_compressor_create_brrc(Native.data(buf));
		};
		RnlError.check(status, 'Compressor.create');
		_lo = buf.getInt32(0);
		_hi = buf.getInt32(4);
		_alive = true;
	}

	#if cpp
	inline function h():cpp.Star<cpp.Void> return Native.i64ToPtr(_lo, _hi);
	#else
	inline function h():Dynamic return Native.i64ToPtr(_lo, _hi);
	#end

	/** Compress data; returns compressed bytes. */
	public function compress(data:Bytes):Bytes {
		var outLimit = data.length + 256;
		var out = Bytes.alloc(outLimit);
		var outSize = Bytes.alloc(8);
		RnlError.check(Raw.RNL_compressor_compress(h(),
			Native.data(data), data.length,
			Native.data(out), outLimit, Native.data(outSize)), "Compressor.compress");
		return out.sub(0, outSize.getInt32(0));
	}

	/** Decompress previously compressed data. */
	public function decompress(data:Bytes, ?expectedSize:Int):Bytes {
		var limit = expectedSize != null ? expectedSize : data.length * 8 + 1024;
		var out = Bytes.alloc(limit);
		var outSize = Bytes.alloc(8);
		RnlError.check(Raw.RNL_compressor_decompress(h(),
			Native.data(data), data.length,
			Native.data(out), limit, Native.data(outSize)), "Compressor.decompress");
		return out.sub(0, outSize.getInt32(0));
	}

	public var deflateWithHeader(get,set):Bool;
	function get_deflateWithHeader():Bool return Raw.RNL_compressor_deflate_get_with_header(h()) != 0;
	function set_deflateWithHeader(v:Bool):Bool { Raw.RNL_compressor_deflate_set_with_header(h(), v?1:0); return v; }
	public var deflateGreedy(get,set):Bool;
	function get_deflateGreedy():Bool return Raw.RNL_compressor_deflate_get_greedy(h()) != 0;
	function set_deflateGreedy(v:Bool):Bool { Raw.RNL_compressor_deflate_set_greedy(h(), v?1:0); return v; }

	public function dispose():Void {
		if (_alive) { Raw.RNL_compressor_destroy(h()); _alive = false; }
	}
}
