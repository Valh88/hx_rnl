package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;
import rnl.Enums.TranscriptBinding;

class Peer extends HandleWrapper {
	public function new(host:Host, buf:Bytes, offset:Int = 0) {
		super();
		var ps = rnl.raw.Types.PTR_BYTES;
		_lo = buf.getInt32(offset);
		_hi = buf.getInt32(offset + 4);
	}
	override public function dispose():Void {
		if (!disposed) { disposed = true; }
		super.dispose();
	}
	public function incRef():Void Raw.RNL_peer_inc_ref(h());
	public function decRef():Void Raw.RNL_peer_dec_ref(h());
	/** Graceful disconnect; data is delivered to the remote PeerDisconnect event. */
	public function disconnect(?data:haxe.Int64, delayed:Bool = false):Void {
		if (data == null) data = haxe.Int64.ofInt(0);
		Raw.RNL_peer_disconnect(h(), data, delayed ? 1 : 0);
	}
	public var localPeerId(get,never):Int;
	function get_localPeerId():Int return Raw.RNL_peer_get_local_peer_id(h());
	public var remotePeerId(get,never):Int;
	function get_remotePeerId():Int return Raw.RNL_peer_get_remote_peer_id(h());
	public var mtu(get,never):Int;
	function get_mtu():Int return Raw.RNL_peer_get_mtu(h());
	public var minRtt(get,never):Int;
	function get_minRtt():Int return Raw.RNL_peer_get_minimum_round_trip_time(h());
	public var countChannels(get,set):Int;
	function get_countChannels():Int return Raw.RNL_peer_get_count_channels(h());
	function set_countChannels(v:Int):Int { Raw.RNL_peer_set_count_channels(h(),v); return v; }
	public function getChannel(i:Int):Null<Channel> {
		var cb = Bytes.alloc(rnl.raw.Types.PTR_BYTES);
		return Raw.RNL_peer_get_channel(h(), i, Native.data(cb)) == 0 ? new Channel(cb) : null;
	}

	// ---- telemetry & configuration (RNL_peer_get_*/set_*) ----
	public var bandwidthWeight(get,set):Int;
	function get_bandwidthWeight():Int return Raw.RNL_peer_get_bandwidth_weight(h());
	function set_bandwidthWeight(v:Int):Int { Raw.RNL_peer_set_bandwidth_weight(h(), v); return v; }
	public var congestionControlRate(get,never):Int;
	function get_congestionControlRate():Int return Raw.RNL_peer_get_congestion_control_rate(h());
	public var countCongestionControlRuns(get,never):Int;
	function get_countCongestionControlRuns():Int return Raw.RNL_peer_get_count_congestion_control_runs(h());
	public var countKeepAlivePingResends(get,never):Int;
	function get_countKeepAlivePingResends():Int return Raw.RNL_peer_get_count_keep_alive_ping_resends(h());
	public var countLastFlightLostPackets(get,never):Int;
	function get_countLastFlightLostPackets():Int return Raw.RNL_peer_get_count_last_flight_lost_packets(h());
	public var countLastFlightResolvedPackets(get,never):Int;
	function get_countLastFlightResolvedPackets():Int return Raw.RNL_peer_get_count_last_flight_resolved_packets(h());
	public var countPacketLoss(get,never):Int;
	function get_countPacketLoss():Int return Raw.RNL_peer_get_count_packet_loss(h());
	public var deliveryRate(get,never):Int;
	function get_deliveryRate():Int return Raw.RNL_peer_get_delivery_rate(h());
	public var hasRemoteCertificate(get,never):Int;
	function get_hasRemoteCertificate():Int return Raw.RNL_peer_get_has_remote_certificate(h());
	public var incomingBandwidthRate(get,never):Int;
	function get_incomingBandwidthRate():Int return Raw.RNL_peer_get_incoming_bandwidth_rate(h());
	public var maximumDeliveryRate(get,never):Int;
	function get_maximumDeliveryRate():Int return Raw.RNL_peer_get_maximum_delivery_rate(h());
	public var outgoingBandwidthRate(get,never):Int;
	function get_outgoingBandwidthRate():Int return Raw.RNL_peer_get_outgoing_bandwidth_rate(h());
	public var outgoingBandwidthShare(get,never):Int;
	function get_outgoingBandwidthShare():Int return Raw.RNL_peer_get_outgoing_bandwidth_share(h());
	public var queueDepth(get,never):Int;
	function get_queueDepth():Int return Raw.RNL_peer_get_queue_depth(h());
	public var queueingDelay(get,never):Int;
	function get_queueingDelay():Int return Raw.RNL_peer_get_queueing_delay(h());
	public var remoteHostSalt(get,set):haxe.Int64;
	function get_remoteHostSalt():haxe.Int64 return Raw.RNL_peer_get_remote_host_salt(h());
	function set_remoteHostSalt(v:haxe.Int64):haxe.Int64 { Raw.RNL_peer_set_remote_host_salt(h(), v); return v; }
	public var remoteIncomingBandwidthLimit(get,never):Int;
	function get_remoteIncomingBandwidthLimit():Int return Raw.RNL_peer_get_remote_incoming_bandwidth_limit(h());
	public var remoteOutgoingBandwidthLimit(get,never):Int;
	function get_remoteOutgoingBandwidthLimit():Int return Raw.RNL_peer_get_remote_outgoing_bandwidth_limit(h());
	public var transcriptBinding(get,never):TranscriptBinding;
	function get_transcriptBinding():TranscriptBinding return cast Raw.RNL_peer_get_transcript_binding(h());
}
