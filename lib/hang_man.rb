# frozen_string_literal: false

require 'json'
require 'pry-byebug'

def extract_words
  file = File.new('words.txt', 'r')
  words = []
  until file.eof?
    word = file.readline
    words.push(word) if choice_in_range?(word.length, 13, 6)
  end
  file.close
  words
end

def load_game

end

def save_game(game)

end

def count_down(message, custom_interval = 3, unique_char = nil)
  i = custom_interval
  print "#{message} -> "
  until i.zero?
    print unique_char || i
    sleep(1)
    i -= 1
  end
  puts ''
end

def display_options(option_list, prompt)
  formatted_options = ''
  option_list.each_with_index { |option, idx| formatted_options += "#{idx + 1}: #{option}   " }
  formatted_options
end

def prompt_option(option_list, prompt)
  print "\n#{prompt} "
  option_list.each_with_index do |option, idx|
    print option
    unless (option_list.length - 1).eql?(idx)
      print option_list.length.eql?(idx + 2) ? ' and ' : ', '
    end
  end
  puts ''
end

def prompt(message)
  puts message
  print "\n>> "
end

def options(option_list, prompt = 'Please choose one of the following options')
  prompt_option(option_list, prompt)
  puts "\nSelect a number corresponding to an option:"
  prompt(display_options(option_list, prompt))
  option_list[validate_option(option_list).to_i - 1]
end

def validate_option(option_list)
  choice = gets.chomp until condition?(choice, option_list)
  puts ''
  choice
end

def condition?(choice, option_list)
  return true if choice_is_number?(choice) && choice_in_range?(choice.to_i, option_list.length)
  error_message(choice_is_number?(choice) ? 'out of range' : 'must input number') unless choice.nil?
end

def choice_in_range?(choice, max_range, min_range = 1)
  return if choice.nil?

  (choice >= min_range) && (choice <= max_range)
end

def choice_is_number?(choice)
  return if choice.nil?

  choice.scan(/\d+/).length.eql?(choice.length)
end

def error_message(context)
  prompt(("Error, #{context}, please try again")) if context
end

# Game
class Game
  def initialize
    init_players
    init_words
    init_columns
    init_board
  end

  def init_players
    player = options(['Human', 'Computer'], 'What should be the setter?')
    create_players(player)
  end

  def create_players(player)
    @setter = (player.eql('Human') ? Human.new('setter') : Computer.new('setter'))
    @guesser = Human.new('guesser')
  end

  def init_board
    @board = Board.new(@columns)
  end

  def init_columns
    @columns = @current_word.length
    @guessed_word = Array.new(@columns)
  end

  def play_game
    @setter.set_correct_word
    until @board.wrong_tries.eql?(7) || @guessed_word.none { |letter| letter.nil? }
      letter = @guesser.guess_letter
      return if letter.eql?('quit')
      if @setter.word.include?(letter)
        add_correct_letter(letter)
      else
        @board.guess_was_wrong
      end
      @board.put_board
    end
  end

  def add_correct_letter(letter)
    
  end
end

class Player
  attr_reader :score, :word
  def initialize(player_type, player_mode)
    @player_type = player_type
    @player_mode = player_mode
    @score = 0
    @wrong_tries = 0
  end

  def winner(board)
    print "Congrats, #{@player_name}#{ 'the guesser could not find the word.' if player_mode.eql?('setter') }"
    puts ' You win and you gained a point'
    @score += 1
  end
end

class Human < Player
  def initialize(player_mode)
    super('Human', player_mode)
  end

  def player_name
    return @player_name if @player_name

    prompt('Human, please enter your name')
    @player_name = gets.chomp
  end

  def guess_was_wrong
    @wrong_tries += 1
  end

  def guess_letter
    prompt('Choose a (1) character to guess the code, type a single "quit" to quit (case insensitive')
    letter = nil
    validate_guess(letter)
    letter
  end

  def validate_guess(letter)
    until letter && choice_in_range?(letter.length, 1)
      letter = gets.chomp
      (are_you_sure?('quit') ? break : next) if letter.downcase.eql?('quit')
      unless letter.nil? || choice_in_range?(letter.length, 1)
        error_message('only one letter is accepted')
      end
    end
  end

  def set_correct_word
    prompt('Human (setter), please enter the secret word (between 5 and 12 characters')
    word = ''
    until choice_in_range?(word.length, 12, 5)
      word = gets.chomp
      error_message('') unless choice_in_range?(word.length, 12, 5)
    end
    @word = word
  end

  def are_you_sure?(context)
    options(['Yes', 'No'], "Are you sure you want to #{context}?").eql?('Yes')
  end
end

class Computer < Player
  def initialize(player_mode)
    super('Computer', player_mode)
  end

  def player_name
    return @player_name if @player_name

    count_down('Computer entering name')
    @player_name = "Computer_#{rand(0..999)}"
  end
  
  def set_correct_word
    words = extract_words
    @word = words[rand(0...words.length)]
    @word.slice!(-1, 2)
  end

  def are_you_sure?(context)
    options(['Yes', 'No'], "Are you sure you want to #{context}?").eql?('Yes')
  end
end

class Board
  attr_reader :columns, :wrong_tries
  def initialize(columns)
    @columns = columns
    @hang_man_limbs = ["F O\n", 'F/', '|', "\\\n", 'F/', ' \\']
    puts 'This is what the board looks like'
    put_board(6)
  end

  def put_board(limbs, guessed_word = nil)
    print positioning('__')
    puts '_'
    print positioning('  ')
    puts " \\"
    puts hang_man_guy(limbs)
    puts "\n"
    lines(guessed_word)
  end


  def show_results(setter, guesser)
    print positioning('  ')
    puts 'Points:'
    print "#{guesser.player_name} (guesser): #{guesser.player_points} "
    print positioning('   ')
    puts "#{setter.player_name} (setter): #{setter.player_points} "
  end
  
  def hang_man_guy(limbs)
    guy = positioning('  ')
    guy += "( )\n"
    add_limbs(guy, limbs)
  end

  def add_limbs(guy, limbs)
    limbs.times do |limb|
      if @hang_man_limbs[limb].include?('F')
        @hang_man_limbs[limb].slice!(0, 1)
        guy += positioning('  ')
      end
      guy += @hang_man_limbs[limb]
    end
    guy
  end

  def lines(word)
    puts ''
    word.each { |letter| print "  #{letter || ' '}  " } unless word.nil?
    puts ''
    print positioning('---  ')
    puts ''
  end

  def positioning(character)
    str = ''
    @columns.times { str += character }
    str
  end
end

puts 'Welcome to mastermind, in order to play,'
puts 'Player must choose a letter that has been'
puts 'Pre selected by the computer or human as the setter' 
puts 'can choose whether a computer or human sets'
puts 'the correct word. Human can set whatever they'
puts 'want (must be between 5 and 12 characters inclusive)'
puts 'but the computer will randomly choose their word.'
puts 'The word guesser must find all the letters before'
puts 'the stick-man figure fully appears. If the guesser'
puts 'wins, they earn a point, whereas the setter gains a '
puts 'point if the guesser loses. There are no rounds, points'
puts 'go on forever unless the guesser (always human) removes'
puts 'or overwrites a save. There is no character validation for the guesser,'
puts 'but they must only type one character per round'

Dir.mkdir('saved-games') unless Dir.exist?('saved-games')

if options(['new game', 'load existing game']).eql?('new game')
  game = Game.new
else

end

