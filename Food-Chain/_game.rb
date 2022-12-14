# frozen_string_literal: true

require 'ruby2d'

module Conf
  PIXEL = 20
  WIDTH = 30
  HEIGHT = 30
end

##
# Classe para representar a posição dos objetos
class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def +(other)
    Point.new(x + other.x, y + other.y)
  end

  def -(other)
    Point.new(x - other.x, y - other.y)
  end

  def ==(other)
    x == other.x && y == other.y
  end

  def inside?(point_min, point_max)
    x.between?(point_min.x, point_max.x) && y.between?(point_min.y, point_max.y)
  end

  def to_s
    "#{x}, #{y}"
  end
end

##
# Super classe das classes do jogo
class GameObject
  attr_reader :point

  def initialize(point, color)
    @point = point
    @circle = Circle.new radius: Conf::PIXEL / 2, color: color
    update
  end

  def update
    @circle.x = @point.x * Conf::PIXEL + Conf::PIXEL / 2
    @circle.y = @point.y * Conf::PIXEL + Conf::PIXEL / 2
  end

  def delete
    @circle.remove
  end
end

##
# Classe para representar as plantas
class Plant < GameObject
  def initialize(point)
    super point, 'green'
  end
end

##
# Classe para representar cervos
class Deer < GameObject
  attr_reader :point

  def initialize(point)
    super point, 'orange'
    @escape = false
  end

  def move(direction)
    directions = {
      left: Point.new(-1, 0),
      right: Point.new(1, 0),
      up: Point.new(0, -1),
      down: Point.new(0, 1)
    }
    @point += directions[direction] unless @escape || yield(point + directions[direction])
  end

  def escape!
    @escape = @escape ? false : true
  end

  def update
    @circle.color = @escape ? 'gray' : 'orange'
    super
  end
end

##
# Classe para manipular o jogo
class Game
  def initialize
    @plants = []
    @plants = Array.new(4) { Plant.new(point(rand(Conf::WIDTH), rand(Conf::HEIGHT))) }
    @deer = Deer.new(point(rand(Conf::WIDTH), rand(Conf::HEIGHT)))
  end

  def get_input(key)
    return unless inputs.key?(key)

    inputs[key].call do |pnt|
      !pnt.inside?(point(0, 0), point(Conf::WIDTH - 1, Conf::HEIGHT - 1))
    end
  end

  def update
    game_objects.each(&:update)

    @plants.each do |plant|
      next unless plant.point == @deer.point

      p = @plants.delete(plant)
      p.delete
      @plants << Plant.new(Point.new(rand(Conf::WIDTH), rand(Conf::HEIGHT)))
    end
  end

  private

  def inputs
    {
      'left' => ->(&block) { @deer.move :left, &block },
      'right' => ->(&block) { @deer.move :right, &block },
      'up' => ->(&block) { @deer.move :up, &block },
      'down' => ->(&block) { @deer.move :down, &block },
      'space' => proc { @deer.escape! }
    }
  end

  def point(pos_x, pos_y)
    Point.new pos_x, pos_y
  end

  def game_objects
    @plants + [@deer]
  end
end

set width: Conf::PIXEL * Conf::WIDTH, height: Conf::PIXEL * Conf::HEIGHT

g = Game.new

on :key_down do |event|
  g.get_input(event.key)
end

update do
  g.update
end

show
