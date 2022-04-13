require 'pry-byebug'

module GameRules
  COLORS = %w[red yellow green blue white black].freeze

  def initial_setup
    @code = []
    @guess = []
    @pegs = []
    @rounds = 1
  end

  def clear
    @pegs.clear
    @guess.clear
    @code_clone.clear
  end

  def clone_code
    @code_clone = @code.clone
  end

  def red_pegs?
    @code.each_index do |idx|
      next unless @code[idx] == @guess[idx]

      @pegs << 'RED'
      @code_clone[idx] = 'x'
      @guess[idx] = 'z'
    end
  end

  def white_pegs?
    @code_clone.each do |val|
      next unless @guess.any?(val)

      # If same color is present in code more than once, and the guess contains that
      # color in the wrong position but only once, # of white pegs awarded = # of
      # times color present in code. To prevent this:
      @pegs << 'WHITE'
      @guess[@guess.index(val)] = 'z' if @code_clone.count(val) > @guess.count(val)
    end
  end

  def check_pegs
    red_pegs?
    white_pegs?
  end

  def display_pegs
    puts "\n#{@pegs.shuffle.join(' ')}\n "
  end

  def game_won?
    @pegs == %w[RED RED RED RED]
  end

  def game_over?
    @rounds == 13
  end

  def code_maker
    computer = CodeMaker.new
  end
end

class Game
  include GameRules

  attr_reader :role

  def initialize
    choose_role
    play
  end

  def play
    code_breaker if role == 1
    code_maker if role == 2
  end

  def choose_role
    puts 'Enter 1 to be the code-breaker or 2 to be the code-maker.'
    @role = gets.chomp.to_i
    return if role == 1 || role == 2

    puts 'Invalid entry.'
    choose_role
  end

  def code_breaker
    player = CodeBreaker.new
    player.play_rounds
  end
end

class CodeBreaker
  include GameRules

  # attr_reader :guess, :pegs

  def initialize
    initial_setup
    generate_code
  end

  def play_rounds
    until game_won? || game_over?
      clear
      solicit_guess
      clone_code
      display_pegs
      puts "You've guessed the code!" if game_won?
      @rounds += 1
      puts "Game over. You didn't guess correctly within 12 rounds." if game_over?
    end
  end

  def generate_code
    4.times { @code << COLORS.sample }
    clone_code
    # delete when code is complete
    p @code
  end

  def solicit_guess
    puts 'Enter your guess:'
    @guess << gets.chomp.split(' ')
    @guess.flatten!
  end
end

class CodeMaker
  include GameRules

  attr_reader :pegs, :initial_pegs

  def initialize
    initial_setup
    choose_code
    generate_possible_codes
    reject_numbers
    computer_guess
  end

  def computer_guess
    until game_won?
      initial_guess
      switch_code_to_guess
      eliminate_numbers unless game_won?
      repeat_guesses unless game_won?
      puts 'The computer has guessed the code.' if game_won?
    end
  end

  def choose_code
    puts 'Enter the code that you want the computer to break:'
    @code << gets.chomp.split(' ')
    @code.flatten!
    clone_code
    @original_code = @code
    p @code
  end

  def generate_possible_codes
    @possible_codes = (1111..6666).to_a
  end

  def reject_numbers
    [7, 8, 9, 0].each do |num_to_delete|
      @possible_codes.delete_if { |num| num.to_s.include?("#{num_to_delete}") }
    end
  end

  def numbers_to_colors(numbers)
    numbers.each_with_index do |val, idx|
      numbers[idx] = COLORS[val - 1]
    end
  end

  def initial_guess(guess=[1, 1, 2, 2])
    @guess = guess
    @guess_clone = @guess.clone
    numbers_to_colors(@guess)
    check_pegs
    @original_red_pegs = red_pegs_count
    @original_white_pegs = white_pegs_count
    @rounds += 1
    puts @rounds
  end

  def switch_code_to_guess
    @guess = @guess_clone
    @code = @guess
    numbers_to_colors(@code)
  end

  def eliminate_numbers
    @possible_codes.each do |possible_code|
      @guess = possible_code.to_s.split('').map(&:to_i)
      numbers_to_colors(@guess)
      @pegs.clear
      clone_code
      check_pegs
      delete_from_set?(possible_code)
      break if game_won? || game_over?
    end
  end

  def repeat_guesses
    @pegs.clear
    @code = @original_code
    @code_clone = @code.clone
    new_guess = @possible_codes[0].to_s.split('').map(&:to_i)
    initial_guess(new_guess)
  end

  def delete_from_set?(possible_code)
    @possible_codes.delete(possible_code) unless equal_pegs?
  end

  def equal_pegs?
    @original_red_pegs == red_pegs_count && @original_white_pegs == white_pegs_count
  end

  def red_pegs_count
    @pegs.count { |peg| peg == 'RED' }
  end

  def white_pegs_count
    @pegs.count { |peg| peg == 'WHITE' }
  end
end

Game.new
