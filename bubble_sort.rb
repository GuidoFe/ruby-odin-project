# frozen_string_literal: true

def bubble_sort_rec(list, end_index)
  (0..end_index).each do |i|
    list[i], list[i + 1] = list[i + 1], list[i] if list[i] > list[i + 1]
  end
  end_index.zero? ? list : bubble_sort_rec(list, end_index - 1)
end

def bubble_sort(list)
  bubble_sort_rec(list, list.length - 2)
end

p bubble_sort([4, 3, 78, 2, 0, 2])
