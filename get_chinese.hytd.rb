require 'nokogumbo'
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

i = 0
mucluc = File.readlines("hytd_loading.txt")
mucluc.each do |chapter|
    i += 1
    next if File.file? "chinese/hytd/chinese#{i}.txt"
    status, input = system_quietly "wget -qO- #{chapter.strip}"
    if status
        document = Nokogiri.HTML5(input)

        content = document.css('div.content > p')[0].text        
        content.gsub! /\n(?!\n)/, ""
        content.gsub! /\u3000/, "U"
        content.gsub! /[[:blank:]]/, ""
        content.gsub! /U/, "\u3000"
        
        output = ""
        content.each_line do |line|
            output = "#{output}<br>\u3000\u3000#{line.strip}<br>\n"
        end

        File.open("chinese/hytd/chinese#{i}.txt", 'w') do |f|
            f.write output
        end

        puts "Completed Chapter #{i}, #{chapter.strip}"
    else
        puts "ERROR Loading Chapter #{i}, #{chapter.strip}"
    end
    sleep 5
end

