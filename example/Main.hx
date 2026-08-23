import rnl.raw.Raw;
import rnl.internal.RnlBuild;
import rnl.Instance;
import rnl.Network;
import rnl.Network.VirtualNetwork;
import rnl.Network.RealNetwork;
import rnl.Network.InterferenceNetwork;
import rnl.Host;
import rnl.Address;
import rnl.Peer;
import rnl.Channel;
import rnl.RnlEvent;
import rnl.Enums.WorkMode;
import rnl.Enums.ChannelType;
import rnl.Enums.EventType;

typedef Ctx = {inst:Instance, net:Network, srv:Host, cli:Host, addr:Address};

/**
 * RNL demo suite. Each test spins up a client/server pair and checks one
 * aspect of the library. The connect handshake is handled internally:
 * client.connect() returns immediately, and once approved the
 * PeerApproval event fires — that's where the client side starts sending.
 *
 *   1. ping-pong        basic connect + reliable send/receive
 *   2. channel types    all four delivery types carry traffic
 *   3. loss simulation  reliable survives 30% datagram loss, unreliable loses
 *   4. fragmentation    message larger than one datagram arrives intact
 *   5. disconnect       PeerDisconnect delivers the user payload
 */
class Main {
	static var failures = 0;

	public static function main() {
		testPingPong();
		testChannelTypes();
		testLossSimulation();
		testFragmentation();
		testDisconnectData();
		testHostConfig();
		testHandlersFlushDns();
		trace(failures == 0 ? 'ALL TESTS PASS' : 'FAILURES: $failures');
		if (failures > 0) Sys.exit(1);
	}

	static function ok(name:String, cond:Bool, ?detail:String) {
		if (!cond) failures++;
		trace('[$name] ${cond ? "PASS" : "FAIL"}${detail != null ? ' ($detail)' : ""}');
	}

	/** Server+client pair sharing one virtual network, port 23232. */
	static function makePair(?net:Network = null, ?types:Array<ChannelType> = null):Ctx {
		var inst = new Instance();
		if (net == null) net = new VirtualNetwork(inst);
		var srv = new Host(inst, net);
		var cli = new Host(inst, net);
		Raw.RNL_host_set_maximum_count_channels(srv.h(), 16);
		Raw.RNL_host_set_maximum_count_channels(cli.h(), 16);
		if (types != null) {
			for (i in 0...types.length) {
				srv.setChannelType(i, types[i]);
				cli.setChannelType(i, types[i]);
			}
		}
		var addr = Address.parse("127.0.0.1");
		addr.port = 23232;
		srv.setAddress(addr);
		srv.start(WorkMode.WmV4Only);
		cli.start(WorkMode.WmV4Only);
		return {inst: inst, net: net, srv: srv, cli: cli, addr: addr};
	}

	/** Pump both hosts until done() or maxIter service rounds elapse. */
	static function pump(p:Ctx, maxIter:Int, onSrv:RnlEvent->Void, onCli:RnlEvent->Void, done:Void->Bool):Bool {
		for (_ in 0...maxIter) {
			var e = p.srv.service(1);
			if (e != null) { onSrv(e); p.srv.eventFree(); }
			e = p.cli.service(1);
			if (e != null) { onCli(e); p.cli.eventFree(); }
			if (done()) return true;
		}
		return done();
	}

	// ------------------------------------------------------------- 1 ping-pong

	static function testPingPong() {
		var name = "pingpong";
		var p = makePair();
		var peer = p.cli.connect(p.addr, 1, haxe.Int64.ofInt(42));
		var sent = false, got = false;

		pump(p, 8000,
			function(ev) if (ev.type == EventType.PeerReceive) {
				p.srv.broadcast(0, haxe.io.Bytes.ofString("pong"));
			},
			function(ev) {
				if (ev.type == EventType.PeerApproval && !sent) {
					sent = true;
					peer.getChannel(0).send(haxe.io.Bytes.ofString("ping"));
				}
				if (ev.type == EventType.PeerReceive) {
					var payload = ev.message.getBytes();
					trace('  cli recv len=${payload.length} "${payload.toString()}"');
					got = payload.toString() == "pong";
				}
			},
			function() return got);

		ok(name, got && sent, 'ping sent=$sent pong received=$got');
	}

	// --------------------------------------------------------- 2 channel types

	static function testChannelTypes() {
		var name = "channels";
		var types = [ReliableOrdered, ReliableUnordered, UnreliableOrdered, UnreliableUnordered];
		var p = makePair(null, types);
		var peer = p.cli.connect(p.addr, types.length, haxe.Int64.ofInt(0));

		var received = new Map<Int, String>();
		var sentAll = false;
		var denial = -1;
		pump(p, 12000,
			function(ev) {
				if (ev.type == EventType.PeerReceive) {
					received[ev.channel] = ev.message.getBytes().toString();
					trace('  srv recv ch=${ev.channel} "${received[ev.channel]}"');
				} else if (ev.type == EventType.PeerDenial) {
					denial = cast ev.denialReason;
				}
			},
			function(ev) if (ev.type == EventType.PeerApproval && !sentAll) {
				sentAll = true;
				for (i in 0...types.length) {
					var ch = peer.getChannel(i);
					ch.send(haxe.io.Bytes.ofString('hello-ch$i'));
				}
			},
			function() return Lambda.count(received) >= types.length);

		var detail = [];
		var allOk = Lambda.count(received) == types.length;
		for (i in 0...types.length) {
			var want = 'hello-ch$i';
			var gotIt = received.get(i) == want;
			allOk = allOk && gotIt;
			detail.push('ch$i(${typeName(types[i])}):${gotIt ? "ok" : "MISSING"}');
		}
		ok(name, allOk && sentAll, detail.join(" "));
	}

	static function typeName(t:ChannelType):String return switch t {
		case ReliableOrdered: "RO";
		case ReliableUnordered: "RU";
		case UnreliableOrdered: "UO";
		case UnreliableUnordered: "UU";
	};

	// ------------------------------------------------------- 3 loss simulation

	static function testLossSimulation() {
		var name = "loss";
		var inst = new Instance();
		var virt = new VirtualNetwork(inst);
		var net = new InterferenceNetwork(inst, virt);
		net.setLoss(0.30); // ~30% of datagrams are dropped

		var p = makePair(net, [ReliableOrdered, UnreliableOrdered]);
		var peer = p.cli.connect(p.addr, 2, haxe.Int64.ofInt(0));

		var total = 50;
		var rCount = 0, uCount = 0, rOrdered = true, rLast = -1;
		var sentAll = false, ticks = 0;

		pump(p, 40000,
			function(ev) if (ev.type == EventType.PeerReceive) {
				var seq = ev.message.getBytes().getInt32(0);
				if (ev.channel == 0) {
					rCount++;
					if (seq <= rLast) rOrdered = false;
					rLast = seq;
				} else if (ev.channel == 1) uCount++;
			},
			function(ev) if (ev.type == EventType.PeerApproval && !sentAll) {
				sentAll = true;
				var rCh = peer.getChannel(0), uCh = peer.getChannel(1);
				for (i in 0...total) {
					var b = haxe.io.Bytes.alloc(4);
					b.setInt32(0, i);
					rCh.send(b); // must survive via retransmission
					uCh.send(b); // individual datagrams may be dropped
				}
			},
			function() { ticks++; return (rCount >= total && ticks > 500) || ticks > 35000; });

		ok(name, sentAll && rCount == total && rOrdered,
			'reliable $rCount/$total ordered=$rOrdered | unreliable $uCount/$total (dropped=${total - uCount})');
	}

	// -------------------------------------------------------- 4 fragmentation

	static function testFragmentation() {
		var name = "fragmentation";
		var p = makePair();
		var peer = p.cli.connect(p.addr, 1, haxe.Int64.ofInt(0));

		var unfrag = -1;
		var payloadLen = -1;
		var sumSent = 0;
		var gotLen = -1, gotSum = -1, gotIt = false;
		var sent = false;

		pump(p, 20000,
			function(ev) if (ev.type == EventType.PeerReceive && !gotIt) {
				gotIt = true;
				var data = ev.message.getBytes();
				gotLen = data.length;
				gotSum = 0;
				for (i in 0...data.length) gotSum += data.get(i);
			},
			function(ev) if (ev.type == EventType.PeerApproval && !sent) {
				sent = true;
				var ch = peer.getChannel(0);
				unfrag = ch.maximumUnfragmented;
				payloadLen = unfrag * 4 + 137; // definitely spans several datagrams
				var data = haxe.io.Bytes.alloc(payloadLen);
				for (i in 0...payloadLen) {
					data.set(i, i & 0xFF);
					sumSent += i & 0xFF;
				}
				ch.send(data);
			},
			function() return gotIt);

		var okCond = gotIt && gotLen == payloadLen && gotSum == sumSent;
		ok(name, okCond,
			'max_unfragmented=$unfrag, message $payloadLen bytes -> received $gotLen, checksum ${gotSum == sumSent ? "match" : 'MISMATCH'}');
	}

	// ------------------------------------------------------------ 5 disconnect

	static function testDisconnectData() {
		var name = "disconnect";
		var p = makePair();
		var peer = p.cli.connect(p.addr, 1, haxe.Int64.ofInt(7));
		var srvGotData = false, hasValue = false;
		var kicked = false;

		pump(p, 8000,
			function(ev) if (ev.type == EventType.PeerDisconnect) {
				srvGotData = true;
				hasValue = ev.data.low == 0x05060708 && ev.data.high == 0x01020304;
			},
			function(ev) {
				if (ev.type == EventType.PeerApproval && !kicked) {
					kicked = true;
					peer.disconnect(haxe.Int64.make(0x01020304, 0x05060708));
				}
			},
			function() return srvGotData);

		ok(name, srvGotData && hasValue, 'server saw disconnect with sentinel data: $srvGotData');
	}

	// ------------------------------------------------------------ 6 host config

	static function testHostConfig() {
		var name = "config";
		var p = makePair();
		var srv = p.srv;
		var cli = p.cli;

		srv.incomingBandwidthLimit = 64000;
		srv.outgoingBandwidthLimit = 128000;
		srv.congestionControl = true;
		srv.maximumCountPeers = 32;
		// protocol id must match on both sides or connections are denied:
		srv.protocolId = haxe.Int64.make(0, 1234);
		cli.protocolId = haxe.Int64.make(0, 1234);

		var checks = [
			{n:"incoming", ok:srv.incomingBandwidthLimit == 64000},
			{n:"outgoing", ok:srv.outgoingBandwidthLimit == 128000},
			{n:"congestion", ok:srv.congestionControl == true},
			{n:"maxPeers", ok:srv.maximumCountPeers == 32},
			{n:"protocolId", ok:srv.protocolId.low == 1234},
		];
		var okCond = true;
		var detail = [];
		for (c in checks) { okCond = okCond && c.ok; detail.push('${c.n}=${c.ok}'); }

		var peer = p.cli.connect(p.addr, 1, haxe.Int64.ofInt(0));
		var approved = false;
		pump(p, 4000,
			function(ev) {},
			function(ev) if (ev.type == EventType.PeerApproval) approved = true,
			function() return approved);
		var mtuOk = false;
		if (approved) {
			pump(p, 2000, function(ev) {}, function(ev) {}, function() return false);
			mtuOk = peer.mtu > 0 && peer.localPeerId >= 0;
		}
		var mtuStr = approved ? Std.string(peer.mtu) : "n/a";
		ok(name, okCond && (!approved || mtuOk),
			'${detail.join(" ")}, approved=$approved, peer mtu=$mtuStr');
	}

	// ------------------------------------------- 7 handlers / flush / dns

	static function testHandlersFlushDns() {
		var name = "handlers";
		var p = makePair();
		var peer:Peer = null;

		var connEv = false, gotPong = false, discEv = false, sent = false;
		var kicked = false;

		// callback-style: no manual switch/eventFree — service() dispatches.
		p.srv.onPeerConnect = function(ev) connEv = true;
		p.srv.onPeerReceive = function(ev) {
			if (ev.message.getBytes().toString() == "ping")
				p.srv.broadcast(0, haxe.io.Bytes.ofString("pong"));
		};
		p.srv.onPeerDisconnect = function(ev) discEv = true;
		p.cli.onPeerApproval = function(ev) {
			if (!sent) { sent = true; peer.getChannel(0).send(haxe.io.Bytes.ofString("ping")); }
		};
		p.cli.onPeerReceive = function(ev) {
			if (ev.message.getBytes().toString() == "pong") gotPong = true;
		};

		peer = p.cli.connect(p.addr, 1, haxe.Int64.ofInt(5));
		var ticks = 0;
		while (ticks < 8000 && !gotPong) { p.srv.service(1); p.cli.service(1); ticks++; }

		if (peer != null && !kicked) {
			kicked = true;
			peer.disconnect(haxe.Int64.ofInt(0));
		}
		while (ticks < 16000 && !discEv) { p.srv.service(1); p.cli.service(1); ticks++; }

		var flushOk = p.srv.flush();

		// DNS через реальную сеть (localhost всегда резолвится через hosts)
		var realNet = new RealNetwork(p.inst);
		var resolved = realNet.resolveHost("localhost", 1);
		var dnsOk = resolved != null;
		realNet.dispose();

		ok(name, sent && gotPong && connEv && discEv && flushOk && dnsOk,
			'sent=$sent pong=$gotPong connectEv=$connEv disconnectEv=$discEv flush=$flushOk dns=$dnsOk');
	}
}
