require 'base64'
require 'nokogumbo'

entry = ""
first = 0
ARGV[0].each_char do |c|
  first += 1
  input = `/usr/bin/wget -qO- http://nguyendu.com.free.fr/hanviet/hv_timchu.php?unichar=#{c}`
  document = Nokogiri.HTML5(input)
  document.css('a').remove_attr('href')
  document.css('a').remove_attr('onmouseout')
  document.css('a').remove_attr('onmouseover')
  output = document.css('div#dataarea').to_html
  if first == 1
    entry += output
  else
    entry += "\n<hr id='scrollToHere'><div style='text-align:center;'>&#x02729;</div><hr>\n#{output}"
  end
end

tudien = File.readlines "tudien.txt"
tudien.delete_if {|entry| entry.include? ARGV[0][0]}

encoded_data = Base64.strict_encode64(entry)
tudien << "#{ARGV[0][0]}#{encoded_data}"

File.open("tudien.txt", 'w') {|f| f.puts tudien}
