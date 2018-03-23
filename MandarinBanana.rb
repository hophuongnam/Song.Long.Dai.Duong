require 'anki'
require 'open3'
require 'base64'

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

cards = []
File.readlines("3000_Hanzi.txt").each do |line|
    line = line.split
    hanzi = line[0]

    status, output = system_quietly "grep ^#{hanzi} hanviet.txt"
    if status
        hanviet = output[1..-1]
    else
        puts "Cannot find #{hanzi} in hanviet.txt"
        next
    end

    status, output = system_quietly "grep ^#{hanzi} tudien.txt"
    if status
        entry = Base64.strict_decode64(output[1..-1]).force_encoding('UTF-8').encode.gsub!(/\n/, " ")
        bothu = entry[19..100].split()[0..3].join(" ")
    else
        puts "Cannot find #{hanzi} in tudien.txt"
        bothu = "N/A"
    end

    status, output = system_quietly "node hanzi_decompose.js #{hanzi}"
    decompose = output.split("\n")[-1].split(",").join(" ")

    status, output = system_quietly "grep ^#{hanzi} MandarinBanana.txt"
    if status        
        entry = output.split("\t")[2][1..-2].gsub '""', '"'
        item = {"hanzi" => hanzi, "hanviet" => hanviet, "bothu" => bothu, "decompose" => decompose, "strokeorder" => entry}
        cards << item
    else
        puts "Cannot find #{hanzi} in MandarinBanana.txt"
    end
end

headers = [ "hanzi", "hanviet", "bothu", "decompose", "strokeorder" ]
deck = Anki::Deck.new(card_headers: headers, card_data: cards)
deck.generate_deck(file: "Anki_Mandarin_Banana_3000.txt")
