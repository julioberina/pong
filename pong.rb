require "gosu"

class Paddle < Gosu::Window
  def initialize(x, y, width, height)
    @pos = [x, y, (x+width), y, x, (y+height), (x+width), (y+height)]
    @moving_up = false
    @moving_down = false
  end

  def move_up
    @moving_up = true
    @moving_down = false
  end

  def move_down
    @moving_up = false
    @moving_down = true
  end

  def stop_moving
    @moving_up = false
    @moving_down = false
  end

  def move
    if @moving_up == true
      1.step(7, 2) { |x| @pos[x] -= 1 }
    elsif @moving_down == true
      1.step(7, 2) { |x| @pos[x] += 1 }
    end
  end
  
  def draw_to_screen
    draw_quad(@pos[0], @pos[1], Gosu::Color::WHITE, @pos[2], @pos[3], Gosu::Color::WHITE,
              @pos[4], @pos[5], Gosu::Color::WHITE, @pos[6], @pos[7], Gosu::Color::WHITE)
  end
end

class GameWindow < Gosu::Window
  def initialize
    super(800, 600)
    self.caption = "Gosu Tutorial Game"
    @player_paddle = Paddle.new(10, 10, 20, 120)
    @computer_paddle = Paddle.new(770, 10, 20, 120)
  end

  def update
    @player_paddle.move
    @computer_paddle.move
  end

  def button_down(id)
    if id == Gosu::KbW
      @player_paddle.move_up
    elsif id == Gosu::KbS
      @player_paddle.move_down
    end
  end

  def button_up(id)
    if id == Gosu::KbW or id == Gosu::KbS
      @player_paddle.stop_moving
    end
  end

  def draw
    @player_paddle.draw_to_screen
    @computer_paddle.draw_to_screen
  end
end

GameWindow.new.show
