package rnl.internal;

/**
 * Non-extern build config. Import this from your Main class so hxcpp:
 *  1. Includes rnl.h (via @:headerCode) for function declarations
 *  2. Links against librnl.so / RNL.dll (via @:buildXml)
 *
 * All paths resolve through ${haxelib:hxrnl} — hxcpp asks haxelib for the
 * package root, so this works both for `haxelib dev hxrnl .` checkouts and
 * installed packages, on any machine. Requirement: the library must be
 * registered with haxelib.
 */
@:headerCode('#include "rnl.h"')
@:buildXml('<files id="haxe">
		<compilerflag value="-I${haxelib:hxrnl}/include" />
		<compilerflag value="-fpermissive" />
	</files>
	<target id="haxe">
		<libpath name="${haxelib:hxrnl}/ndll/Linux64" if="linux" />
		<lib name="-lrnl" if="linux" />
		<!-- find librnl.so next to the binary, or straight from the package -->
		<flag value="-Wl,-rpath,$ORIGIN" if="linux" />
		<flag value="-Wl,-rpath,${haxelib:hxrnl}/ndll/Linux64" if="linux" />
		<libpath name="${haxelib:hxrnl}/ndll/win64" if="windows" />
		<lib name="-lRNL" if="windows" />
		<libpath name="${haxelib:hxrnl}/ndll/android-arm64" if="android && HXCPP_ARM64" />
		<lib name="-lrnl" if="android && HXCPP_ARM64" />
		<libpath name="${haxelib:hxrnl}/ndll/android-arm" if="android && HXCPP_ARMV7" />
		<lib name="-lrnl" if="android && HXCPP_ARMV7" />
	</target>
	<!-- ship the runtime library into the build output automatically -->
	<copyFile name="librnl.so" from="${haxelib:hxrnl}/ndll/Linux64" if="linux" />
	<copyFile name="RNL.dll" from="${haxelib:hxrnl}/ndll/win64" if="windows" />')
class RnlBuild {}
