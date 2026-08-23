package rnl;

import haxe.io.Bytes;
import rnl.raw.Raw;

typedef DiscoveredService =
{
	address:Address,
	version:Int,
	meta:String,
};

/**
 * LAN service discovery client — one-shot browse.
 * Sends a multicast request and collects responses from listening servers.
 */
@:headerCode('#include "rnl.h"')
class DiscoveryClient
{
	/**
		Discover servers on the LAN advertising `serviceId` (16 bytes).
		Returns up to maxServers entries within timeoutMs.
	**/
	public static function discover(inst:Instance, net:Network, port:Int, serviceId:Bytes, serviceVersion:Int, ?meta:Bytes, maxServers:Int = 8,
			timeoutMs:Int = 1000):Array<DiscoveredService>
	{
		if (meta == null)
			meta = Bytes.alloc(0);

		var mcastV4 = new Address();
		mcastV4.setBytes(224, 0, 0, 251); // 224.0.0.251 standard mDNS-like

		// each entry is 22(addr) + 4(version) + 1(meta_len) + 255(meta) = 282 bytes packed
		var entrySize = 282;
		var outBuf = Bytes.alloc(entrySize * maxServers);
		var count = Bytes.alloc(8);
		var sidBuf = Bytes.alloc(16);
		sidBuf.blit(0, serviceId, 0, Math.min(16, serviceId.length));

		Raw.RNL_discovery_client_discover(inst.native(), net.native(), port, Native.data(mcastV4.native()), null, // no v6 multicast for now
			Native.data(sidBuf), serviceVersion, meta.length > 0 ? Native.data(meta) : null, meta.length, maxServers, timeoutMs, Native.data(outBuf),
			maxServers, Native.data(count));

		var n = count.getInt32(0);
		var results:Array<DiscoveredService> = [];
		for (i in 0...n)
		{
			var base = i * entrySize;
			if (base + entrySize > outBuf.length)
				break;
			var addr = new Address();
			addr.copyFrom(outBuf, base);
			var ver = outBuf.getInt32(base + 22);
			var metaLen = outBuf.get(base + 26);
			var metaStr = metaLen > 0 ? outBuf.getString(base + 27, metaLen) : "";
			results.push({address: addr, version: ver, meta: metaStr});
		}
		return results;
	}
}

/**
 * LAN service discovery server.
 * Advertises a service on the local network and responds to browse requests.
 *
 * NOTE: the accept callback requires C function pointer support which is not
 * yet wired through the FFI layer; all incoming requests are accepted by default.
 * Use setMeta() to update advertised metadata while running.
 */
@:headerCode('#include "rnl.h"')
class DiscoveryServer
{
	var _buf:Bytes;

	public var disposed(default, null):Bool = false;

	function lo():Int
		return _buf != null ? _buf.getInt32(0) : 0;

	function hi():Int
		return _buf != null ? _buf.getInt32(4) : 0;

	inline function h():Dynamic
		return Native.i64ToPtr(lo(), hi());

	/**
		Start advertising on the given port with a 16-byte service ID.
		The host will respond to browse requests automatically.
	**/
	public function new(inst:Instance, net:Network, port:Int, serviceId:Bytes, serviceVersion:Int, ?meta:Bytes)
	{
		if (meta == null)
			meta = Bytes.alloc(0);
		var sidBuf = Bytes.alloc(16);
		sidBuf.blit(0, serviceId, 0, Math.min(16, serviceId.length));
		_buf = Bytes.alloc(8);

		// accept_cb = NULL means "accept all" in the current binding layer
		var status = Raw.RNL_discovery_server_create(inst.native(), net.native(), port, Native.data(sidBuf), serviceVersion, null,
			null, // no explicit service addresses
			0, // flags
			null, null, // callback + user_data
			meta.length > 0 ? Native.data(meta) : null, meta.length,
			Native.data(_buf));
		RnlError.check(status, "DiscoveryServer.create");
	}

	public var port(get, never):Int;

	function get_port():Int
		return Raw.RNL_discovery_server_get_port(h());

	/** Hot-update advertised metadata without restarting the server. */
	public function setMeta(data:Bytes):Void
		Raw.RNL_discovery_server_set_meta(h(), data.length > 0 ? Native.data(data) : null, data.length);

	public function shutdown():Void
		Raw.RNL_discovery_server_shutdown(h());

	public function dispose():Void
	{
		if (!disposed && _buf != null)
		{
			Raw.RNL_discovery_server_destroy(h());
			_buf = null;
			disposed = true;
		}
	}
}
