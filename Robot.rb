require 'thread'
require 'RFBConnector'
require 'SocketStream'
require 'Keyboard'
require 'Mouse'
require 'Screen'
require 'FrameBufferFetchThread'

class Robot
	def initialize
		@mutex=Mutex.new
		@mutex.synchronize do
			@rfb=RFBConnector.new
			@keyboard=Keyboard.new(self)
			@mouse=Mouse.new(self)
			@screen=Screen.new(self)
			@frameThread=nil
			@socketstream=nil
		end
	end
	def connect(machine,port,password="")
		@frameThread.stop unless @frameThread.nil?
		mutex.synchronize do
			@machine=machine
			@port=port
			@password=password
			@socketstream.close unless @socketstream.nil?
			@socketstream=SocketStream.new(@machine,@port)
			@rfb.connect(@socketstream,@password)
			@frameThread=FrameBufferFetchThread.new(self)
		end
	end
	def reconnect
		if @machine.nil? || @port.nil?
			puts "Cannot reconnect...first connect"
			return
		end
		connect(@machine,@port,@password)
	end
	def socketStream
		@socketstream
	end
	def keyboard
		@keyboard
	end
	def mouse
		@mouse
	end
	def screen
		@screen
	end
	def rfb
		@rfb
	end
	def mutex
		@mutex
	end
	def frame
		@frameThread
	end
end

