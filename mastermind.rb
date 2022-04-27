# frozen_string_literal: true

DEFAULT_N_COLORS = 6
DEFAULT_N_GUESSES = 12
DEFAULT_N_PLACES = 4
# Main class
class Game
  attr_reader :n_places

  def try_guess
    return unless @current_n_guess < @total_n_guesses

    code = input_code
    @current_n_guess += 1
    puts "#{@current_n_guess}/#{@total_n_guesses}\t#{format_code(code)} #{format_response(check_code(code))}"
    code == @correct_code
  end

  def can_guess?
    @current_n_guess < @total_n_guesses
  end

  def format_code(code)
    code.map { |value| color(value, value) }.join
  end

  def print_legend
    puts 'Legend:'
    puts (0...@n_colors).to_a.map { |value| color(value, value) }.join
    puts '● Correct color at correct position'
    puts '○ Correct color at wrong position\n'
  end

  def input_string_to_code(string)
    string.chomp.chars.map(&:to_i)
  end

  def input_code
    code = input_string_to_code(gets)
    while code.length != @n_places
      puts "You must specify #{@n_places} pins. Retry:"
      code = input_string_to_code(gets)
    end
    code
  end

  def initialize(n_colors = DEFAULT_N_COLORS, n_places = DEFAULT_N_PLACES, total_n_guesses = DEFAULT_N_GUESSES)
    @n_colors = n_colors
    @n_places = n_places
    @total_n_guesses = total_n_guesses
    @current_n_guess = 0
    @correct_code = Array.new(@n_places) { rand(n_colors) }
  end

  private

  def color(string, index)
    "\e[#{index + 31}m#{string}\e[0m"
  end

  def format_response(response)
    ('●' * response[:black]) + ('○' * response[:white])
  end

  def check_code(code)
    cloned_guess = code.clone
    cloned_correct = @correct_code.clone
    possible_whites = []
    n_blacks = 0
    cloned_guess.zip(@correct_code).each_with_index do |el, index|
      if el[0] == el[1]
        n_blacks += 1
        cloned_correct[index] = -1
      elsif cloned_correct.include?(el[0])
        possible_whites.push(el[0])
      end
    end
    n_whites = possible_whites.each_with_object({}) { |var, mem| mem[var] = mem.fetch(var, 0) + 1 }
                              .map { |color, value| [cloned_correct.count(color), value].min }
                              .sum
    { black: n_blacks, white: n_whites }
  end
end

game = Game.new
game.print_legend
loop do
  won = game.try_guess
  if won
    puts 'You won!'
    break
  elsif !game.can_guess?
    puts 'You lost! You finished your guesses.'
    puts "The answer was #{format_code(game.correct_code)}"
    break
  end
end
