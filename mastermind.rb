require 'pry-byebug'

class Game
attr_reader :role

COLORS = ["red", "yellow", "green", "blue", "white", "black"]
  
  def initialize
    @code = []
    @guess = []
    @pegs = []
  end

  def play
    choose_role
    code_breaker if role == 1
    code_maker if role == 2
  end

  def code_breaker
    generate_code
    # change to 12 rounds when code is complete
    5.times do
      round
      break if game_won?
    end
  end

  def choose_role
    puts "Enter 1 to be the code-breaker or 2 to be the code-maker."
    @role = gets.chomp.to_i
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
    @pegs.clear
    @guess.clear
    @code_clone.clear
    puts "Enter your guess:"
    @guess << gets.chomp.split(" ").flatten!
    @guess_clone = @guess.clone
  end

  def red_pegs?
    @code.each_with_index do |val, idx|
      if (@code[idx] == @guess[idx])
        @pegs << "RED"
        @code_clone[idx] = "x"
        @guess_clone[idx] = "z"
      end
    end
  end

  def white_pegs?
    @code_clone.each_with_index do |val, idx|
      if (@guess_clone.any?(val))
        @pegs << "WHITE"
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

  def round
    solicit_guess
    @code_clone = @code.clone
    give_feedback
  end

  def game_won?
    if (@pegs == ["RED", "RED", "RED", "RED"])
      puts "You win! You've guessed the code."
      return true
    end
  end
end

game = Game.new
game.play
