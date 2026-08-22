package rnl.raw;

/** Platform pointer types used by the raw bindings. */

#if cpp
typedef Ptr = cpp.Star<cpp.Void>;
typedef CharPtr = cpp.ConstCharStar;
#elseif hl
typedef Ptr = hl.Bytes;
typedef CharPtr = hl.Bytes;
#else
typedef Ptr = Dynamic;
typedef CharPtr = Dynamic;
#end

/** Size of a native pointer in bytes (for packed struct layout). */
#if (hl || HXCPP_M64 || x64)
inline var PTR_BYTES:Int = 8;
#else
inline var PTR_BYTES:Int = 4;
#end
