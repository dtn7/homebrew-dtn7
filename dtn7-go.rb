class Dtn7Go < Formula
  desc "Delay-tolerant networking software suite, Bundle Protocol Version 7"
  homepage "https://dtn7.github.io"
  url "https://github.com/dtn7/dtn7-go.git",
      :tag      => "v0.9.0",
      :revision => "08ab34ba60d129bb0c10f69f6f13493bcead6d4e"
  head "https://github.com/dtn7/dtn7-go.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath

    src = buildpath/"src/github.com/dtn7/dtn7-go"
    src.install buildpath.children
    src.cd do
      system "go", "build", "-o", "#{name}d", "./cmd/dtnd/"
      system "go", "build", "-o", "#{name}-tool", "./cmd/dtn-tool/"
      bin.install "#{name}d"
      bin.install "#{name}-tool"
    end

    (etc/"#{name}").mkpath
    (etc/"#{name}/configuration.toml").write <<~EOS
# SPDX-FileCopyrightText: 2019 Markus Sommer
# SPDX-FileCopyrightText: 2019, 2020 Alvar Penning
# SPDX-FileCopyrightText: 2020 Jonas Höchst
#
# SPDX-License-Identifier: GPL-3.0-or-later

# The core is the main module of the delay-tolerant networking daemon.
[core]
# Path to the bundle storage. Bundles will be saved in this directory to be
# present after restarting dtnd.
store = "#{var}/#{name}/store"

# Allow inspection of forwarding bundles, containing an administrative record.
# This allows deletion of stored bundles after being received.
inspect-all-bundles = true

# The node's ID, which should be a dtn-URI. Each node's endpoint ID should be
# an URI based on the given node-id.
node-id = "dtn://#{Socket.gethostname}/"

# If a signature-private entry exists, all outgoing bundles created at this
# node will be signed with the following key. Such a key can be created by:
#   $ xxd -l 64 -p -c 64 /dev/urandom
# Please DO NOT use the following key or a variation of it. I am serious.
# signature-private = "2d5b59df9e860636ee392fc7833d957543cd7e47e95b8a2800224408840242a8edff1aafc10af23ae32a6868e2c31cbbcf3157a706accae2eb7faa7a1d7ee84e"


# Configure the format and verbosity of dtnd's logging.
[logging]
# Should be one of, sorted from silence to verbose:
# panic,fatal,error,warn,info,debug,trace
level = "info"

# Show the calling method and its file in the logs
# report-caller = true

# Could be "text" for human readable output or "json".
# format = "json"


# The peer/neighbor discovery searches the (local) network for other dtnd nodes
# and tries to establish a connection to the promoted CLAs.
[discovery]
ipv4 = true
ipv6 = true

# Interval between two messages in seconds, defaults to 10.
interval = 30


# Agents are applications or interfaces for sending or receiving bundles.
[agents]
# Web server based agent with an own HTTP server for third party tools.
[agents.webserver]
# Address to bind the server to.
address = "localhost:8080"

# Create a WebSocket endpoint at "ws://localhost:8080/ws"
websocket = true

# Create a RESTful endpoints at "http://localhost:8080/rest/"
rest = true


# Each listen is another convergence layer adapter (CLA). Multiple [[listen]]
# blocks are usable.
[[listen]]
# Protocol to use, one of tcpclv4, tcpclv4-ws, mtcp, bbc.
protocol = "tcpclv4"

# Address to bind this CLA to.
endpoint = ":4556"


# Another example based on the WebSocket variant of the TCPCLv4.
# [[listen]]
# protocol = "tcpclv4-ws"
# # Webserver on port 8081 with a WebSocket endpoint at "ws://HOST:8081/tcpclv4".
# endpoint = ":8081"


# Another example for a Bundle Broadcasting Connector with a rf95modem.
# [[listen]]
# protocol = "bbc"
# endpoint = "bbc://rf95modem/dev/ttyUSB0"


# Multiple [[peers]] might be configured.
# [[peer]]
# # Protocol to use, one of tcpclv4, tcpclv4-ws, mtcp.
# protocol = "tcpclv4"
# # Address to connect to this CLA.
# endpoint = "10.0.0.2:4556"


# [[peer]]
# protocol = "tcpclv4-ws"
# endpoint = "ws://HOST:PORT/tcpclv4"


# Another peer example..
# [[peer]]
# # The name/endpoint ID of this peer, as MTCP does not support any introduction.
# node = "dtn://gamma/"
# protocol = "mtcp"
# endpoint = "[fc23::2]:35037"


# Specify routing algorithm
[routing]
# One of  "epidemic", "spray", "binary_sparay", "dtlsr", "prophet", "sensor-mule"
algorithm = "epidemic"


# Config for spray routing
# [routing.sprayconf]
# multiplicity = 10


# Config for dtlsr
# [routing.dtlsrconf]
# recomputetime = "30s"
# broadcasttime = "30s"
# purgetime = "10m"


# Config for prophet
# [routing.prophetconf]
# # pinit ist the prophet initialisation constant (default value provided by the PROPHET-paper)
# pinit = 0.75
#
# # beta is the prophet scaling factor for transitive predictability (default value provided by the PROPHET-paper)
# beta = 0.25
#
# # gamma is the prophet ageing factor (default value provided by the PROPHET-paper)
# gamma = 0.98
#
# ageinterval = "1m"


# Config for sensor-mule
# [routing.sensor-mule-conf]
# # sensor-node-regex is a regular expression matching sensor node's node IDs.
# sensor-node-regex = "^dtn://[^/]+\\.sensor/.*$"
#
# # This routing structure defines the underlying routing algorithm;
# # it's identical to the parent routing section.
# # In this example, the underlying algorithm is the simple epidemic routing.
# [routing.sensor-mule-conf.routing]
# algorithm = "epidemic"

    EOS

    ohai "Created config file at /usr/local/etc/#{name}/configuration.toml"
    
  end

  def post_install
    (var/"#{name}").mkpath
  end

  plist_options :manual => "dtn7-god"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/#{name}d</string>
          <string>/usr/local/etc/#{name}/configuration.toml</string>
        </array>
        <key>KeepAlive</key>
        <dict>
          <key>Crashed</key>
          <true />
          <key>SuccessfulExit</key>
          <false />
        </dict>
        <key>ProcessType</key>
        <string>Background</string>
        <key>WorkingDirectory</key>
        <string>#{var}/#{name}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/#{name}/daemon.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/#{name}/daemon.log</string>
      </dict>
    </plist>
  EOS
  end

  test do
    # dtn7d runs as daemon, thus only the correct installation of the binary can be tested
    system "which", "#{name}d"

    # dtn7cat required a running dtn7d, thus use help as a simple test
    system "which", "#{name}-tool"
  end
end
