# frozen_string_literal: true

require 'yaml'
# Main game class
class Game
  @@STATUS = { guess_letter: 0, guess_word: 1, won: 3, lost: 4, quit: 5 }.freeze

  def clear_screen
    puts "\e[H\e[2J"
  end

  def random_word
    possible_words = File.open('google-10000-english-no-swears.txt', 'r').readlines.map(&:chomp)
    possible_words.sample.upcase
  end

  def read_stage_drawings(drawing_path)
    file = File.open(drawing_path, 'r')
    if file
      lines = file.readlines
      n_drawings = lines[0].to_i
      drawing_height = (lines.length - 1) / n_drawings
      drawings = []
      (0...n_drawings).each do |stage|
        start_index = 1 + stage * drawing_height
        end_index = start_index + drawing_height
        drawings.push(lines[start_index...end_index])
      end
      drawings
    else
      puts('Error: file not found')
      exit(1)
    end
  end

  def print_hangman(stage)
    puts @stage_drawings[stage]
  end

  def concealed_word
    @secret_word.map { |letter| @guessed_letters.include?(letter) || letter == ' ' ? letter : '_' }.join(' ')
  end

  def won?
    @secret_word.uniq.all? { |letter| @guessed_letters.include?(letter) }
  end

  def save_game(name)
    file = File.new(name, 'w')
    save_hash = {
      secret_word: @secret_word,
      guessed_letters: @guessed_letters,
      current_stage: @current_stage,
      wrong_letters: @wrong_letters
    }
    file.write YAML.dump(save_hash)
    file.close
  end

  def load_game(name)
    file = File.open(name, 'r')
    data = YAML.load(file.read)
    @secret_word = data[:secret_word]
    @guessed_letters = data[:guessed_letters]
    @current_stage = data[:current_stage]
    @wrong_letters = data[:wrong_letters]
  end

  def write_head
    clear_screen
    print_hangman(@current_stage)
    puts concealed_word
  end

  def execute_guess_word_status
    write_head
    puts 'What word do you guess?'
    word = gets.chomp.upcase
    word == @secret_word ? @@STATUS[:won] : @@STATUS[:lost]
  end

  def execute_won_status
    write_head
    puts 'YOU WON!!!'
    @@STATUS[:quit]
  end

  def execute_lost_status
    write_head
    puts 'You lost :('
    puts "The word was #{@secret_word.join}"
    @@STATUS[:quit]
  end

  def execute_guess_letter_status
    write_head
    puts "Wrong guesses: #{@wrong_letters.sort.join(', ')}" unless @wrong_letters.empty?
    puts 'Guess a letter, ! to guess a word, $ to save, @ to quit'
    input_char = gets.chomp.upcase
    return @@STATUS[:guess_letter] if input_char.length > 1

    case input_char
    when '!'
      puts 'Guess the word:'
      guessed_word = gets.upcase.chomp
      return guessed_word == @secret_word.join ? @@STATUS[:won] : @@STATUS[:lost]
    when '$'
      puts 'Name for the save?'
      name = gets.chomp
      save_game(name)
      return @@STATUS[:guess_letter]
    when '@'
      return @@STATUS[:quit]
    end
    @@STATUS[:guess_letter] if @guessed_letters.include?(input_char)

    @guessed_letters.push(input_char)
    if @secret_word.include?(input_char)
      if won?
        @@STATUS[:won]
      else
        @@STATUS[:guess_letter]
      end
    else
      @current_stage += 1
      if @current_stage == @n_stages - 1
        @@STATUS[:lost]
      else
        @wrong_letters.push(input_char)
        @@STATUS[:guess_letter]
      end
    end
  end

  def initialize(drawing_path = 'draw.txt')
    @stage_drawings = read_stage_drawings(drawing_path)
    @n_stages = @stage_drawings.length
    puts 'Do you want to load a game? (y,n)'
    if gets.chomp == 'y'
      puts 'Filename:'
      filename = gets.chomp
      load_game(filename)
    else
      @secret_word = random_word.chars
      @guessed_letters = []
      @current_stage = 0
      @wrong_letters = []
    end
    @current_status = @@STATUS[:guess_letter]
  end

  def start
    clear_screen
    while @current_status != @@STATUS[:quit]
      @current_status =
        case @current_status
        when @@STATUS[:guess_letter]
          execute_guess_letter_status
        when @@STATUS[:guess_word]
          execute_guess_word_status
        when @@STATUS[:won]
          execute_won_status
        when @@STATUS[:lost]
          execute_lost_status
        end
    end
  end
end

game = Game.new
game.clear_screen
game.start
