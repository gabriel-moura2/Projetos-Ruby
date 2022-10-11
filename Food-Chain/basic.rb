# frozen_string_literal: true

require 'ruby2d'
require 'neural-network'

module Conf
  PIXEL = 40
  WIDTH = 25
  HEIGHT = 25
end

##
# Classe para representar a posição dos objetos
class Point
  attr_reader :x, :y

  def initialize(position_x, position_y)
    @x = position_x
    @y = position_y
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

  def distance_to(other)
    Math.sqrt((other.x - x)**2 + (other.y - y)**2)
  end

  def to_s
    "#{x}, #{y}"
  end
end

##
# Classe para representar as plantas
class Plant
  attr_reader :point

  def initialize(point)
    @point = point
    @circle = Circle.new radius: Conf::PIXEL / 2, color: 'green'
  end

  def update
    @circle.x = @point.x * Conf::PIXEL
    @circle.y = @point.y * Conf::PIXEL
  end

  def delete
    @circle.remove
  end
end

##
# Classe para representar cervos
class Deer
  attr_reader :point

  def initialize(point)
    @point = point
    @circle = Circle.new radius: Conf::PIXEL / 2, color: 'orange'
    @escape = false
  end

  def move(direction)
    directions = {
      left: Point.new(-1, 0),
      right: Point.new(1, 0),
      up: Point.new(0, -1),
      down: Point.new(0, 1)
    }
    @point += directions[direction] unless @escape
  end

  def escape!
    @escape = @escape ? false : true
  end

  def update
    @circle.color = @escape ? 'gray' : 'orange'
    @circle.x = @point.x * Conf::PIXEL
    @circle.y = @point.y * Conf::PIXEL
  end
end

##
# Classe para manipular o jogo
class Game
  def initialize
    @plants = []
    4.times do
      @plants << Plant.new(Point.new(rand(Conf::WIDTH), rand(Conf::HEIGHT)))
    end
    @deer = Deer.new(Point.new(rand(Conf::WIDTH), rand(Conf::HEIGHT)))
  end

  def get_input key
    inputs = {
      'left' => -> { @deer.move :left },
      'right' => -> { @deer.move :right },
      'up' => -> { @deer.move :up },
      'down' => -> { @deer.move :down },
      'space' => -> { @deer.escape! }
    }
    inputs[key].call
  end

  def update
    gameobjects.each(&:update)

    @plants.each do |plant|
      if plant.point == @deer.point
        p = @plants.delete(plant)
        p.delete
        @plants << Plant.new(Point.new(rand(Conf::WIDTH), rand(Conf::HEIGHT)))
      end
    end
  end

  private

  def gameobjects
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
