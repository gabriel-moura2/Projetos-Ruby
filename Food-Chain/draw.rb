# frozen_string_literal: true

require 'ruby2d'

module Game
  PIXEL = 20
  WIDTH = 30
  HEIGHT = 30
end

class Figure
  attr_accessor :id

  def initialize(kwargs)
    @circle = Circle.new radius: Conf::PIXEL / 2
    update(**kwargs)
  end

  def update(x_pos:, y_pos:, color: @circle.color)
    @circle.x = x_pos * Conf::PIXEL + Conf::PIXEL / 2
    @circle.y = y_pos * Conf::PIXEL + Conf::PIXEL / 2
    @circle.color = color
  end

  def remove
    @circle.remove
  end

  def to_s
    "#{@circle.x}, #{@circle.y}, #{@circle.color}"
  end
end

class NFigure
  include Enumerable

  def initialize
    @figures = []
  end

  def each(&block)
    @figures.each(&block)
  end

  def insert(obj)
    obj.id = take_id unless obj.is_a? Array

    case obj.class
    when Figure
      @figures << obj
    when Array
      obj.each { |o| insert(o) }
    end
  end

  def remove(obj)
    r = get_by_id(obj.id) unless obj.is_a? Array

    case r.class
    when Figure
      r.remove
      @figure.delete(r)
    when Array
      obj.each { |o| remove(o) }
    end
  end

  def get_by_id(id)
    find { |o| o.id == id }
  end

  private

  def take_id
    count.positive? ? max_by(&:id).id + 1 : 1
  end
end

set width: Conf::PIXEL * Conf::WIDTH, height: Conf::PIXEL * Conf::HEIGHT

n = NFigure.new

n.insert(Array.new(2) { Figure.new x_pos: rand(Conf::WIDTH), y_pos: rand(Conf::HEIGHT), color: 'orange' })

on :key_down do
  n.each { |d| d.update x_pos: rand(Conf::WIDTH), y_pos: rand(Conf::HEIGHT) }
end

show
