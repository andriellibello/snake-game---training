require 'ruby2d'

BACKGROUND_COLORS = ["black", "yellow", "red", "blue", "purple", "green"]
set background: BACKGROUND_COLORS.sample, title: 'snake'

set fps_cap: 20
SQUARE_SIZE = 20
GRID_WIDHT = Window.width / SQUARE_SIZE
GRID_HEIGHT = Window.height / SQUARE_SIZE
DIRECTIONS = ["down", "up", "right", "left", "s", "w", "d", "a"]
class Snake
  def initialize
    @body = [[5,5], [5,6], [5,7], [5,8]]
    @direction = DIRECTIONS.sample
    @growing = false
    @snake_stopped = false
    @start_game = false
  end

  def start_new_game
    @start_game = true
  end 

  def draw
    @body.each do |ref|
      Square.new(x: ref[0]*SQUARE_SIZE, y: ref[1]*SQUARE_SIZE, size: SQUARE_SIZE-1, color: 'white')
    end 
  end

  def move
    if @snake_stopped
      return false
    end 
    @body.shift unless @growing
    case @direction
    when 'down', 's' then
      @body.push(set_coordinates(head[0], head[1]+1))
    when 'up', 'w' then
      @body.push(set_coordinates(head[0], head[1]-1))
    when 'left', 'a' then
      @body.push(set_coordinates(head[0]-1, head[1]))
    when 'right', 'd' then
      @body.push(set_coordinates(head[0]+1, head[1]))
    end
    @growing = false
  end

  def head
    @body.last
  end

  def set_direction new_direction
    return unless can_change_direction? new_direction
    @direction = new_direction
  end

  def set_stopped
    @snake_stopped = !@snake_stopped 
  end 

  def set_coordinates x, y
    [x % GRID_WIDHT, y % GRID_HEIGHT]
  end

  def can_change_direction? new_direction
    case new_direction
    when 'down', 's' then
      @direction != 'up' || @direction != 'w'
    when 'up', 'w' then
      @direction != 'down' || @direction != 's'
    when 'left', 'a' then
      @direction != 'right' ||  @direction != 'd'
    when 'right', 'd' then
      @direction != 'left' || @direction != 'a'
    end
  end

  def grow
    @growing = true
  end

  def x
    head[0]
  end

  def y
    head[1]
  end

  def auto_hit?
    @body.length != @body.uniq.length
  end

  def stopped?
    @snake_stopped
  end 

  def game_started?
    @start_game
  end 
end

class Match
  def initialize
    @score = 0
    @ball_x = rand(GRID_WIDHT)
    @ball_y = rand(GRID_HEIGHT)
    @finished = false
  end

  def draw_stopped_text 
    Text.new("                           Press SPACE to return new game")
  end 

  def draw_start_game_text
    Text.new("Press ENTER to star a new game")
  end 

  def draw
    if @finished
      Text.new("Your score was: #{@score}. Press ENTER to star a new game")
    else
      Text.new("Score: #{@score}")
    end
    Square.new(x: @ball_x*SQUARE_SIZE, y: @ball_y*SQUARE_SIZE, size: SQUARE_SIZE, color: 'yellow')
  end

  def hit_ball? x, y
    @ball_x == x && @ball_y == y
  end

  def set_hit
    @score += 5
    @ball_x = rand(GRID_WIDHT)
    @ball_y = rand(GRID_HEIGHT)
  end

  def finish_game
    @finished = true
  end

  def finished?
    @finished
  end

end

snake = Snake.new
match = Match.new
update do
  clear
  if snake.game_started?
    snake.draw
    match.draw
  else 
    match.draw_start_game_text
  end 
  
  unless match.finished?
    snake.move
  end

  if match.hit_ball? snake.x, snake.y
    match.set_hit
    snake.grow
  end

  if snake.auto_hit?
    match.finish_game
  end

  if snake.stopped?
    match.draw_stopped_text
  end 
end

on :key_down do |event|
  snake.set_direction event.key if DIRECTIONS.include? event.key
  if event.key == 'space'
    snake.set_stopped
  end 

  if event.key == 'delete'
    snake = Snake.new
    match = Match.new
  end 

  if event.key == 'return'
    snake.start_new_game 
  end 
  
  if event.key == 'return' && match.finished?
    snake = Snake.new
    match = Match.new
  end
end

show