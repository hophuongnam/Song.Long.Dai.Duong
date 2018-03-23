require 'open3'
require 'oga'
require 'base64'
require 'json'

if ARGV[0].nil?
    p "Need Chapter Number"
    exit
end
chuong = ARGV[0]

chinese_doc = Oga.parse_xml(File.read("chinese/quo/chinese#{chuong}.txt"))
vietnamese_doc = Oga.parse_xml(File.read("vietnamese/vietnamese#{chuong}.txt"))

if vietnamese_doc.css('parallel').size != chinese_doc.css('parallel').size
    puts "Parallel texts mismatch. Please check Vietnamese and Chinese files"
    puts "Chinese #{chinese_doc.css('parallel').size}"
    puts "Vietnamese #{vietnamese_doc.css('parallel').size}"
    exit
end

result = ""
id = 0 
chinese_doc.css('parallel').each_with_index do |paragraph, index|
    # newParagraph = "<br>"
    newParagraph = ""
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
            output = "<span class=hz>#{c}</span>"
        end
        newParagraph += output
    end
    trans = vietnamese_doc.css('parallel')[index].text.strip.gsub("\n", "<br>")
    trans = Base64.strict_encode64 trans
    # newParagraph += "<span data-vietnamese='#{trans}'>&#x02729;</span><br>\n"
    newParagraph += "<span class=vietnamese data-vietnamese='#{trans}'><img class=vi src='/comment.svg'></span><br>\n"
    newParagraph = "<div class=paragraph>#{newParagraph}</div>"
    newParagraph.gsub! "　", ""
    result += newParagraph
end

result += "<div id='chapter-number' style='display: none;' data-chapter='#{chuong}'></div>"

# font = File.read("font/NotoSerifCJKsc-Regular-#{chuong}.otf").strip
# fontbase64 = Base64.strict_encode64 font

output = File.read "sldd.template.html"
output.gsub! "TITLEWILLBEHERE", "Dai Duong Song Long #{chuong}"
# output.gsub! "FONTBASE64WILLBEHERE", fontbase64
output.gsub! "CHAPTERNUMBER", chuong
output.gsub! "CONTENTWILLBEHERE", result
File.open("/home/BitTorrent Sync/time4vps.html/sldd/sldd#{chuong}.html", "w") {|f| f.write output}
