(1..799).each do |i|
  input = File.read("chinese/chinese#{i}.txt")
  input.gsub! "“", "『"
  input.gsub! "”", "』"
  input.gsub! "‘", "『"
  input.gsub! "’", "』"
  input.gsub! "，", "、"
  File.open("chinese/quo/chinese#{i}.txt", 'w') {|f| f.write input}
end
