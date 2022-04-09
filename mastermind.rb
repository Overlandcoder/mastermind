require 'pry-byebug'

module GameRules
  COLORS = %w[red yellow green blue white black].freeze

  def clear
    @pegs.clear
    @guess.clear
    @code_clone.clear
  end

  def red_pegs?
    @code.each_with_index do |_val, idx|
      next unless @code[idx] == @guess[idx]

      @pegs << 'RED'
      @code_clone[idx] = 'x'
      @guess_clone[idx] = 'z'
    end
  end

  def white_pegs?
    @code_clone.each_with_index do |val, _idx|
      next unless @guess_clone.any?(val)

      # If same color is present in code more than once, and the guess contains that
      # color in the wrong position but only once, # of white pegs awarded = # of
      # times color present in code. To prevent this:
      @pegs << 'WHITE'
      @guess_clone[@guess_clone.index(val)] = 'z' if @code_clone.count(val) > @guess_clone.count(val)
    end
  end

  def give_feedback
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
    player.rounds
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

  def rounds
    5.times do
      clear
      solicit_guess
      @code_clone = @code.clone
      give_feedback
      if game_won?
        puts "You've guessed the code!"
        break
      end
    end
  end

  def generate_code
    4.times do
      @code << COLORS.sample
    end
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

  attr_reader :pegs

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
    first_level
  end

  def first_level(num = 0)
    4.times { @guess << COLORS[num] }
    p @guess
    @guess_clone = @guess.clone
    if pegs.zero?
      clear
      first_level(num + 1)
    end
    give_feedback
    second_level(num) unless game_won?
  end

  def second_level(num)
    @guess.clear
    pegs.count.times { @guess << COLORS[num] }
    num += 1
    (4 - pegs.count).times { @guess << COLORS[num] }
    p @guess
    @guess_clone = @guess.clone
    give_feedback
    return unless count_pegs <= pegs.count

    clear
    second_level(num + 1)
  end
end

Game.new
