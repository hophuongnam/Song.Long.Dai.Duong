require 'open3'
require 'oga'
require 'base64'
require 'json'
require 'chinese_pinyin'

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

chinese_doc = Oga.parse_xml(File.read("chinese/quo/chinese#{chuong}.txt"))
vietnamese_doc = Oga.parse_xml(File.read("vietnamese/vietnamese#{chuong}.txt"))

if vietnamese_doc.css('parallel').size != chinese_doc.css('parallel').size
    puts "Parallel texts mismatch. Please check Vietnamese and Chinese files"
    exit
end

result = "<br>\n"
id = 0 
chinese_doc.css('parallel').each_with_index do |paragraph, index|
    newParagraph = "<br>"
    if paragraph.text.strip == ""
        if vietnamese_doc.css('parallel')[index].text.strip != ""
            puts "Break mismatch at #{index}"
            exit
        end
        newParagraph += "<div style='text-align: center;'>&#x0272A;</div>"
        result += newParagraph
        next
    end
    paragraph.text.strip.each_char do |c|
        if not c =~ /\p{Han}/
            output = c
        else
            id += 1
            status, word = system_quietly "/usr/bin/grep ^#{c} hanviet.txt"
            word = " " if not status
            pinyin = Pinyin.t(c, tonemarks: true)
            output = "<ruby id='h#{id}' data-hv='#{pinyin}' data-dict='u#{c.ord.to_s(16)}'>#{c}<rt>#{word[1..-1].split(',')[0]}</rt></ruby>"            
        end
        newParagraph += output
    end
    trans = vietnamese_doc.css('parallel')[index].text.strip.gsub("\n", "<br>")
    trans = Base64.strict_encode64 trans
    newParagraph += "<span data-vietnamese='#{trans}'>&#x02729;</span><br>\n"
    result += newParagraph
end

result += "<div id='chapter-number' style='display: none;' data-chapter='#{chuong}'></div>"

dict = {}
chinese_doc.css('parallel').each do |paragraph|
    paragraph.text.strip.each_char do |c|
        if c =~ /\p{Han}/
            status, word = system_quietly "/usr/bin/grep ^#{c} tudien.txt"
            if status
                dict[ "u#{c.ord.to_s(16)}" ] = word[1..-1] if not dict.has_key?( "u#{c.ord.to_s(16)}" )
            else
                puts "No dictionary entry found for #{c}. Did you forget to build the dictionary for this chapter?"
            end
        end
    end
end

dictionary_data = dict.to_json

font = File.read("font/NotoSerifCJKsc-Regular-#{chuong}.otf").strip
fontbase64 = Base64.strict_encode64 font

output = File.read "template.html"
output.gsub! "TITLEWILLBEHERE", "Dai Duong Song Long #{chuong}"
output.gsub! "FONTBASE64WILLBEHERE", fontbase64
output.gsub! "CONTENTWILLBEHERE", result
output.gsub! "DICTIONARYWILLBEHERE", dictionary_data

File.open("website/pinyin_chuong#{chuong}.html", "w") {|f| f.write output}
