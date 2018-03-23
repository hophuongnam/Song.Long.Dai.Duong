require 'open3'
require 'nokogumbo'

def system_quietly(*cmd)
  # --> require 'open3'
  exit_status = nil  
  err = nil
  out = nil
  Open3.popen3(*cmd) do |stdin, stdout, stderr, wait_thread|
    err = stderr.gets(nil)
    out = stdout.gets(nil)
    [stdin, stdout, stderr].each{|stream| stream.send('close')}
    exit_status = wait_thread.value
  end
  exit_status == 0 ? exit_status = true : exit_status = false
  out ? out.chomp! : out = nil
  return exit_status, out
end

if ARGV[0].nil?
    p "Need Chapter Number"
    exit
end
chuong = ARGV[0]

chinese = File.readlines "chinese/chinese#{chuong}.txt"
i = 0

chinese.each do |line|
    line.each_char do |c|
        if c =~ /\p{Han}/
            status, word = system_quietly "/usr/bin/grep ^#{c} hanviet.txt"
            if not status
                input = `/usr/bin/wget -qO- http://nguyendu.com.free.fr/hanviet/hv_timchu.php?unichar=#{c}`
                document = Nokogiri.HTML5(input)
                entry = document.css('font[color="darkblue"]')[1].text.strip

                entry = "NA" if entry.length == 0

                tudien = File.open "hanviet.txt", "a"
                tudien.puts "#{c}#{entry}"
                tudien.close

                i += 1
                puts "Added #{c}"
            end
        end
    end
end

puts "Completed Chapter #{chuong}. Added #{i} new word(s)."
