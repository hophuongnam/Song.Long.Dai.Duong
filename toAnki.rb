require 'anki'
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

def getExamples(han)
    out = ""
    (1..799).each do |i|
       stat, w = system_quietly "/usr/bin/grep #{han} chinese/quo/chinese#{i}.txt"
       out += "#{w}Π" if stat
    end
    out.gsub!(/\s/, "Π")
    out.gsub! "\u3000", ""
    examples = out.split("Π")
    if examples.length > 10
        examples.delete_if { |x| x.length > 60 }
        examples.delete_if { |x| x.length < 40 }
    end
    if examples.length > 10
        example = examples.sample(10)
    else
        example = examples
    end
    if example.empty?
        example[0] = "No Example Available"
        puts "No Example Available for #{han}"
    end
    out = example.join("Π").gsub("#{han}", "<span class=hanzi>#{han}</span>")
    puts "Done for #{han}"
    return out
end

hanzi = []
(1..799).each do |i|
    File.open("chinese/quo/chinese#{i}.txt").each_char do |c|
        if c =~ /\p{Han}/
            if not hanzi.include? c
                hanzi << c
            end
        end
    end
end

puts 'Start Now!'

cards = []
queue = Queue.new
threads = []

writePerm = Queue.new
writePerm.push "y"

5.times do
    threads << Thread.new do
        loop do
            han = queue.pop
            example = getExamples(han)
            item = {"Hanzi" => han, "Example" => example}
            writeOK = writePerm.pop
            cards << item
            writePerm.push "y"
        end
    end
end

hanzi.each do |han|
    queue.push han
end

# Wait until any currently running threads have finished their current work and returned to queue.pop
while queue.num_waiting < threads.count
    sleep 1
end

headers = [ "Hanzi", "Example" ]
deck = Anki::Deck.new(card_headers: headers, card_data: cards, field_separator: "|")
deck.generate_deck(file: "Anki_DaiDuongSongLong.txt")

# Kill off each thread now that they're idle and exit
threads.each(&:exit)
Process.exit(0)

=begin
hanzi.each do |han|
    out = ""
    (1..799).each do |i|
       stat, w = system_quietly "/usr/bin/grep #{han} chinese/quo/chinese#{i}.txt"
       out += "#{w}AAA" if stat
    end
    out.gsub! "\u3000", ""
    # out.gsub! "#{han}", "<span style='color: red;'>#{han}</span>"
    examples = out.split("AAA")
    if examples.length > 10
        examples.delete_if { |x| x.length > 70 }
        examples.delete_if { |x| x.length < 40 }
    end
    if examples.length > 10
        example = examples.sample(10)
    else
        example = examples
    end
    if example.empty?
        example[0] = "No Example Available"
        puts "No Example Available for #{han}"
    end
    out = example.join("AAA").gsub("#{han}", "<span class=hanzi>#{han}</span>")
    item = {"Hanzi" => han, "Example" => out}
    cards << item

    puts "Done for #{han}"
end
=end