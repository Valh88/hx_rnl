package rnl.internal;

/**
 * Non-extern build config. Import this from your Main class so hxcpp:
 *  1. Includes rnl.h (via @:headerCode) for function declarations
 *  2. Links against librnl.so / RNL.dll (via @:buildXml)
 */
@:headerCode('#include "rnl.h"')
@:buildXml('<files id="haxe">
		<compilerflag value="-I${HAXE_LIBS}/hxrnl/../lib" />
	</files>
	<target id="haxe">
		<libpath name="${HAXE_LIBS}/hxrnl/ndll/Linux64" if="linux" />
		<lib name="rnl" if="linux" />
		<libpath name="${HAXE_LIBS}/hxrnl/ndll/Windows64" if="windows" />
		<lib name="RNL" if="windows" />
		<libpath name="${HAXE_LIBS}/hxrnl/ndll/android-arm64" if="android" if="HXCPP_ARM64" />
		<lib name="rnl" if="android" if="HXCPP_ARM64" />
		<libpath name="${HAXE_LIBS}/hxrnl/ndll/android-arm" if="android" if="HXCPP_ARMV7" />
		<lib name="rnl" if="android" if="HXCPP_ARMV7" />
	</target>')
class RnlBuild {}
