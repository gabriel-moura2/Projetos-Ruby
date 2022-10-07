# frozen_string_literal: true

require 'neural-network'
require 'ruby2d'

module Conf
  PIXEL = 40
  WIDTH = 25
  HEIGHT = 25
end

##
# Classe para representar a posição dos objetos
class Point
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

  def x
    Conf::PIXEL * @x + Conf::PIXEL / 2
  end

  def y
    Conf::PIXEL * @y + Conf::PIXEL / 2
  end

  def distance(other)
    Math.sqrt((other.x - x)**2 + (other.y - y)**2)
  end

  def to_s
    "#{x}, #{y}"
  end
end

##
# Superclasse para representar os objetos
class GameObject
  def initialize(point, figure)
    @point = point
    @figure = figure
    @brain = nil
  end

  def update; end

  def draw
    @figure.x = @point.x
    @figure.y = @point.y
  end
end

##
# Classe para representar as plantas
class Plant < GameObject
  def initialize(point)
    super point, Circle.new(radius: Conf::PIXEL / 2, color: 'green')
  end
end

##
# Classe para representar cervos
class Deer < GameObject
  def initialize(point, brain = nil)
    super point, Circle.new(radius: Conf::PIXEL / 2, color: 'blue')
    @brain = NeuralNetwork.new([6, 6, 5]) unless brain
  end
end

##
# Classe para representar leões
class Lion < GameObject
  def initialize(point, brain = nil)
    super point, Circle.new(radius: Conf::PIXEL / 2, color: 'red')
    @brain = NeuralNetwork.new([6, 6, 4]) unless brain
  end
end

##
# Classe para representar a regra de negócio
class Game
  def initialize
    @gameobjects = []
    @gameobjects << Deer.new(Point.new(rand(Conf::WIDTH), rand(Conf::HEIGHT)))
  end

  def update
    @gameobjects.each(&:update)
  end

  def draw
    @gameobjects.each(&:draw)
  end
end

g = Game.new

set width: Conf::PIXEL * Conf::WIDTH, height: Conf::PIXEL * Conf::HEIGHT

update do
  g.update
  g.draw
end

show
