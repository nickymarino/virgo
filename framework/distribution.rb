# frozen_string_literal: true

require 'rubystats/normal_distribution'

# Represents a random distribution of values from a minimum value
# to a maximum value. Can be either a normal or uniform distribution
#
# A Wallpaper uses a Distribution for each of the x- and y-coordinates
# of every pixel placed onto the background of the image
class Distribution
  # Creates a Distribution
  #
  # - mean is the average of random points sample from the Distribution
  # - min is the minimum possible sampled point
  # - max is the maximum possible sampled point
  # - std is the standard deviation of the sampled points
  #     If std is nil, the Distribution is uniform (any point from
  #     min to max is equally likely)
  def initialize(mean, min, max, std = nil)
    @mean = mean
    @min = min
    @max = max
    @std = std

    # Use a normal distribution if a standard deviation was
    # given
    # A nil @normal implies a uniform distribution
    @normal = Rubystats::NormalDistribution.new(@mean, @std) if @std
  end

  # Returns a uniform Distribution from a dimension
  #
  # For example, if a height of 500 is given, the returned
  # Distribution has a mean of 500/2 = 250, a minimum of 0,
  # a maximum of 500, and a std of nil (to create a uniform
  # probability)
  def self.from_dim(dimension)
    Distribution.new(dimension / 2, 0, dimension)
  end

  # Returns a random point x, @min <= x <= @max
  def random_point
    test = if @normal
             @normal.rng.round(0)
           else
             rand(@min...@max)
           end

    # Try again if the test point violates the constraints
    if (test < @min) || (test > @max)
      random_point
    else
      test
    end
  end
end
