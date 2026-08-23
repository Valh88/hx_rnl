import rnl.raw.Raw;
import rnl.internal.RnlBuild;
import rnl.Instance;
import rnl.Network;
import rnl.Network.VirtualNetwork;
import rnl.Host;
import rnl.Address;
import rnl.Peer;
import rnl.Channel;
import rnl.Enums.WorkMode;
import rnl.Enums.EventType;

class Main {
	public static function main() {
		var inst = new Instance();
		var net = new VirtualNetwork(inst);
		var server = new Host(inst, net);
		var client = new Host(inst, net);

		var srvAddr = Address.parse("127.0.0.1");
		srvAddr.port = 23232;
		server.setAddress(srvAddr);
		server.start(WorkMode.WmV4Only);
		client.start(WorkMode.WmV4Only);

		var cpeer:Peer = client.connect(srvAddr, 1, haxe.Int64.ofInt(42));
		trace('connecting...');

		var gotPong = false;
		var sentPing = false;
		var iterations = 0;

		while (iterations < 2000 && !gotPong) {
			// Server
			switch (server.service(1)) {
				case null:
				case ev:
					if (ev.type == EventType.PeerConnect)
						trace('server connected');
					if (ev.type == EventType.PeerReceive)
						server.broadcast(0, haxe.io.Bytes.ofString("pong"));
					server.eventFree();
			}
			// Client
			switch (client.service(1)) {
				case null:
				case ev:
					if (ev.type == EventType.PeerApproval) {
						trace('client approved');
						var ch = cpeer.getChannel(0);
						if (ch != null) ch.send(haxe.io.Bytes.ofString("ping"));
						sentPing = true;
					}
					if (ev.type == EventType.PeerReceive)
						gotPong = true;
					client.eventFree();
			}
			iterations++;
		}

		trace('sentPing=$sentPing gotPong=$gotPong');
		trace(sentPing && gotPong ? 'PASS' : 'FAIL');
	}
}
