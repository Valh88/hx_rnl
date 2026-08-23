package rnl;

import haxe.io.Bytes;
import rnl.raw.Raw;
import rnl.Enums.EventType;

/**
 * STUN query helper over the host's built-in STUN client.
 * Uses RNL_host_begin_stun_query + RNL_host_take_stun_result,
 * which take struct-by-pointer (safe on all targets).
 *
 * Typical usage:
 *   host.beginStunQuery(serverAddr);       // queue query
 *   while (!host.hasStunResult()) service(); // pump
 *   var result = host.takeStunResult();     // mapped address + RTT
 */
@:headerCode('#include "rnl.h"')
class Stun
{
	/** Queue a STUN binding request through the given socket slot. */
	public static function beginQuery(host:Host, serverAddr:Address, socketIndex:Int = 0):Bool
	{
		var ok = Bytes.alloc(4);
		var status = Raw.RNL_host_begin_stun_query(host.h(), serverAddr.native(), socketIndex, Native.data(ok));
		return status == 0 && ok.getInt32(0) != 0;
	}

	/** Number of queries still in flight. */
	public static function pendingCount(host:Host):Int
		return Raw.RNL_host_count_pending_stun_queries(host.h());

	/**
		Non-blocking poll for completed results.
		Returns null if none ready yet.
	**/
	public static function takeResult(host:Host):Null<{mappedAddress:Address, rttMs:haxe.Int64}>
	{
		var success = Bytes.alloc(4);
		var sockIdx = Bytes.alloc(8);
		var server = new Address();
		var mapped = new Address();
		var rtt = Bytes.alloc(8);
		var have = Bytes.alloc(4);

		Raw.RNL_host_take_stun_result(host.h(), Native.data(success), Native.data(sockIdx), Native.data(server.native()), Native.data(mapped.native()),
			Native.data(rtt), Native.data(have));

		if (have.getInt32(0) == 0 || success.getInt32(0) == 0)
			return null;
		return {mappedAddress: mapped, rttMs: Native.getI64(rtt, 0)};
	}
}

/** NAT traversal prediction based on mapping behaviours. */
@:headerCode('#include "rnl.h"')
class NatPredict
{
	public static inline var VIABILITY_DIRECT = 0;
	public static inline var VIABILITY_P2P_POSSIBLE = 1;
	public static inline var VIABILITY_NEEDS_RELAY = 2;

	/** Predict whether hole punching will work given both sides' mapping behaviours. */
	public static function holePunchingViability(localMapping:Int, remoteMapping:Int):Int
		return Raw.RNL_nat_predict_hole_punching_viability(localMapping, remoteMapping);
}
