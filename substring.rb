# frozen_string_literal: true

def substrings(word, valid_substrings)
  downcased_word = word.downcase
  valid_substrings.each_with_object({}) do |substring, hash|
    count = downcased_word.scan(substring).length
    hash[substring] = count if count.positive?
  end
end

dictionary = %w[
  below down go going horn how howdy it i low own part partner sit
  below down go going horn how howdy it i low own part partner sit
]
p substrings("Howdy partner, sit down! How's it going?", dictionary)
