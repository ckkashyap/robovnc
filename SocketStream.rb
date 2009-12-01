require 'socket'
class SocketStream
	def initialize(machine,port)
		@machine=machine
		@port=port
		@socket=TCPSocket.open(@machine, @port)
	end
	def readInt
		@socket.recv(4).unpack("N")[0]
	end
	def writeInt(i)
		@socket.send([i].pack("N"),0)
	end
	def readUnsignedShort
		@socket.recv(2).unpack("n")[0]
	end
	def readUnsignedByte
		@socket.recv(1).unpack("C")[0]
	end
	def readString(l)
		@socket.recv(l)
	end
	def writeString(s)
		@socket.send(s,0)
	end

	def readPad(p)
		@socket.recv(p)
	end

	def writeByte(i)
		@socket.send([i].pack("C"),0)
	end
	def close
		@socket.close
	end
end

