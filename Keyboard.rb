class Keyboard
	def createKeyEvent(event,key,updown)
		event="" if event.nil?
		event.concat( 
		[
			4, #KeyboardEvent
			(updown==true)?1:0,
			0,
			0,
			key
		].pack("CCCCN")
		)
	end
	def pressKey(k)
		@robot.mutex.synchronize do
			e=createKeyEvent(nil,k,true)
			e=createKeyEvent(e,k,false)
			@robot.socketStream.writeString(e)
		end
	end
	def pressWindowsCombination(k)
		@robot.mutex.synchronize do
			k=k[0]
			e=createKeyEvent(nil,0xffeb,true)
			e=createKeyEvent(e,k,true)
			e=createKeyEvent(e,k,false)
			e=createKeyEvent(e,0xffeb,false)
			@robot.socketStream.writeString(e)
		end
	end
	def pressAltCombination(k)
		@robot.mutex.synchronize do
			k=k[0]
			e=createKeyEvent(nil,0xffe9,true)
			e=createKeyEvent(e,k,true)
			e=createKeyEvent(e,k,false)
			e=createKeyEvent(e,0xffe9,false)
			@robot.socketStream.writeString(e)
		end
	end
	def pressCtrlCombination(k)
		@robot.mutex.synchronize do
			k=k[0]
			e=createKeyEvent(nil,0xffe3,true)
			e=createKeyEvent(e,k,true)
			e=createKeyEvent(e,k,false)
			e=createKeyEvent(e,0xffe3,false)
			@robot.socketStream.writeString(e)
		end
	end
	def pressShiftCombination(k)
		@robot.mutex.synchronize do
			k=k[0]
			e=createKeyEvent(nil,0xffe1,true)
			e=createKeyEvent(e,k,true)
			e=createKeyEvent(e,k,false)
			e=createKeyEvent(e,0xffe1,false)
			@robot.socketStream.writeString(e)
		end
	end
	def pressEnter
		pressKey(0xff0d)
	end
	def pressTab
		pressKey(0xff09)
	end
	def pressEscape
		pressKey(0xff1b)
	end
	def pressUp
		pressKey(0xff52)
	end
	def pressDown
		pressKey(0xff54)
	end
	def pressRight
		pressKey(0xff53)
	end
	def pressLeft
		pressKey(0xff51)
	end
	def typeString(s)
		s.each_byte do |b|
			pressKey(b)
		end
	end
	def initialize(robot)
		@robot=robot
	end
end
