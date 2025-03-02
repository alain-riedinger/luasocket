--[[
Simple TCP sample server/client
- client methods to send a message
- server methods to listen

The sampe server can be run with this command:
lua -e "require('tcpsample').listen('127.0.0.1', 6060)"

A sample message can be sent with this command
lua -e "require('tcpsample').sample('127.0.0.1', 6060, 'Hello guys')"
]]

-- Table bearing the different methods
TcpSample = {}

-- Initialisation
TcpSample.host = "127.0.0.1"
TcpSample.port = 6060
TcpSample.socket = require("socket")
TcpSample.tcp = nil

-- Initiliaze TCP client connection
function TcpSample.init(host, port)
  TcpSample.host = host
  TcpSample.port = port
  TcpSample.tcp = assert(TcpSample.socket.tcp())
  TcpSample.tcp:connect(TcpSample.host, TcpSample.port)
end

-- Close TCP client connection
function TcpSample.close()
  TcpSample.tcp:close()
end

-- Listen function
--   listens indefinitely for incoming TCP messages
--   displays received messages
function TcpSample.listen(host, port)
	print("TCP listen on: "..host..":"..port.."    (Ctrl+C to quit...)")
	
	local socket = require("socket")
	local s = assert(socket.bind(host, port))
	while true do
		local c = assert(s:accept())
		local l, e = c:receive()
		while not e do
			print(l)
			l, e = c:receive()
		end
		print("-- debug: "..e)
	end
end

-- A sample function to test a send over TCP connection
--  sends then given text to the TCP listener
function TcpSample.sample(host, port, txt)
    TcpSample.init(host, port)
	TcpSample.tcp:send(txt.."\n")
end

return TcpSample
