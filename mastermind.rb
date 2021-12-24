require 'pry-byebug'

class Game
attr_reader :role

COLORS = ["red", "yellow", "green", "blue", "white", "black"]
NUMBERS = [1, 2, 3, 4, 5, 6]
  
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
      play_round
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
    puts "Enter your guess:"
    @guess << gets.chomp.split(" ")
    @guess.flatten!
    @guess_clone = @guess.clone
  end

  def clear
    @pegs.clear
    @guess.clear
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
        # if same color is present in code more than once, and guess contains that
        # color in the wrong position but only once, # of white pegs awarded = # of
        # times color present in code. to prevent this:
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

  def play_round
    clear
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

  def code_maker
    choose_code

    12.times do
      clear
      computer_guess
      @code_clone = @code.clone
      give_feedback
      break if game_won?
    end
  end

  def choose_code
    puts "Enter the code that you want the computer to break:"
    @code << gets.chomp.split(" ")
    @code.flatten!
    @code_clone = @code.clone
  end

  def computer_guess
    @guess = ["red", "white", "blue", "black"]
    @guess_clone = @guess.clone
  end

  def intelligence
    
  end
end

game = Game.new
game.play
