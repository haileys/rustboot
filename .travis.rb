#!/usr/bin/env ruby
# coding: BINARY
require "socket"
require "timeout"
require "json"

QEMU = ENV["QEMU"] || "qemu-system-i386"
IMG  = ENV["IMG"]  || "floppy.img"

File.delete("x.ppm") if File.exist?("x.ppm")

Timeout.timeout(20) do
  server = TCPServer.new(4444)
  qemu = IO.popen([
    QEMU,
    "-monitor", "tcp:127.0.0.1:4444",
    "-net", "none",
    "-nographic",
    "-fda", IMG,
  ], "r+")
  monitor = server.accept

  puts monitor.gets

  eip = nil
  loop do
    monitor.puts "print $eip"
    monitor.gets
    current_eip = monitor.gets
    puts "EIP is at #{current_eip}"
    if current_eip == eip
      puts "Detected halt, screenshotting."
      break
    else
      eip = current_eip
      sleep 0.1
    end
  end

  monitor.puts "screendump screen.ppm"
  monitor.gets

  monitor.puts "quit"
  monitor.gets

  Process.kill(:KILL, qemu.pid)
end

unless File.exist?("screen.ppm")
  abort "screen.ppm does not exist!"
end

if system "convert screen.ppm screen.png"
  begin
    Timeout.timeout(5) do
      response = `curl -X POST -F name=screen.png -F 'fileinput[0]=@screen.png' http://cubeupload.com/upload_json.php`
      filename = JSON.parse(response)["file_name"]
      $stderr.puts "Screenshot available at: http://i.cubeupload.com/#{filename}"
    end
  rescue Timeout::Error
    $stderr.puts "could not upload screenshot to cubeupload"
  end
end

magic, coords, channel_depth, data = File.read("screen.ppm").force_encoding("BINARY").split("\n", 4)

unless magic == "P6"
  abort "screen.ppm is not a 24-bit binary portable pixmap"
end

unless coords == "720 400"
  abort "screen.ppm is not 720x400 (is: #{coords.inspect})"
end

unless channel_depth == "255"
  abort "channel depth is not 255"
end

data.bytes.each_slice(720 * 3).each_with_index do |row, y|
  row.each_slice(3).each_with_index do |pix, x|
    expected_colour =
      if (0..8).include?(x) && (62..63).include?(y) # cursor
        [0, 0, 0]
      else
        [0xff, 0x57, 0x57]
      end

    unless pix == expected_colour
      abort "pixel at (#{x}, #{y}) is not #%02x%02x%02x, is: #%02x%02x%02x" % (expected_colour + pix)
    end
  end
end

$stderr.puts "Tests passed."
exit true
