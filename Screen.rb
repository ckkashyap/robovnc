class Screen
	def initialize(robot)
		@robot=robot
	end
	def writeFrameBufferUpdateRequest(x,y,width,height)
		req=[
			3,#FramebufferUpdateRequest,
			0,#non-incremental
			x,
			y,
			width,
			height
		].pack("CCnnnn")
		@robot.socketStream.writeString(req)
	end
	def dumpScreenToFile(name="screen.pnm")
		@robot.mutex.synchronize do
		file=File.open(name,"wb")
		file.print("P6\n")
		file.print("#Comment\n")
		width=@robot.rfb["frame_width"]
		height=@robot.rfb["frame_height"]
		file.print("#{width} #{height}\n")
		file.print("255\n")
		file.print(@robot.frame.image)
		file.close
		end
	end
end
