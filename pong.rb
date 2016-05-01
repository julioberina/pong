require "gosu"
include Math

class GameWindow < Gosu::Window
  def initialize
    super(800, 600)
    self.caption = "Pong"
    @player_paddle = [10, 10, 30, 10, 10, 130, 30, 130]
    @computer_paddle = [770, 10, 790, 10, 770, 130, 790, 130]
    @pong_ball = [380, 280, 10]
    @moving_up = false
    @moving_down = false
  end

  def below_boundary?; return (@player_paddle[1] > 0) end
  def above_boundary?; return (@player_paddle[5] < 600) end

  def button_down(id)
    if id == Gosu::KbW
      @moving_up = true
      @moving_down = false
    elsif id == Gosu::KbS
      @moving_up = false
      @moving_down = true
    end
  end

  def button_up(id)
    if id == Gosu::KbW or id == Gosu::KbS
      @moving_up = false
      @moving_down = false
    end
  end

  def update
    if @moving_up and below_boundary?
      1.step(7, 2) { |x| @player_paddle[x] -= 5 }
    elsif @moving_down and above_boundary?
      1.step(7, 2) { |x| @player_paddle[x] += 5 }
    end
  end

  def draw
    draw_quad(@player_paddle[0], @player_paddle[1], Gosu::Color::WHITE,
              @player_paddle[2], @player_paddle[3], Gosu::Color::WHITE,
              @player_paddle[4], @player_paddle[5], Gosu::Color::WHITE,
              @player_paddle[6], @player_paddle[7], Gosu::Color::WHITE)
    draw_quad(@computer_paddle[0], @computer_paddle[1], Gosu::Color::WHITE,
              @computer_paddle[2], @computer_paddle[3], Gosu::Color::WHITE,
              @computer_paddle[4], @computer_paddle[5], Gosu::Color::WHITE,
              @computer_paddle[6], @computer_paddle[7], Gosu::Color::WHITE)
    360.times do |n|
      draw_line(@pong_ball[0], @pong_ball[1], Gosu::Color::WHITE,
                @pong_ball[0] + (@pong_ball[2] * cos(n*PI/180)),
                @pong_ball[1] + (@pong_ball[2] * sin(n*PI/180)),
                Gosu::Color::WHITE, 0)
    end
  end
end

GameWindow.new.show
