chuong = ARGV[0]
input = File.read("chinese/quo/chinese#{chuong}.txt")
output = ""
input.each_char do |c|
  if c =~ /\p{Han}/
    output += c if not output.include? c
  end
end

output += "。『』「」、‧《》〈〉？；：（）！，﹁﹂﹃﹄"
File.open("font/text/chuong#{chuong}", 'w') {|f| f.write output}
