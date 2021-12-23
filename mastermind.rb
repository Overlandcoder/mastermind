require 'pry-byebug'

class Game
  COLORS = ["red", "yellow", "green", "blue", "white", "black"]
  
  def initialize
    @code = []
    @guess = []
    @pegs = []
  end

  def play
    generate_code

      5.times do
        round
        break if game_won?
      end
  end

  def generate_code
    4.times do
      @code << COLORS.sample
    end
    p @code
    @code_clone = @code.clone
  end

  def solicit_guess
    @pegs.clear
    @guess.clear
    @code_clone.clear
    puts "Enter your guess:"
    @guess << gets.chomp.split(" ")
    @guess.flatten!
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
