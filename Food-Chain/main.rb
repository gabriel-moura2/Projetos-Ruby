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
  attr_reader :point

  def initialize(point, figure)
    @point = point
    @figure = figure
    @brain = nil
    @vision = []
  end

  def look(objects)
    @vision = []
    list = objects.sort { |x| point.distance(x.point) }
    list.delete(self)
    list[0, 2].each do |item|
      @vision << item.point.x - point.x
      @vision << item.point.y - point.y
      @vision << item.type
    end
  end

  def think
    @brain.neurons[0] = @vision
    @brain.feed_forward
    
  end

  def update; end

  def draw
    @figure.x = Conf::PIXEL * @point.x
    @figure.y = Conf::PIXEL * @point.y
  end
end

##
# Classe para representar as plantas
class Plant < GameObject
  def initialize(point)
    super point, Circle.new(radius: Conf::PIXEL / 2, color: 'green')
  end

  def look(gameobjects); end

  def think; end

  def update; end

  def type
    0
  end
end

##
# Classe para representar cervos
class Deer < GameObject
  def initialize(point, brain = nil)
    super point, Circle.new(radius: Conf::PIXEL / 2, color: 'blue')
    # @brain = NeuralNetwork.new([6, 6, 5]) unless brain
    @joke = false
  end

  def type
    1
  end
end

##
# Classe para representar leões
class Lion < GameObject
  def initialize(point, brain = nil)
    super point, Circle.new(radius: Conf::PIXEL / 2, color: 'red')
    # @brain = NeuralNetwork.new([6, 6, 4]) unless brain
  end

  def type
    3
  end
end

##
# Classe para representar a regra de negócio
class Game
  def initialize
    @gameobjects = []
    @gameobjects << Deer.new(Point.new(rand(Conf::WIDTH), rand(Conf::HEIGHT)))
    @gameobjects << Plant.new(Point.new(rand(Conf::WIDTH), rand(Conf::HEIGHT)))
    @gameobjects << Lion.new(Point.new(rand(Conf::WIDTH), rand(Conf::HEIGHT)))
    @gameobjects << Deer.new(Point.new(rand(Conf::WIDTH), rand(Conf::HEIGHT)))
  end

  def update
    @gameobjects.each { |x| x.look(@gameobjects) }
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
