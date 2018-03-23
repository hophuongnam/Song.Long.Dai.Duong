require 'anki'
require 'base64'
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

cards = []
File.readlines("3000_Hanzi.txt").each do |line|
    line = line.split
    hanzi, freq = line[0], line[1]
    status, output = system_quietly "grep #{hanzi} tudien.txt"
    if status
        entry = Base64.strict_decode64(output[1..-1]).force_encoding('UTF-8').encode.gsub!(/\n/, " ")
        item = {"Hanzi" => hanzi, "FrequencyRank" => freq, "Meaning" => entry}
        cards << item
    else
        puts "Cannot find #{hanzi}"
    end
end

headers = [ "Hanzi", "FrequencyRank", "Meaning" ]
deck = Anki::Deck.new(card_headers: headers, card_data: cards, field_separator: "|")
deck.generate_deck(file: "Anki_3000_Hanzi.txt")
