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

  def get_angle
    atan((self[1] * -1) / self[0].to_f) * 180 / Math::PI
  end
end

class GameWindow < Gosu::Window
  def initialize
    super 800, 600
    self.caption = "Pong"
    @player_paddle = [10, 10, 30, 10, 10, 130, 30, 130]
    @computer_paddle = [770, 60, 790, 60, 770, 180, 790, 180]
    @pong_ball = [380, 280, 10]
    @moving = [false, false] # 0 = moving up, 1 = moving down
    @active = [false, false] # 0 = moving up, 1 = moving down
    @ball_v = [0, 0]
    @pscore = 0
    @cscore = 0
    @player_score = Gosu::Image.from_text(self, @pscore.to_s, Gosu.default_font_name, 45)
    @computer_score = Gosu::Image.from_text(self, @cscore.to_s, Gosu.default_font_name, 45)
  end

  def below_boundary?; return (@player_paddle[1] > 0) end
  def above_boundary?; return (@player_paddle[5] < 600) end
  def below_surface?; return (@computer_paddle[1] > 0) end
  def above_surface?; return (@computer_paddle[5] < 600) end
  
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
    if @active[0] and below_surface?
      1.step(7, 2) { |x| @computer_paddle[x] -= 5 }
    elsif @active[1] and above_surface?
      1.step(7, 2) { |x| @computer_paddle[x] += 5 }
    end

    # Computer paddle tracks ball movement
    if (@computer_paddle[1] + 60) > @pong_ball[1]
      # Move up
      @active[0] = true
      @active[1] = false
    elsif (@computer_paddle[1] + 60) < @pong_ball[1]
      # Move down
      @active[0] = false
      @active[1] = true
    else
      # Stand still
      @active[0] = false
      @active[1] = false
    end
  end

  def update
    # Player paddle movement
    if @moving[0] and below_boundary?
      1.step(7, 2) { |x| @player_paddle[x] -= 5 }
    elsif @moving[1] and above_boundary?
      1.step(7, 2) { |x| @player_paddle[x] += 5 }
    end

    computer_ai

    # Initial and recurring ball movement
    if @ball_v == [0, 0]
      angle = rand(241)
      if angle >= 0 and angle < 120 then angle -= 60 end
      @ball_v = [(5 * (cos(angle * Math::PI / 180.0))), (5 * (sin(angle * Math::PI / 180.0)))]
    end

    # Check for low magnitude vectors
    if @ball_v != [0, 0] and @ball_v.magnitude < 5
      @ball_v = [(5 * cos(@ball_v.get_angle)), (5 * sin(@ball_v.get_angle))]
    end

    2.times { |n| @pong_ball[n] += @ball_v[n] }

    # Ball-to-wall collision checking
    if @pong_ball[1] < 10 or @pong_ball[1] > 590
      @ball_v[1] = @ball_v[1] * (-1)
    elsif @pong_ball[0] < 5 # Computer scores
      @cscore += 1
      @ball_v = [0, 0]
    elsif @pong_ball[0] > 795 # Player scores
      @pscore += 1
      @ball_v = [0, 0]
    end

    # Ball-to-player_paddle collision checking
    if (@pong_ball[0] - @pong_ball[2]) <= @player_paddle[2] # Horizontal collision
      if @pong_ball[1] >= @player_paddle[1] and @pong_ball[1] <= @player_paddle[5] # Vertical collision
        angle = (@pong_ball[1] - @player_paddle[1] - 60) * PI / 180.0 # Get angle of deflection in radians
        ball_v = [((-1) * @ball_v[0]), ((-1) * @ball_v[1])] # Invert pong ball vector
        force_v = [((ball_v.magnitude + 2) * cos(angle)), ((ball_v.magnitude + 2) * sin(angle))] # Calculate force vector
        @ball_v = force_v.resultant ball_v # average out the ball and force vector
      end
    end
    
    # Ball-to-computer_paddle collision checking
    if (@pong_ball[0] + @pong_ball[2]) >= @computer_paddle[0] # Horizontal collision
      if @pong_ball[1] >= @computer_paddle[1] and @pong_ball[1] <= @computer_paddle[5] # Vertical collision
        angle = (@pong_ball[1] - @computer_paddle[1] + 120.0) * PI / 180.0 # Get angle of deflection in radians
        ball_v = [((-1) * @ball_v[0]), ((-1) * @ball_v[1])] # Invert pong ball vector
        force_v = [((ball_v.magnitude + 2) * cos(angle)), ((ball_v.magnitude + 2) * sin(angle))] # Calculate force vector
        @ball_v = force_v.resultant ball_v # average out the ball and force vector
      end
    end

    # Scoreboard update
    if @pong_ball[0] < 5
      @player_score = Gosu::Image.from_text(self, @pscore.to_s, Gosu.default_font_name, 45)
      @computer_score = Gosu::Image.from_text(self, @cscore.to_s, Gosu.default_font_name, 45)
      @pong_ball = [380, 280, 10]
    elsif @pong_ball[0] > 795
      @player_score = Gosu::Image.from_text(self, @pscore.to_s, Gosu.default_font_name, 45)
      @computer_score = Gosu::Image.from_text(self, @cscore.to_s, Gosu.default_font_name, 45)
      @pong_ball = [380, 280, 10]
    end
  end

  def draw
    @player_score.draw(60.0, 10.0, 0) # Draw player score
    @computer_score.draw(720.0, 10.0, 0) # Draw computer score
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
