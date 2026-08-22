package rnl;

/** Exception thrown when a native RNL call returns an error status. */
class RnlError extends haxe.Exception {
	public final code:Int;

	public function new(code:Int, ?msg:String, ?p:haxe.PosInfos) {
		super(msg != null ? msg : 'RNL error $code', p);
		this.code = code;
	}

	public static inline var OK:Int = 0;
	public static inline var INVALID_ARGUMENT:Int = -1;
	public static inline var OUT_OF_MEMORY:Int = -2;
	public static inline var INVALID_HANDLE:Int = -3;
	public static inline var BUFFER_TOO_SMALL:Int = -4;
	public static inline var NOT_FOUND:Int = -5;
	public static inline var UNSUPPORTED:Int = -6;
	public static inline var EXCEPTION:Int = -7;
	public static inline var COMPRESSION_FAILED:Int = -8;
	public static inline var AUTHENTICATION_FAILED:Int = -9;

	/** Check status, throw RnlError if != OK */
	public static inline function check(status:Int, ?context:String):Int {
		if (status != OK)
			throw new RnlError(status, context != null ? '$context: error $status' : null);
		return status;
	}
}
