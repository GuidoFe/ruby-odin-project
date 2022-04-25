# frozen_string_literal: true

def stock_picker(prices)
  best_diff = -1
  buy_day = -1
  sell_day = -1
  prices[0..-2].each_with_index do |buy_price, buy_index|
    ((buy_index + 1)...prices.length).each do |sell_index|
      sell_price = prices[sell_index]
      new_diff = sell_price - buy_price
      next if new_diff < best_diff

      best_diff = new_diff
      buy_day = buy_index
      sell_day = sell_index
    end
  end
  [buy_day, sell_day]
end

p stock_picker([17, 3, 6, 9, 15, 8, 6, 1, 10])
