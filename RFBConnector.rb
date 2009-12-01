require 'openssl'

class RFBConnector
	def readVersionMessge
		m=@socketStream.readString(12)
		raise "Bad version message" unless /RFB (\d\d\d).(\d\d\d)\n/.match(m)
		@data["server_major_version"]=$1.to_i
		@data["server_minor_version"]=$2.to_i
	end

	def writeVersionMessage
		# TODO - must
		@socketStream.writeString("RFB 003.003\n");
		@data["client_major_version"]=3
		@data["client_minor_version"]=3
	end
	def vncAuthenticate
		challenge1=@socketStream.readString(8)
		challenge2=@socketStream.readString(8)
		des = OpenSSL::Cipher::Cipher.new("des")
		password=""
		@password.each_byte do |b|
			bits=[b].pack("C").unpack("b*").pack("B*")
			password.concat(bits)
		end
		z=[0].pack("c")
		password.concat(z*(8-password.length))
		des.key=password
		enc = des.encrypt
		cipherText1 = enc.update(challenge1)
		enc = des.encrypt
		cipherText2 = enc.update(challenge2)
		@socketStream.writeString(cipherText1)
		@socketStream.writeString(cipherText2)
		result = @socketStream.readInt
		if result != 0
			puts "Authentication falied"
			exit
		end
	end
	def negotiateSecurity
		#TODO - use the clientMinorVersion
		st=@socketStream.readInt
		#raise "Unimplemented security type #{st}" unless st==RFBAuthTypes::None
		@data["security_type"]=st
		vncAuthenticate if st == 2
	end
	def writeClientInit
		#TODO, assuming a desktop share and writing 1
		@socketStream.writeByte(1)
	end
	def readServerInit
		@data["frame_width"]=@socketStream.readUnsignedShort
		@data["frame_height"]=@socketStream.readUnsignedShort
		@data["bits_per_pixel"]=@socketStream.readUnsignedByte
		@data["depth"]=@socketStream.readUnsignedByte
		@data["big_endian"]=@socketStream.readUnsignedByte!=0
		@data["true_color"]=@socketStream.readUnsignedByte!=0
		@data["red_max"]=@socketStream.readUnsignedShort
		@data["green_max"]=@socketStream.readUnsignedShort
		@data["blue_max"]=@socketStream.readUnsignedShort
		@data["red_shift"]=@socketStream.readUnsignedByte
		@data["green_shift"]=@socketStream.readUnsignedByte
		@data["blue_shift"]=@socketStream.readUnsignedByte
		@socketStream.readPad(3)
		nameLength=@socketStream.readInt
		@data["frame_name"]=@socketStream.readString(nameLength)
		@data["bytes_per_pixel"]=@data["bits_per_pixel"]/8
	end
	def connect(socketStream,password="")
		@data=Hash.new
		@socketStream=socketStream
		@password=password
		readVersionMessge
		writeVersionMessage
		negotiateSecurity
		writeClientInit
		readServerInit
	end
	def dump
		if @data.nil?
			puts "Nil data"
			return
		end
		@data.each do |key,val|
			puts "#{key} => #{val}"
		end
	end
	def [](k)
		return nil if @data.nil?
		@data[k]
	end
	def []=(k,v)
		@data[k]=v
	end
end
