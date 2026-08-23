package rnl;

import haxe.io.Bytes;
import rnl.raw.Raw;

/**
 * Base for all native handle wrappers.
 * Stores handle as lo/hi int pair, provides h() for native access.
 */
class HandleWrapper {
	var _lo:Int;
	var _hi:Int;
	public var disposed(default,null):Bool = false;

	function new() { _lo = 0; _hi = 0; }

	/** Call AFTER the create function wrote handle into outBuf */
	inline function readHandle(outBuf:Bytes):Void {
		_lo = outBuf.getInt32(0);
		_hi = outBuf.getInt32(4);
	}

	public function dispose():Void { disposed = true; }

	/** Get native pointer for this handle */
	public inline function h():Dynamic {
		return rnl.raw.Raw.ptrFromI64(_lo, _hi);
	}
}
