class Mouse
	def initialize(robot)
		@robot=robot
	end
	def createMouseEvent(event,button,updown,x,y)
		event="" if event.nil?
		mask=0
		mask=1 if (/left/i.match(button) && updown)
		mask=mask|4 if (/right/i.match(button) && updown)
		event.concat( 
		[
			5, #mouse event
			mask,
			x,
			y
		].pack("CCnn")
		)
	end
	def leftClick(x,y)
		@robot.mutex.synchronize do
			e=createMouseEvent(nil,"left",true,x,y);
			e=createMouseEvent(e,"left",false,x,y);
			@robot.socketStream.writeString(e)
		end
	end
	def rightClick(x,y)
		@robot.mutex.synchronize do
			e=createMouseEvent(nil,"right",true,x,y);
			e=createMouseEvent(e,"right",false,x,y);
			@robot.socketStream.writeString(e)
		end
	end
	def moveTo(x,y)
		@robot.mutex.synchronize do
			e=createMouseEvent(nil,"right",false,x,y);
			e=createMouseEvent(e,"right",false,x,y);
			@robot.socketStream.writeString(e)
		end
	end
end
