package rnl;
import haxe.io.Bytes;
import rnl.raw.Raw;
import rnl.Enums.WorkMode;
import rnl.Enums.ChannelType;
import rnl.Enums.CertVerdict;
import rnl.Enums.EventType;

class Host extends HandleWrapper {
	var _evBuf:Bytes;
	var _stBuf:Bytes;

	public function new(inst:Instance, network:Network) {
		super();
		_evBuf = Bytes.alloc(64);
		_stBuf = Bytes.alloc(4);
		var tmp = Bytes.alloc(8);
		RnlError.check(
			Raw.RNL_host_create(inst.native(), network.native(), Native.data(tmp)),
			"Host.create"
		);
		readHandle(tmp);
	}

	override public function dispose():Void {
		if (!disposed) { Raw.RNL_host_destroy(h()); disposed = true; }
		super.dispose();
	}

	public function setAddress(addr:Address):Void {
		RnlError.check(Raw.RNL_host_set_address(h(), addr.native()));
	}

	public function start(mode:WorkMode):Void {
		RnlError.check(Raw.RNL_host_start(h(), cast mode), "Host.start");
	}

	/** Configure delivery type of channel slot i (before peers connect). */
	public function setChannelType(i:Int, t:ChannelType):Void {
		RnlError.check(Raw.RNL_host_set_channel_type(h(), i, cast t), 'Host.setChannelType($i)');
	}
	public function getChannelType(i:Int):ChannelType {
		var out = Bytes.alloc(4);
		RnlError.check(Raw.RNL_host_get_channel_type(h(), i, Native.data(out)), 'Host.getChannelType($i)');
		return cast out.getInt32(0);
	}

	public function service(timeoutMs:Int):Null<RnlEvent> {
		var st = Bytes.alloc(4);
		Raw.RNL_host_service(h(), Native.data(_evBuf),
			haxe.Int64.ofInt(timeoutMs), Native.data(st));
		if (st.getInt32(0) == 3) return new RnlEvent(this, _evBuf);
		return null;
	}

	public function eventFree():Void Raw.RNL_host_event_free(h());

	public function connect(addr:Address, channels:Int = 1, ?data:Null<haxe.Int64>):Peer {
		if (data == null) data = haxe.Int64.ofInt(0);
		var pb = Bytes.alloc(8);
		var tok:Dynamic = null;
		RnlError.check(
			Raw.RNL_host_connect(h(), addr.native(), channels,
				data, tok, tok, tok, tok, Native.data(pb)),
			"Host.connect"
		);
		return new Peer(this, pb);
	}


	// ---- configuration & statistics (RNL_host_get_*/set_*) ----
	public var allowIncomingConnections(get,set):Bool;
	function get_allowIncomingConnections():Bool return Raw.RNL_host_get_allow_incoming_connections(h()) != 0;
	function set_allowIncomingConnections(v:Bool):Bool { Raw.RNL_host_set_allow_incoming_connections(h(), v?1:0); return v; }
	public var checkAuthenticationTokens(get,set):Bool;
	function get_checkAuthenticationTokens():Bool return Raw.RNL_host_get_check_authentication_tokens(h()) != 0;
	function set_checkAuthenticationTokens(v:Bool):Bool { Raw.RNL_host_set_check_authentication_tokens(h(), v?1:0); return v; }
	public var checkConnectionTokens(get,set):Bool;
	function get_checkConnectionTokens():Bool return Raw.RNL_host_get_check_connection_tokens(h()) != 0;
	function set_checkConnectionTokens(v:Bool):Bool { Raw.RNL_host_set_check_connection_tokens(h(), v?1:0); return v; }
	public var congestionControl(get,set):Bool;
	function get_congestionControl():Bool return Raw.RNL_host_get_congestion_control(h()) != 0;
	function set_congestionControl(v:Bool):Bool { Raw.RNL_host_set_congestion_control(h(), v?1:0); return v; }
	public var connectionAttemptsPerSecond(get,never):Int;
	function get_connectionAttemptsPerSecond():Int return Raw.RNL_host_get_connection_attempts_per_second(h());
	public var connectionChallengeDifficultyLevel(get,never):Int;
	function get_connectionChallengeDifficultyLevel():Int return Raw.RNL_host_get_connection_challenge_difficulty_level(h());
	public var countPeers(get,never):Int;
	function get_countPeers():Int return Raw.RNL_host_get_count_peers(h());
	public var countStunQueryAttempts(get,set):Int;
	function get_countStunQueryAttempts():Int return Raw.RNL_host_get_count_stun_query_attempts(h());
	function set_countStunQueryAttempts(v:Int):Int { Raw.RNL_host_set_count_stun_query_attempts(h(), v); return v; }
	public var currentTimeMinutes(get,set):Int;
	function get_currentTimeMinutes():Int return Raw.RNL_host_get_current_time_minutes(h());
	function set_currentTimeMinutes(v:Int):Int { Raw.RNL_host_set_current_time_minutes(h(), v); return v; }
	public var encryptedPacketSequenceWindowSize(get,set):Int;
	function get_encryptedPacketSequenceWindowSize():Int return Raw.RNL_host_get_encrypted_packet_sequence_window_size(h());
	function set_encryptedPacketSequenceWindowSize(v:Int):Int { Raw.RNL_host_set_encrypted_packet_sequence_window_size(h(), v); return v; }
	public var hasCertificate(get,never):Int;
	function get_hasCertificate():Int return Raw.RNL_host_get_has_certificate(h());
	public var incomingBandwidthLimit(get,set):Int;
	function get_incomingBandwidthLimit():Int return Raw.RNL_host_get_incoming_bandwidth_limit(h());
	function set_incomingBandwidthLimit(v:Int):Int { Raw.RNL_host_set_incoming_bandwidth_limit(h(), v); return v; }
	public var incomingBandwidthRate(get,never):Int;
	function get_incomingBandwidthRate():Int return Raw.RNL_host_get_incoming_bandwidth_rate(h());
	public var interruptible(get,set):Bool;
	function get_interruptible():Bool return Raw.RNL_host_get_interruptible(h()) != 0;
	function set_interruptible(v:Bool):Bool { Raw.RNL_host_set_interruptible(h(), v?1:0); return v; }
	public var keepAliveWindowSize(get,set):Int;
	function get_keepAliveWindowSize():Int return Raw.RNL_host_get_keep_alive_window_size(h());
	function set_keepAliveWindowSize(v:Int):Int { Raw.RNL_host_set_keep_alive_window_size(h(), v); return v; }
	public var lastCertificateVerdict(get,never):CertVerdict;
	function get_lastCertificateVerdict():CertVerdict return cast Raw.RNL_host_get_last_certificate_verdict(h());
	public var maximumCandidatesPerHandshakeRound(get,set):Int;
	function get_maximumCandidatesPerHandshakeRound():Int return Raw.RNL_host_get_maximum_candidates_per_handshake_round(h());
	function set_maximumCandidatesPerHandshakeRound(v:Int):Int { Raw.RNL_host_set_maximum_candidates_per_handshake_round(h(), v); return v; }
	public var maximumCountChannels(get,set):Int;
	function get_maximumCountChannels():Int return Raw.RNL_host_get_maximum_count_channels(h());
	function set_maximumCountChannels(v:Int):Int { Raw.RNL_host_set_maximum_count_channels(h(), v); return v; }
	public var maximumCountPeers(get,set):Int;
	function get_maximumCountPeers():Int return Raw.RNL_host_get_maximum_count_peers(h());
	function set_maximumCountPeers(v:Int):Int { Raw.RNL_host_set_maximum_count_peers(h(), v); return v; }
	public var maximumMessageSize(get,never):Int;
	function get_maximumMessageSize():Int return Raw.RNL_host_get_maximum_message_size(h());
	public var maximumOutgoingUnreliableMessageAge(get,set):Int;
	function get_maximumOutgoingUnreliableMessageAge():Int return Raw.RNL_host_get_maximum_outgoing_unreliable_message_age(h());
	function set_maximumOutgoingUnreliableMessageAge(v:Int):Int { Raw.RNL_host_set_maximum_outgoing_unreliable_message_age(h(), v); return v; }
	public var maximumReliableBlockPacketSendAttempts(get,set):Int;
	function get_maximumReliableBlockPacketSendAttempts():Int return Raw.RNL_host_get_maximum_reliable_block_packet_send_attempts(h());
	function set_maximumReliableBlockPacketSendAttempts(v:Int):Int { Raw.RNL_host_set_maximum_reliable_block_packet_send_attempts(h(), v); return v; }
	public var maximumRetransmissionTimeout(get,set):haxe.Int64;
	function get_maximumRetransmissionTimeout():haxe.Int64 return Raw.RNL_host_get_maximum_retransmission_timeout(h());
	function set_maximumRetransmissionTimeout(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_maximum_retransmission_timeout(h(), v); return v; }
	public var maximumRetransmissionTimeoutLimit(get,set):haxe.Int64;
	function get_maximumRetransmissionTimeoutLimit():haxe.Int64 return Raw.RNL_host_get_maximum_retransmission_timeout_limit(h());
	function set_maximumRetransmissionTimeoutLimit(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_maximum_retransmission_timeout_limit(h(), v); return v; }
	public var maximumUnreliableBlockPacketsPerDispatch(get,set):Int;
	function get_maximumUnreliableBlockPacketsPerDispatch():Int return Raw.RNL_host_get_maximum_unreliable_block_packets_per_dispatch(h());
	function set_maximumUnreliableBlockPacketsPerDispatch(v:Int):Int { Raw.RNL_host_set_maximum_unreliable_block_packets_per_dispatch(h(), v); return v; }
	public var minimumRetransmissionTimeout(get,set):haxe.Int64;
	function get_minimumRetransmissionTimeout():haxe.Int64 return Raw.RNL_host_get_minimum_retransmission_timeout(h());
	function set_minimumRetransmissionTimeout(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_minimum_retransmission_timeout(h(), v); return v; }
	public var minimumRetransmissionTimeoutLimit(get,set):haxe.Int64;
	function get_minimumRetransmissionTimeoutLimit():haxe.Int64 return Raw.RNL_host_get_minimum_retransmission_timeout_limit(h());
	function set_minimumRetransmissionTimeoutLimit(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_minimum_retransmission_timeout_limit(h(), v); return v; }
	public var mtuDoFragment(get,set):Bool;
	function get_mtuDoFragment():Bool return Raw.RNL_host_get_mtu_do_fragment(h()) != 0;
	function set_mtuDoFragment(v:Bool):Bool { Raw.RNL_host_set_mtu_do_fragment(h(), v?1:0); return v; }
	public var outgoingBandwidthLimit(get,set):Int;
	function get_outgoingBandwidthLimit():Int return Raw.RNL_host_get_outgoing_bandwidth_limit(h());
	function set_outgoingBandwidthLimit(v:Int):Int { Raw.RNL_host_set_outgoing_bandwidth_limit(h(), v); return v; }
	public var outgoingBandwidthRate(get,never):Int;
	function get_outgoingBandwidthRate():Int return Raw.RNL_host_get_outgoing_bandwidth_rate(h());
	public var pendingConnectionChallengeTimeout(get,set):haxe.Int64;
	function get_pendingConnectionChallengeTimeout():haxe.Int64 return Raw.RNL_host_get_pending_connection_challenge_timeout(h());
	function set_pendingConnectionChallengeTimeout(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_pending_connection_challenge_timeout(h(), v); return v; }
	public var pendingConnectionNonceTimeout(get,set):haxe.Int64;
	function get_pendingConnectionNonceTimeout():haxe.Int64 return Raw.RNL_host_get_pending_connection_nonce_timeout(h());
	function set_pendingConnectionNonceTimeout(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_pending_connection_nonce_timeout(h(), v); return v; }
	public var pendingConnectionProtocolFallbackTimeout(get,set):haxe.Int64;
	function get_pendingConnectionProtocolFallbackTimeout():haxe.Int64 return Raw.RNL_host_get_pending_connection_protocol_fallback_timeout(h());
	function set_pendingConnectionProtocolFallbackTimeout(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_pending_connection_protocol_fallback_timeout(h(), v); return v; }
	public var pendingConnectionSaltTimeout(get,set):haxe.Int64;
	function get_pendingConnectionSaltTimeout():haxe.Int64 return Raw.RNL_host_get_pending_connection_salt_timeout(h());
	function set_pendingConnectionSaltTimeout(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_pending_connection_salt_timeout(h(), v); return v; }
	public var pendingConnectionSendTimeout(get,set):haxe.Int64;
	function get_pendingConnectionSendTimeout():haxe.Int64 return Raw.RNL_host_get_pending_connection_send_timeout(h());
	function set_pendingConnectionSendTimeout(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_pending_connection_send_timeout(h(), v); return v; }
	public var pendingConnectionShortTermKeyPairTimeout(get,set):haxe.Int64;
	function get_pendingConnectionShortTermKeyPairTimeout():haxe.Int64 return Raw.RNL_host_get_pending_connection_short_term_key_pair_timeout(h());
	function set_pendingConnectionShortTermKeyPairTimeout(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_pending_connection_short_term_key_pair_timeout(h(), v); return v; }
	public var pendingConnectionTimeout(get,set):haxe.Int64;
	function get_pendingConnectionTimeout():haxe.Int64 return Raw.RNL_host_get_pending_connection_timeout(h());
	function set_pendingConnectionTimeout(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_pending_connection_timeout(h(), v); return v; }
	public var pendingDisconnectionSendTimeout(get,set):haxe.Int64;
	function get_pendingDisconnectionSendTimeout():haxe.Int64 return Raw.RNL_host_get_pending_disconnection_send_timeout(h());
	function set_pendingDisconnectionSendTimeout(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_pending_disconnection_send_timeout(h(), v); return v; }
	public var pendingDisconnectionTimeout(get,set):haxe.Int64;
	function get_pendingDisconnectionTimeout():haxe.Int64 return Raw.RNL_host_get_pending_disconnection_timeout(h());
	function set_pendingDisconnectionTimeout(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_pending_disconnection_timeout(h(), v); return v; }
	public var protocolId(get,set):haxe.Int64;
	function get_protocolId():haxe.Int64 return Raw.RNL_host_get_protocol_id(h());
	function set_protocolId(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_protocol_id(h(), v); return v; }
	public var rateLimiterHostAddressBurst(get,set):haxe.Int64;
	function get_rateLimiterHostAddressBurst():haxe.Int64 return Raw.RNL_host_get_rate_limiter_host_address_burst(h());
	function set_rateLimiterHostAddressBurst(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_rate_limiter_host_address_burst(h(), v); return v; }
	public var rateLimiterHostAddressPeriod(get,set):haxe.Int64;
	function get_rateLimiterHostAddressPeriod():haxe.Int64 return Raw.RNL_host_get_rate_limiter_host_address_period(h());
	function set_rateLimiterHostAddressPeriod(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_rate_limiter_host_address_period(h(), v); return v; }
	public var rateLimiterRelayAddressBurst(get,set):haxe.Int64;
	function get_rateLimiterRelayAddressBurst():haxe.Int64 return Raw.RNL_host_get_rate_limiter_relay_address_burst(h());
	function set_rateLimiterRelayAddressBurst(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_rate_limiter_relay_address_burst(h(), v); return v; }
	public var rateLimiterRelayAddressPeriod(get,set):haxe.Int64;
	function get_rateLimiterRelayAddressPeriod():haxe.Int64 return Raw.RNL_host_get_rate_limiter_relay_address_period(h());
	function set_rateLimiterRelayAddressPeriod(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_rate_limiter_relay_address_period(h(), v); return v; }
	public var receiveBufferSize(get,set):Int;
	function get_receiveBufferSize():Int return Raw.RNL_host_get_receive_buffer_size(h());
	function set_receiveBufferSize(v:Int):Int { Raw.RNL_host_set_receive_buffer_size(h(), v); return v; }
	public var relayRateLimiterPerPort(get,set):Bool;
	function get_relayRateLimiterPerPort():Bool return Raw.RNL_host_get_relay_rate_limiter_per_port(h()) != 0;
	function set_relayRateLimiterPerPort(v:Bool):Bool { Raw.RNL_host_set_relay_rate_limiter_per_port(h(), v?1:0); return v; }
	public var reliableChannelBlockPacketWindowSize(get,set):Int;
	function get_reliableChannelBlockPacketWindowSize():Int return Raw.RNL_host_get_reliable_channel_block_packet_window_size(h());
	function set_reliableChannelBlockPacketWindowSize(v:Int):Int { Raw.RNL_host_set_reliable_channel_block_packet_window_size(h(), v); return v; }
	public var requireCertificate(get,set):Bool;
	function get_requireCertificate():Bool return Raw.RNL_host_get_require_certificate(h()) != 0;
	function set_requireCertificate(v:Bool):Bool { Raw.RNL_host_set_require_certificate(h(), v?1:0); return v; }
	public var sendBufferSize(get,set):Int;
	function get_sendBufferSize():Int return Raw.RNL_host_get_send_buffer_size(h());
	function set_sendBufferSize(v:Int):Int { Raw.RNL_host_set_send_buffer_size(h(), v); return v; }
	public var stunQueryTimeout(get,set):haxe.Int64;
	function get_stunQueryTimeout():haxe.Int64 return Raw.RNL_host_get_stun_query_timeout(h());
	function set_stunQueryTimeout(v:haxe.Int64):haxe.Int64 { Raw.RNL_host_set_stun_query_timeout(h(), v); return v; }
	public var totalAcceptedCertificates(get,never):haxe.Int64;
	function get_totalAcceptedCertificates():haxe.Int64 return Raw.RNL_host_get_total_accepted_certificates(h());
	public var totalDiscardedStaleOutgoingBlockPackets(get,never):haxe.Int64;
	function get_totalDiscardedStaleOutgoingBlockPackets():haxe.Int64 return Raw.RNL_host_get_total_discarded_stale_outgoing_block_packets(h());
	public var totalDroppedOutgoingMessages(get,never):haxe.Int64;
	function get_totalDroppedOutgoingMessages():haxe.Int64 return Raw.RNL_host_get_total_dropped_outgoing_messages(h());
	public var totalHardReceiveFailures(get,never):haxe.Int64;
	function get_totalHardReceiveFailures():haxe.Int64 return Raw.RNL_host_get_total_hard_receive_failures(h());
	public var totalHardSendFailures(get,never):haxe.Int64;
	function get_totalHardSendFailures():haxe.Int64 return Raw.RNL_host_get_total_hard_send_failures(h());
	public var totalOutgoingBandwidthDeferredDispatches(get,never):haxe.Int64;
	function get_totalOutgoingBandwidthDeferredDispatches():haxe.Int64 return Raw.RNL_host_get_total_outgoing_bandwidth_deferred_dispatches(h());
	public var totalPeerAddressChanges(get,never):haxe.Int64;
	function get_totalPeerAddressChanges():haxe.Int64 return Raw.RNL_host_get_total_peer_address_changes(h());
	public var totalPeersGivenUpOn(get,never):haxe.Int64;
	function get_totalPeersGivenUpOn():haxe.Int64 return Raw.RNL_host_get_total_peers_given_up_on(h());
	public var totalRateLimitedConnectionRequests(get,never):haxe.Int64;
	function get_totalRateLimitedConnectionRequests():haxe.Int64 return Raw.RNL_host_get_total_rate_limited_connection_requests(h());
	public var totalReceivedData(get,never):haxe.Int64;
	function get_totalReceivedData():haxe.Int64 return Raw.RNL_host_get_total_received_data(h());
	public var totalReceivedPackets(get,never):haxe.Int64;
	function get_totalReceivedPackets():haxe.Int64 return Raw.RNL_host_get_total_received_packets(h());
	public var totalRejectedCertificates(get,never):haxe.Int64;
	function get_totalRejectedCertificates():haxe.Int64 return Raw.RNL_host_get_total_rejected_certificates(h());
	public var totalRejectedRemoteLongTermPublicKeys(get,never):haxe.Int64;
	function get_totalRejectedRemoteLongTermPublicKeys():haxe.Int64 return Raw.RNL_host_get_total_rejected_remote_long_term_public_keys(h());
	public var totalRelayCeilingRateLimitedConnectionRequests(get,never):haxe.Int64;
	function get_totalRelayCeilingRateLimitedConnectionRequests():haxe.Int64 return Raw.RNL_host_get_total_relay_ceiling_rate_limited_connection_requests(h());
	public var totalRelayedConnectionRequests(get,never):haxe.Int64;
	function get_totalRelayedConnectionRequests():haxe.Int64 return Raw.RNL_host_get_total_relayed_connection_requests(h());
	public var totalSimultaneousConnectsGivenUp(get,never):haxe.Int64;
	function get_totalSimultaneousConnectsGivenUp():haxe.Int64 return Raw.RNL_host_get_total_simultaneous_connects_given_up(h());
	public var totalSimultaneousConnectsWon(get,never):haxe.Int64;
	function get_totalSimultaneousConnectsWon():haxe.Int64 return Raw.RNL_host_get_total_simultaneous_connects_won(h());
	public var totalSoftSendFailures(get,never):haxe.Int64;
	function get_totalSoftSendFailures():haxe.Int64 return Raw.RNL_host_get_total_soft_send_failures(h());
	public var totalStalledRetransmissions(get,never):haxe.Int64;
	function get_totalStalledRetransmissions():haxe.Int64 return Raw.RNL_host_get_total_stalled_retransmissions(h());
	public var transcriptBindingMode(get,set):Int;
	function get_transcriptBindingMode():Int return Raw.RNL_host_get_transcript_binding_mode(h());
	function set_transcriptBindingMode(v:Int):Int { Raw.RNL_host_set_transcript_binding_mode(h(), v); return v; }

	public function broadcast(channel:Int, data:Bytes):Void {
		Raw.RNL_host_broadcast_message_data(h(), channel, Native.data(data), data.length, 0);
	}
}
