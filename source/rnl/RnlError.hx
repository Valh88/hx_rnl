package rnl;

class RnlError extends haxe.Exception {
	public final code:Int;
	public function new(code:Int, ?msg:String, ?p:haxe.PosInfos) {
		super(msg != null ? msg : 'RNL error $code', p);
		this.code = code;
	}
	public static inline var OK = 0;
	public static inline var INVALID_ARGUMENT = -1;
	public static inline var INVALID_HANDLE = -3;
	public static inline var NOT_FOUND = -5;
	public static inline var EXCEPTION = -7;
	public static inline function check(status:Int, ?ctx:String):Int {
		if (status != OK)
			throw new RnlError(status, ctx != null ? '$ctx: error $status' : null);
		return status;
	}
}
