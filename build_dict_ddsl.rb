require 'tradsim'
require 'open3'
require 'base64'
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

chinese = File.readlines "chinese/hytd/chinese#{chuong}.txt"
i = 0
j = 0

chinese.each do |line|
    line.each_char do |c|
        if c =~ /\p{Han}/
            status, word = system_quietly "/usr/bin/grep ^#{c} tudien.txt"
            if not status
                d = Tradsim::to_trad(c)
                input = `/usr/bin/wget -qO- http://nguyendu.com.free.fr/hanviet/hv_timchu.php?unichar=#{d}`
                document = Nokogiri.HTML5(input)
                document.css('a').remove_attr('href')
                document.css('a').remove_attr('onmouseout')
                document.css('a').remove_attr('onmouseover')
                entry = document.css('div#dataarea').to_html

                if entry.strip.length == 0
                    p "Something wrong with #{d}"
                    j += 1
                else
                    encoded_data = Base64.strict_encode64(entry)
                    
                    tudien = File.open "tudien.txt", "a"
                    tudien.puts "#{c}#{encoded_data}"
                    tudien.close

                    i += 1
                    puts "Added #{c} - #{d}"
                end
            end
        end
    end
end

puts "Completed Chapter #{chuong}. Added #{i} new word(s). #{j} error(s) encountered!"
