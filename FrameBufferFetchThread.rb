class FrameBufferFetchThread
	def initialize(robot)
	@count=0
		@robot=robot
		@thread=Thread.new {
			worker
		}
	end

	def worker
		Thread.current["shouldrun"]=true
		width=@robot.rfb["frame_width"]
		height=@robot.rfb["frame_height"]
		@imagedata="0"*(width*height*3)
		loop do
			@robot.mutex.synchronize do
				getFrameBufferUpdate
			end
			unless Thread.current["shouldrun"]
				puts "Exiting the thread"
				break
			end
			sleep 1
		end
	end

	def stop
		@thread["shouldrun"]=false
		loop do
			break unless @thread.alive?
		end
	end

	def image
		@imagedata
	end

	def writeFrameBufferUpdateRequest(x,y,width,height)
		req=[
			3,#FramebufferUpdateRequest,
			1,#incremental
			x,
			y,
			width,
			height
		].pack("CCnnnn")
		@robot.socketStream.writeString(req)
	end
	def getFrameBufferUpdate
		width=@robot.rfb["frame_width"]
		height=@robot.rfb["frame_height"]
		x=0
		y=0
		bytesPerPixel=@robot.rfb["bytes_per_pixel"]
		writeFrameBufferUpdateRequest(x,y,width,height)
		msgType=@robot.socketStream.readUnsignedByte

		case msgType
		when 0
			@robot.socketStream.readUnsignedByte
			numberOfRects=@robot.socketStream.readUnsignedShort
			numberOfRects.times do |n|
				rectX=@robot.socketStream.readUnsignedShort
				rectY=@robot.socketStream.readUnsignedShort
				rectW=@robot.socketStream.readUnsignedShort
				rectH=@robot.socketStream.readUnsignedShort
				encoding=@robot.socketStream.readInt

				numberOfBytes=rectW*rectH*bytesPerPixel
				data=""
				toBeRead=numberOfBytes
				while(data.length != numberOfBytes)
					s=@robot.socketStream.readString(toBeRead)
					data.concat(s)
					toBeRead=toBeRead-s.length
				end
				x=0
				numberOfPixels=rectW*rectH
				dataOut=""
				rshift = @robot.rfb["red_shift"]
				gshift = @robot.rfb["green_shift"]
				bshift = @robot.rfb["blue_shift"]
				rmax = @robot.rfb["red_max"]
				gmax = @robot.rfb["green_max"]
				bmax = @robot.rfb["blue_max"]
				numberOfPixels.times do
						case bytesPerPixel
						when 4
							r=data[x+2]
							b=data[x]
							data[x]=r
							data[x+2]=b
							dataOut.concat(data[x,3])
							x=x+4
						when 2
							packed=data[x,2].unpack("s")[0]
							r=((packed>>rshift)&rmax)*255/rmax
							g=((packed>>gshift)&gmax)*255/gmax
							b=((packed>>bshift)&bmax)*255/bmax
							dataOut.concat([r,g,b].pack("CCC"))
							x=x+2
						end
				end


				image_width=width*3
				rect_width=rectW*3
				image_offset=rectY*image_width+rectX*3
				data_offset=0
				rectH.times do
					image_limit=image_offset+rect_width-1
					data_limit=data_offset+rect_width-1
					@imagedata[image_offset..image_limit]=dataOut[data_offset..data_limit]
					data_offset=data_offset+rect_width
					image_offset=image_offset+image_width
				end
				@count=@count+1
#name="/mnt/host-share/camellia/image#{@count}.pnm"
#				puts "image#{@count} for patch of location=#{rectX},#{rectY} and dimension=#{rectW},#{rectH}"
#				dumpImage(name)
#				dumpUpdate(dataOut,rectW,rectH,@count)
			end
		else
			puts "Could not understand what the server said #{msgType}!"
		end
	end

	def dumpImage(name)
		file=File.open(name,"wb")
		file.print("P6\n")
		file.print("#Comment\n")
		file.print("1280 1024\n")
		file.print("255\n")
		file.print(@imagedata)
		file.close
	end
	def dumpUpdate(data,w,h,count)
		name="/mnt/host-share/camellia/image_update#{@count}.pnm"
		file=File.open(name,"wb")
		file.print("P6\n")
		file.print("#Comment\n")
		file.print("#{w} #{h}\n")
		file.print("255\n")
		file.print(data)
		file.close
	end
end
