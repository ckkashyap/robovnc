require 'Robot'

r=Robot.new

r.connect("localhost","5900","abc123")
r.keyboard.typeString("Hello World")
r.keyboard.pressEnter
r.screen.dumpScreenToFile
