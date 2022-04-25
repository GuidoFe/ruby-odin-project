def caesar_cipher(text, factor)
  code_array = text.each_char.map do |char|
    case char
    when "a".."z"
      n = char.ord + factor
      n = n > "z".ord ? n % "z".ord + "a".ord - 1 : n
      n.chr
    when "A".."Z"
      n = char.ord + factor
      n = n > "Z".ord ? n % "Z".ord + "A".ord - 1 : n
      n.chr
    else
      char
    end
  end
  code_array.join
end

p caesar_cipher("What a string!", 5)
