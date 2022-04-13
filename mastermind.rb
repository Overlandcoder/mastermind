require 'pry-byebug'

module GameRules
  COLORS = %w[red yellow green blue white black].freeze

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

  def display_pegs
    red_pegs?
    white_pegs?
    puts "\n#{@pegs.shuffle.join(' ')}\n "
  end

  def game_won?
    @pegs == %w[RED RED RED RED]
  end

  def code_maker
    computer = CodeMaker.new
  end
end

class Game
  include GameRules

  attr_reader :role

  def initialize
    # choose_role
    play
  end

  def play
    # code_breaker if role == 1
    # code_maker if role == 2
    code_maker
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
    @code = []
    @guess = []
    @pegs = []
    generate_code
  end

  def play_rounds
    5.times do
      clear
      solicit_guess
      clone_code
      display_pegs(@guess)
      if game_won?
        puts "You've guessed the code!"
        break
      end
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
    clone_guess
  end
end

class CodeMaker
  include GameRules

  attr_reader :pegs, :initial_pegs

  def initialize
    @code = []
    @guess = []
    @pegs = []
    choose_code
    computer_guess
  end

  def computer_guess
    12.times do
      clear
      clone_code
      generate_possible_codes
      reject_numbers
      initial_guess
      switch_guess_code
      next_guess if !game_won?
      if game_won?
        puts 'The computer has guessed the code.'
        break
      end
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

  def pegs_count
    @pegs.count
  end

  def initial_guess
    @guess = [1, 1, 2, 2]
    numbers_to_colors(@guess)
    display_pegs
  end

  def switch_guess_code
    @code = @guess
  end

  def next_guess
    @possible_codes.each_with_index do |code, idx|
      @guess = code.to_s.split('').map(&:to_i)
      @guess = numbers_to_colors(@guess)
      binding.pry
      display_pegs
    end
  end
end

Game.new
