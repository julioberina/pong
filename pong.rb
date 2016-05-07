require "gosu"
include Math

class Array # Add math operations for vectors
  def magnitude
    result = 0
    self.length.times { |n| result += (self[n] ** 2) }
    sqrt(result)
  end
  
  def resultant vec
    result = []
    self.length.times { |n| result << ((self[n] + vec[n]) / 2.0) }
    result
  end

  def butlast # Regular array operation, returns all but the last element
    result = self.dup
    result.pop
    result
  end
end

class GameWindow < Gosu::Window
  def initialize
    super 800, 600
    self.caption = "Pong"
    @player_paddle = [10, 10, 30, 10, 10, 131, 30, 131]
    @computer_paddle = [770, 10, 790, 10, 770, 131, 790, 131]
    @pong_ball = [380, 280, 10]
    @moving = [false, false] # 0 = moving up, 1 = moving down
    @ball_v = [0, 0]
  end

  def below_boundary?; return (@player_paddle[1] > 0) end
  def above_boundary?; return (@player_paddle[5] < 600) end

  def button_down id
    if id == Gosu::KbW
      @moving[0] = true
      @moving[1] = false
    elsif id == Gosu::KbS
      @moving[0] = false
      @moving[1] = true
    end
  end

  def button_up(id)
    if id == Gosu::KbW or id == Gosu::KbS
      @moving[0] = false
      @moving[1] = false
    end
  end

  def computer_ai
    # Coming soon...
  end

  def update
    # Player paddle movement
    if @moving[0] and below_boundary?
      1.step(7, 2) { |x| @player_paddle[x] -= 5 }
    elsif @moving[1] and above_boundary?
      1.step(7, 2) { |x| @player_paddle[x] += 5 }
    end

    # Initial and recurring ball movement
    if  @ball_v == [0, 0] then @ball_v = [-5, 0] end
    2.times { |n| @pong_ball[n] += @ball_v[n] }

    # Ball-to-wall collision checking
    if @pong_ball[1] < 10 or @pong_ball[1] > 590
      @ball_v[1] = @ball_v[1] * (-1)
    elsif @pong_ball[0] < 10 or @pong_ball[0] > 790
      @ball_v[0] = @ball_v[0] * (-1)
    end

    # Ball-to-player_paddle collision checking
    if (@pong_ball[0] - @pong_ball[2]) <= @player_paddle[2] # Horizontal collision
      if @pong_ball[1] >= @player_paddle[1] and @pong_ball[1] <= (@player_paddle[1] + 60) # Vertical collision (top to middle)
        angle = (60 - (@pong_ball[1] - @player_paddle[1])) * PI / 180.0
        ball_v = [((-1) * @ball_v[0]), ((-1) * @ball_v[1])] # Invert pong ball vector
        force_v = [((ball_v.magnitude + 2) * cos(angle)), ((ball_v.magnitude + 2) * (-1) * sin(angle))]
        @ball_v = force_v.resultant ball_v
      elsif @pong_ball[1] > (@player_paddle[1] + 60) and @pong_ball[1] <= @player_paddle[5] # Vertical collision (mid to bottom)
        angle = (360 - (@pong_ball[1] - (@player_paddle[1] + 60))) * PI / 180.0
        ball_v = [((-1) * @ball_v[0]), ((-1) * @ball_v[1])] # Invert pong ball vector
        force_v = [((ball_v.magnitude + 2) * cos(angle)), ((ball_v.magnitude + 2) * sin(angle))]
        @ball_v = force_v.resultant ball_v
      end
    end

    computer_ai
    
    # Ball-to-computer_paddle collision checking
    if (@pong_ball[0] + @pong_ball[2]) >= @computer_paddle[0] # Horizontal collision
      if @pong_ball[1] >= @computer_paddle[1] and @pong_ball[1] <= (@computer_paddle[1] + 60) # Vertical collision (top to middle)
        angle = (120 + (@pong_ball[1] - @computer_paddle[1])) * PI / 180.0
        ball_v = [((-1) * @ball_v[0]), ((-1) * @ball_v[1])] # Invert pong ball vector
        force_v = [((ball_v.magnitude + 2) * cos(angle)), ((ball_v.magnitude + 2) * (-1) * sin(angle))]
        @ball_v = force_v.resultant ball_v
      elsif @pong_ball[1] > (@computer_paddle[1] + 60) and @pong_ball[1] <= @computer_paddle[5] # Vertical collision (mid to bottom)
        angle = (180 + (@pong_ball[1] - (@computer_paddle[1] + 60))) * PI / 180.0
        ball_v = [((-1) * @ball_v[0]), ((-1) * @ball_v[1])] # Invert pong ball vector
        force_v = [((ball_v.magnitude + 2) * cos(angle)), ((ball_v.magnitude + 2) * sin(angle))]
        @ball_v = force_v.resultant ball_v
      end
    end
  end

  def draw
    draw_quad(@player_paddle[0], @player_paddle[1], Gosu::Color::WHITE,
              @player_paddle[2], @player_paddle[3], Gosu::Color::WHITE,
              @player_paddle[4], @player_paddle[5], Gosu::Color::WHITE,
              @player_paddle[6], @player_paddle[7], Gosu::Color::WHITE) # Draw player paddle
    draw_quad(@computer_paddle[0], @computer_paddle[1], Gosu::Color::WHITE,
              @computer_paddle[2], @computer_paddle[3], Gosu::Color::WHITE,
              @computer_paddle[4], @computer_paddle[5], Gosu::Color::WHITE,
              @computer_paddle[6], @computer_paddle[7], Gosu::Color::WHITE) # Draw computer paddle
    360.times do |n| # loop that draws a circle (one line per degree)
      draw_line(@pong_ball[0], @pong_ball[1], Gosu::Color::WHITE,
                @pong_ball[0] + (@pong_ball[2] * cos(n*PI/180)),
                @pong_ball[1] + (@pong_ball[2] * sin(n*PI/180)),
                Gosu::Color::WHITE, 0)
    end
  end
end

GameWindow.new.show
