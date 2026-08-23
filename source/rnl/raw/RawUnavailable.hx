package rnl.raw;

/** Thrown by the stub backend on platforms without shipped binaries yet
 *  (macOS / iOS). code mirrors RNL_ERR_UNSUPPORTED. */
class RawUnavailable extends haxe.Exception
{
	public final code:Int;

	public function new(what:String, ?p:haxe.PosInfos)
	{
		super('RNL native library is not available on this platform yet (' + what + ')', p);
		code = -6;
	}
}
