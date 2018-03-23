require 'nokogiri'
require 'json'

tudien = JSON.parse(File.read("tudien.json")); nil

tudien.dup.each do |k, v|
    if k.length != 1
        v.gsub! "\n", ""
        document = Nokogiri.HTML v
        dataArea = document.css("div#dataarea")
        entry = dataArea.at_css('font[color="darkblue"]')
        han = entry.text.split(" ")[0]
        entry.remove_attribute "size"
        entry.remove_attribute "color"
        entry.name = "span"        
        entry.previous = "<font size='6' color='darkblue'>#{han}</font>"
        entry.previous = "<br>"
        entry.content = entry.content.gsub(han, "").strip
        tudien[k] = dataArea.to_html
    end
end

=begin
tudien.dup.each do |k, v|
    document = Nokogiri.HTML v
    dataArea = document.css("div#dataarea")
    atag = dataArea.css("a")
    atag.each do |a|
        if a.content.length == 1 and a.content =~ /\p{Han}/
            unless tudien.has_key? a.content
                input = `/usr/bin/wget -qO- http://nguyendu.com.free.fr/hanviet/hv_timchu.php?unichar=#{a.content}`
                input.gsub! "\xEF\xBB\xBF", ""
                document = Nokogiri.HTML(input)
                dataArea = document.css("div#dataarea")
                next if dataArea.empty?
                tudien[a.content] = dataArea.to_html
                puts "Finished #{a.content}"
            end
        end
        if a.content.length != 1 and a.content.include? "["
            unless tudien.has_key? a.content
                input = `/usr/bin/wget -qO- http://nguyendu.com.free.fr/hanviet/#{a['href']}`
                input.gsub! "\xEF\xBB\xBF", ""
                document = Nokogiri.HTML(input)
                dataArea = document.css("div#dataarea")
                next if dataArea.empty?
                tudien[a.content] = dataArea.to_html
                puts "Finished #{a.content}"
            end
        end
    end
end
=end
File.open("tudien.new.json", "w") {|f| f.write tudien.to_json}