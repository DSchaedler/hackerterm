def wrapped_lines(string, length)
   string.each_line.map do |l|
     l = l.rstrip
     if l.length > length
       "#{l}\n"
     else
       words = l.split ' '
       wrapped_lines_recur(words[0], words[1..], length, []).flatten
     end
   end.flatten
end

def wrapped_lines_recur(word, rest, length, aggregate)
   return aggregate if word.nil?
     
    rest[0].nil?
     aggregate << "#{word}\n"
     aggregate
   elsif ("#{word} #{rest[0]}").length > length
     aggregate << "#{word}\n"
     wrapped_lines_recur rest[0], rest[1..], length, aggregate
   elsif ("#{word} #{rest[0]}").length <= length
     next_word = ("#{word} #{rest[0]}")
     wrapped_lines_recur next_word, rest[1..], length, aggregate
   else
     log << "#{word} is too long."
     next_word = ("#{word} #{rest[0]}")
     wrapped_lines_recur next_word, rest[1..], length, aggregate
   
end
