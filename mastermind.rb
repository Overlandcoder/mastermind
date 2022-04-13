require 'pry-byebug'

module GameRules
  COLORS = %w[red yellow green blue white black].freeze

  def initial_setup
    @code = []
    @guess = []
    @pegs = []
    @round = 1
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
    puts "\nPegs: #{@pegs.shuffle.join(' ')}\n "
  end

  def game_won?
    @pegs == %w[RED RED RED RED]
  end

  def game_over?
    @round == 13
  end

  def code_breaker
    CodeBreaker.new
  end

  def code_maker
    CodeMaker.new
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
end

class CodeBreaker
  include GameRules

  def initialize
    initial_setup
    generate_code
    clone_code
    play_rounds
  end

  def play_rounds
    until game_won? || game_over?
      clear
      solicit_guess
      clone_code
      check_pegs
      display_pegs
      puts "You've guessed the code!" if game_won?
      @round += 1
      if game_over?
        puts "Game over. You didn't guess correctly within 12 rounds."
        puts "The code was: #{@code.join(' ')}."
      end
    end
  end

  def generate_code
    4.times { @code << COLORS.sample }
  end

  def solicit_guess
    puts 'Enter your guess:'
    puts '(Example: white red green black)' if @round == 1
    @guess << gets.chomp.split(' ')
    @guess.flatten!
    return if valid_guess?

    puts 'Invalid guess, please try again.'
    @guess.clear
    solicit_guess
  end

  def valid_guess?
    @guess.count == 4 && @guess.all? { |color| COLORS.include?(color) }
  end
end

class CodeMaker
  include GameRules

  def initialize
    initial_setup
    choose_code
    valid_code?
    generate_possible_codes
    reject_numbers
    computer_guess
  end

  def choose_code
    puts 'Enter the code that you want the computer to break:'
    puts '(Example: white red green black)'
    @code << gets.chomp.split(' ')
    @code.flatten!
    clone_code
    @original_code = @code
  end

  def valid_code?
    return if @code.count == 4 && @code.all? { |color| COLORS.include?(color) }

    puts 'Invalid code, please try again.'
    @code.clear
    choose_code
  end

  def generate_possible_codes
    @possible_codes = (1111..6666).to_a
  end

  def reject_numbers
    [7, 8, 9, 0].each do |num_to_delete|
      @possible_codes.delete_if { |num| num.to_s.include?(num_to_delete.to_s) }
    end
  end

  def computer_guess
    find_first_peg(1, 2)

    until game_won? || game_over?
      switch_code_to_guess
      eliminate_numbers unless game_won?
      new_guess unless game_won?
      puts "The computer has guessed the code in #{@round - 1} tries." if game_won?
      puts "Game over. The computer didn't guess correctly within 12 rounds." if !game_won? && game_over?
    end
  end

  def find_first_peg(num1, num2)
    until red_pegs_count >= 1 || white_pegs_count >= 1
      initial_guess([num1, num1, num2, num2])
      num1 += 2
      num2 += 2
      find_first_peg(num1, num2)
      puts "The computer guessed the code in #{@round - 1} tr#{@round - 1 == 1 ? 'y' : 'ies'}." if game_won?
    end
  end

  def initial_guess(guess)
    @pegs.clear
    @guess = guess
    @guess_clone = @guess.clone
    numbers_to_colors(@guess)
    sleep(1.5)
    puts "Round ##{@round}: The computer guesses: #{@guess.join(' ')}"
    check_pegs
    display_pegs
    @original_red_pegs = red_pegs_count
    @original_white_pegs = white_pegs_count
    @round += 1
  end

  def numbers_to_colors(numbers)
    numbers.each_with_index do |val, idx|
      numbers[idx] = COLORS[val - 1]
    end
  end

  def switch_code_to_guess
    @guess = @guess_clone
    @code = @guess
    numbers_to_colors(@code)
  end

  def eliminate_numbers
    @possible_codes.reverse_each do |possible_code|
      # To turn 1111 into array of 1's
      @guess = possible_code.to_s.split('').map(&:to_i)
      numbers_to_colors(@guess)
      @pegs.clear
      clone_code
      check_pegs
      delete_from_set?(possible_code)
      @pegs.clear
    end
  end

  def new_guess
    @pegs.clear
    @code = @original_code
    clone_code
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
