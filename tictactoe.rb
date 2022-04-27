# frozen_string_literal: true

# Class for controlling the screen


class Screen
  def symbol(value)
    case value
    when -1
      ' '
    when 0
      'X'
    when 1
      'O'
    end
  end

  def draw_grid(positions = Array.new(3, Array.new(-1)))
    grid = [' │ │ '.chars,
            '─┼─┼─'.chars,
            ' │ │ '.chars,
            '─┼─┼─'.chars,
            ' │ │ '.chars]
    positions.each_with_index do |row_array, row_index|
      row_array.each_with_index do |value, column|
        grid[row_index * 2][column * 2] = symbol(value)
      end
    end
    grid.each { |row| puts row.join }
  end
end

# The Controlling Class
class GameEngine
  def initialize(screen, current_player = rand(2))
    @screen = screen
    @current_player = current_player
    @positions = Array.new(3) {Array.new(3, -1)}
  end

  def get_coord_from_position(position)
    real_position = position - 1
    row = real_position.div(3)
    column = real_position % 3
    { row: row, col: column }
  end

  def empty?(coord)
    @positions[coord[:row]][coord[:col]] == -1
  end

  def fill_cell(player, coord)
    @positions[coord[:row]][coord[:col]] = player
  end

  def full?
    @positions.flatten.each { |val| return false if val == -1 }
    true
  end

  def next_turn
    @current_player = (@current_player + 1) % 2
  end

  def won?
    return true if @positions[@last_coord[:row]].sum.abs == 3
    return true if @positions.reduce(0) { |mem, row| mem + row[@last_coord[:col]] }.abs == 3

    if @last_coord[:row] == @last_coord[:col]
      return true if (0..2).reduce(0) { |mem, i| mem + @positions[i][i] }.abs == 3
    elsif @last_coord[:row] + @last_coord[:col] == 2
      return true if (0..2).reduce(0) { |mem, i| mem + @positions[i][2 - i] }.abs == 3
    end
    false
  end

  def play
    winner = -1
    while winner == -1
      @screen.draw_grid(@positions)
      puts "Turn of #{@screen.symbol(@current_player)}"
      puts 'Your choice:'
      choice = 0
      while choice.zero?
        choice = gets.chomp.to_i
        if choice.zero?
          puts 'Wrong input, repeat'
        else
          @last_coord = get_coord_from_position(choice)
          if empty?(@last_coord)
            fill_cell(@current_player, @last_coord)
          else
            puts 'Cell is not empty, repeat'
            choice = 0
          end
        end
      end
      winner = won? ? @current_player : -1
      next_turn
      break if full?
    end
    if full?
      puts 'Draw.'
      -1
    else
      puts "#{@screen.symbol(winner)} won!"
      winner
    end
  end
end

GameEngine.new(Screen.new).play
