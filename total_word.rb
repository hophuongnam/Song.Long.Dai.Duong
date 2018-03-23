output = ""
(1..799).each do |i|
  input = File.read("chinese/quo/chinese#{i}.txt")
  input.each_char do |c|
    if c =~ /\p{Han}/
      output += c if not output.include? c
    end
  end
end

File.open("total_word.txt", 'w') {|f| f.write output}
