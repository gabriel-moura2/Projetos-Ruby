# frozen_string_literal: true

require 'ruby2d'

module Conf
  PIXEL = 20
  WIDTH = 30
  HEIGHT = 30
end

class Draw
  attr_accessor :id

  def initialize(args)
    @circle = Circle.new radius: Conf::PIXEL / 2
    update(**args)
  end

  def update(x_pos:, y_pos:, color: @circle.color)
    @circle.x = x_pos * Conf::PIXEL + Conf::PIXEL / 2
    @circle.y = y_pos * Conf::PIXEL + Conf::PIXEL / 2
    @circle.color = color
  end
end

class NDraw
  include Enumerable

  def initialize
    @figures = []
  end

  def each(&block)
    @figures.each(&block)
  end

  def insert(obj)
    obj.id = take_id unless obj.is_a? Array

    case obj.class.name
    when 'Plant'
      @plants << obj
    when 'Deer'
      @deers << obj
    when 'Array'
      obj.each { |o| insert(o) }
    end
  end

  def remove(obj)
    r = find { |o| o.id == obj.id } unless obj.is_a? Array

    case r.class
    when Plant
      @plants.delete(r)
    when Deer
      @deers.delete(r)
    when Array
      obj.each { |o| remove(o) }
    end
  end

  private

  def take_id
    count.positive? ? max_by(&:id).id + 1 : 1
  end
end

set width: Conf::PIXEL * Conf::WIDTH, height: Conf::PIXEL * Conf::HEIGHT

n = NDraw.new

n.insert(Array.new(2) { Draw.new x_pos: rand(Conf::WIDTH), y_pos: rand(Conf::HEIGHT), color: 'orange' })

on :key_down do
  n.each { |d| d.update x_pos: rand(Conf::WIDTH), y_pos: rand(Conf::HEIGHT) }
end

show
