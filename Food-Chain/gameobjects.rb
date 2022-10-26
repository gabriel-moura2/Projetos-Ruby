# frozen_string_literal: true

module Conf
  PIXEL = 20
  WIDTH = 30
  HEIGHT = 30
end

##
# Classe para representar a posição dos objetos
class Point
  attr_reader :x, :y

  def initialize(pos_x, pos_y)
    @x = pos_x
    @y = pos_y
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
  attr_accessor :id
  attr_reader :point

  def initialize(point, color)
    @point = point
    @color = color
  end

  def update; end

  def to_s
    "[#{@id}] position #{point} | specie #{self.class}"
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
    @color = @escape ? 'gray' : 'orange'
    super
  end
end

##
# Classe para gerenciar os objetos do jogo
class NGameObjects
  include Enumerable

  def initialize
    @plants = []
    @deers = []
    @lions = []
  end

  def each(&block)
    (@plants + @deers + @lions).each(&block)
  end

  def insert(obj)
    obj.id = take_id unless obj.is_a? Array

    a = {
      'Plant' => -> { @plants << obj },
      'Deer' => -> { @deers << obj },
      'Lion' => -> { @lions << obj },
      'Array' => -> { obj.each { |o| insert(o) } }
    }

    a[obj.class.name].call
  end

  def remove(obj)
    r = get_by_id(obj.id) unless obj.is_a? Array

    a = {
      'Plant' => -> { @plants.delete(r) },
      'Deer' => -> { @deers.delete(r) },
      'Lion' => -> { @lions.delete(r) },
      'Array' => -> { obj.each { |o| remove(o) } }
    }

    a[r.class.name].call
  end

  def get_by_id(id)
    find { |o| o.id == id }
  end

  private

  def take_id
    count.positive? ? max_by(&:id).id + 1 : 0
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

n = NGameObjects.new

n.insert(Array.new(4) { Plant.new(Point.new(rand(Conf::WIDTH), rand(Conf::HEIGHT))) })
n.insert(Deer.new(Point.new(rand(Conf::WIDTH), rand(Conf::HEIGHT))))

puts n.to_a
