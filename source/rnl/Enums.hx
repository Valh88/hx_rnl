package rnl;

enum abstract ServiceStatus(Int) {
	var Error;
	var Timeout;
	var Interrupt;
	var Event;
}

enum abstract EventType(Int) {
	var EvtNone;
	var PeerCheckConnectionToken;
	var PeerCheckAuthenticationToken;
	var PeerConnect;
	var PeerDisconnect;
	var PeerApproval;
	var PeerDenial;
	var PeerBandwidthLimits;
	var PeerMtu;
	var PeerReceive;
}

enum abstract ChannelType(Int) {
	var ReliableOrdered;
	var ReliableUnordered;
	var UnreliableOrdered;
	var UnreliableUnordered;
}

enum abstract PeerState(Int) {
	var StDisconnected;
	var StConnectionRequesting;
	var StConnectionChallenging;
	var StConnectionAuthenticating;
	var StConnectionApproving;
	var StConnected;
	var StDisconnectLater;
	var StDisconnecting;
	var StDisconnectionAcknowledging;
	var StDisconnectionPending;
}

enum abstract WorkMode(Int) {
	var WmAuto;
	var WmV4Only;
	var WmV6Only;
	var WmV4OnV6;
	var WmV4AndV6;
}

enum abstract TranscriptBinding(Int) {
	var TbOff;
	var TbAllowed;
	var TbRequired;
}

enum abstract DenialReason(Int) {
	var DenyUnknown;
	var DenyFull;
	var DenyTooFewChannels;
	var DenyTooManyChannels;
	var DenyWrongChannelTypes;
	var DenyUnauthorized;
}

enum abstract CertVerdict(Int) {
	var CertAccepted;
	var CertAbsent;
	var CertBadSignature;
	var CertNotYetValid;
	var CertExpired;
	var CertNoClock;
	var CertWrongSubject;
}
