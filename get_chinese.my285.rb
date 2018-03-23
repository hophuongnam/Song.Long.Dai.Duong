require 'nokogumbo'
require 'iconv'
require 'open3'

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

(1..799).each do |i|
    chuong = "#{i}"
    chuong = "00#{i}" if i < 10    
    chuong = "0#{i}" if i < 100 and i > 9

    uri = "http://www.my285.com/wuxia/huangyi/dtslz/#{chuong}.htm"
    status, input = system_quietly "/usr/bin/wget -qO- #{uri}"
    if status
        input = Iconv.new("UTF-8","gb18030").iconv(input)

        document = Nokogiri.HTML5(input)

        title = document.css('td[height="50"]').text
        title.gsub! /[[:space:]]+/, "\u3000"
        title = "<br>\u3000\u3000#{title}\u3000<br>"

        raw = document.css('td[colspan="2"]')[2].text.strip

        content = ""
        raw.each_line do |line|
            line.strip!
            content = "#{content}<br>#{line}<br>\n"
        end

        File.open("chinese/my285/chinese#{chuong}.txt", 'w') do |f|
            f.puts title
            f.write content
        end
        puts "Completed Chapter #{chuong}"
    else
        puts "ERROR Loading Chapter #{chuong}"
    end
end
