require 'pry-byebug'

module GameRules
  def code_breaker
    player = CodeBreaker.new
    generate_code
    # change to 12 rounds when code is complete
    5.times do
      play_round
      break if game_won?
    end
  end

  def clear
    @pegs.clear
    @code_clone.clear
  end

  def red_pegs?
    @code.each_with_index do |val, idx|
      if (@code[idx] == @guess[idx])
        @pegs << "RED"
        @code_clone[idx] = "x"
        @guess_clone[idx] = "z"
        p @code_clone
      end
    end
  end

  def white_pegs?
    @code_clone.each_with_index do |val, idx|
      if (@guess_clone.any?(val))
        # If same color is present in code more than once, and guess contains that
        # color in the wrong position but only once, # of white pegs awarded = # of
        # times color present in code. To prevent this:
        if @code_clone.count(val) > @guess_clone.count(val) 
          @pegs << "WHITE"
          @guess_clone[@guess_clone.index(val)] = "z"
        else
          @pegs << "WHITE"
        end
      end
    end
  end

  def give_feedback
    red_pegs?
    white_pegs?
    puts " "
    puts @pegs.shuffle.join(" ")
    puts " "
  end

  def game_won?
    if (@pegs == ["RED", "RED", "RED", "RED"])
      puts "You win! You've guessed the code."
      return true
    end
  end

  def code_maker
    choose_code

    12.times do
      clear
      @code_clone = @code.clone
      computer_guess
      break if game_won?
    end
  end
end

class Game
include GameRules
include Display

attr_reader :role, :pegs

COLORS = ["red", "yellow", "green", "blue", "white", "black"]
  
  def initialize
    @code = []
    @pegs = []
  end

  def play
    choose_role
    code_breaker if role == 1
    code_maker if role == 2
  end

  def choose_role
    puts "Enter 1 to be the code-breaker or 2 to be the code-maker."
    @role = gets.chomp.to_i
    if !((@role == 1) || (@role == 2))
      puts "Invalid entry."
      choose_role
    end
  end 
end

class CodeBreaker
include GameRules
include Display

attr_reader :guess

  def initialize
    @guess = []
  end

  def play_round
    clear
    player.solicit_guess
    @code_clone = @code.clone
    give_feedback
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
    puts "Enter your guess:"
    @guess << gets.chomp.split(" ")
    @guess.flatten!
    @guess_clone = @guess.clone
  end
  
end

class CodeMaker
include GameRules
include Display

def choose_code
  puts "Enter the code that you want the computer to break:"
  @code << gets.chomp.split(" ")
  @code.flatten!
  @code_clone = @code.clone
  p @code
end

def computer_guess
  first_level
end

def first_level(n = 0)
  4.times { @guess << COLORS[n] }
  p @guess
  @guess_clone = @guess.clone
  if pegs == 0
    clear
    first_level(n + 1)
  end
  give_feedback
  second_level(n) unless game_won?
end

def second_level(n)
  n = n + 1
  (4 - pegs.count).times { @guess << COLORS[n] }
  p @guess
  @guess_clone = @guess.clone
  if !(count_pegs > pegs.count)
    clear
    second_level(n + 1)
  end
  give_feedback
end
end

game = Game.new
game.play
