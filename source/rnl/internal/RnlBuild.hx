package rnl.internal;

/**
 * Non-extern build config. Import this from your Main class so hxcpp:
 *  1. Includes rnl.h (via @:headerCode) for function declarations
 *  2. Links against librnl.so / RNL.dll (via @:buildXml)
 */
@:headerCode('#include "rnl.h"')
@:buildXml('<files id="haxe">
		<compilerflag value="-I/run/media/vano/9C33-6BBD/projects/pascal/rnl/lib" />
		<compilerflag value="-include/run/media/vano/9C33-6BBD/projects/pascal/rnl/lib/rnl.h" />
		<compilerflag value="-fpermissive" />
	</files>
	<target id="haxe">
		<libpath name="/home/vano/.haxe_lib/hxrnl/ndll/Linux64" if="linux" />
		<lib name="-lrnl" if="linux" />
		<libpath name="${HAXE_LIBS}/hxrnl/ndll/win64" if="windows" />
		<lib name="-lRNL" if="windows" />
		<libpath name="${HAXE_LIBS}/hxrnl/ndll/android-arm64" if="android && HXCPP_ARM64" />
		<lib name="-lrnl" if="android && HXCPP_ARM64" />
		<libpath name="${HAXE_LIBS}/hxrnl/ndll/android-arm" if="android && HXCPP_ARMV7" />
		<lib name="-lrnl" if="android && HXCPP_ARMV7" />
	</target>')
class RnlBuild {}
