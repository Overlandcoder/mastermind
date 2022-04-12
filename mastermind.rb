require 'pry-byebug'

module GameRules
  COLORS = %w[red yellow green blue white black].freeze

  def clear
    @pegs.clear
    @guess.clear
    @code_clone.clear
  end

  def red_pegs?
    @code.each_index do |idx|
      next unless @code[idx] == @guess[idx]

      @pegs << 'RED'
      @code_clone[idx] = 'x'
      @guess_clone[idx] = 'z'
    end
  end

  def white_pegs?
    @code_clone.each do |val|
      next unless @guess_clone.any?(val)

      # If same color is present in code more than once, and the guess contains that
      # color in the wrong position but only once, # of white pegs awarded = # of
      # times color present in code. To prevent this:
      @pegs << 'WHITE'
      @guess_clone[@guess_clone.index(val)] = 'z' if @code_clone.count(val) > @guess_clone.count(val)
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
    computer.begin
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
      @code_clone = @code.clone
      display_pegs
      if game_won?
        puts "You've guessed the code!"
        break
      end
    end
  end

  def generate_code
    4.times { @code << COLORS.sample }
    @code_clone = @code.clone
    # delete when code is complete
    p @code
  end

  def solicit_guess
    puts 'Enter your guess:'
    @guess << gets.chomp.split(' ')
    @guess.flatten!
    @guess_clone = @guess.clone
  end
end

class CodeMaker
  include GameRules

  attr_reader :pegs, :initial_pegs

  def initialize
    @code = []
    @guess = []
    @pegs = []
  end

  def begin
    choose_code

    12.times do
      clear
      @code_clone = @code.clone
      computer_guess
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
    @code_clone = @code.clone
    p @code
  end

  def computer_guess
    find_first_peg
  end

  def find_first_peg(num = 0)
    4.times { @guess << COLORS[num] }
    @guess_clone = @guess.clone
    display_pegs
    guess_again?(num)
    second_level(num) unless game_won?
  end

  def guess_again?(num)
    if pegs.empty?
      clear
      find_first_peg(num + 1)
    end
  end

  def second_level(num)
    (4 - pegs.count).times { @guess.pop }
    num += 1
    (4 - pegs.count).times { @guess << COLORS[num] }
    @initial_pegs = pegs.count
    @pegs.clear
    @guess_clone = @guess.clone
    display_pegs
    third_level(num)
  end

  def third_level(num)
    if initial_pegs >= pegs.count
      second_level(num)
    elsif pegs.count == 4 && !game_won?
      @guess.sample
      display_pegs
    else
      second_level(num) unless game_won?
    end
  end
end

Game.new
