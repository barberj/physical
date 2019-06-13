# frozen_string_literal: true

require 'measured'

module Physical
  class Cuboid
    attr_reader :dimensions, :length, :width, :height, :weight, :id, :properties

    def initialize(id: nil, dimensions: [], weight: Measured::Weight(0, :g), properties: {})
      @id = id || SecureRandom.uuid
      @weight = Types::Weight[weight]
      @dimensions = []
      @dimensions = fill_dimensions(Types::Dimensions[dimensions])
      @length, @width, @height = *@dimensions
      @properties = properties
    end

    def volume
      Measured::Volume(dimensions.map { |d| d.convert_to(:cm).value }.reduce(1, &:*), :ml)
    end

    def ==(other)
      id == other.id
    end

    private

    def method_missing(method)
      symbolized_properties = properties.symbolize_keys
      if symbolized_properties.key?(method)
        symbolized_properties[method]
      else
        super
      end
    end

    def respond_to_missing?(method, *args)
      properties.symbolize_keys.key?(method) || super
    end

    def fill_dimensions(dimensions)
      dimensions.fill(dimensions.length..2) do |index|
        @dimensions[index] || Measured::Length(self.class::DEFAULT_LENGTH, :cm)
      end
    end
  end
end
