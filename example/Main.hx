import rnl.raw.Raw;
import rnl.internal.RnlBuild;

@:headerCode('#include "/run/media/vano/9C33-6BBD/projects/pascal/rnl/lib/rnl.h"')
@:buildXml('<files id="haxe"></files>
<target id="haxe">
	<libpath name="/run/media/vano/9C33-6BBD/projects/pascal/rnl/hx_rnl/ndll/Linux64" />
	<lib name="-lrnl" />
</target>')
class Main {
	public static function main() {
		var v = Raw.RNL_protocol_version();
		trace('RNL protocol version: ${v.high}.${(v.low >> 16) & 0xFFFF}.${v.low & 0xFFFF}');
		trace('OK');
	}
}
