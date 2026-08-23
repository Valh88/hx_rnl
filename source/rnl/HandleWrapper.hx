package rnl;

import haxe.io.Bytes;
import rnl.raw.Raw;

/**
 * Base for all native handle wrappers.
 * Stores handle as lo/hi int pair, provides h() for native access.
 */
class HandleWrapper
{
	var _lo:Int;
	var _hi:Int;

	public var disposed(default, null):Bool = false;

	function new()
	{
		_lo = 0;
		_hi = 0;
	}

	/** Call AFTER the create function wrote handle into outBuf */
	inline function readHandle(outBuf:Bytes):Void
	{
		_lo = outBuf.getInt32(0);
		_hi = outBuf.getInt32(4);
	}

	public function dispose():Void
	{
		disposed = true;
	}

	/** Get native pointer for this handle */
	#if cpp
	public inline function h():cpp.Star<cpp.Void>
	{
		return Native.i64ToPtr(_lo, _hi);
	}
	#else
	public inline function h():Dynamic
	{
		return Native.i64ToPtr(_lo, _hi);
	}
	#end
}
