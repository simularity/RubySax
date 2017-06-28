# sax.rb - The Simularity SAX Library
# Copyright 2017, Simularity, Inc.

class Alphabet

  @@cuts = { 2 => [0.0],
             3 => [-0.430727,0.430727],
             4 => [-0.67449,0,0.67449],
             5 => [-0.841621,-0.253347,0.253347,0.841621],
             6 => [-0.967422,-0.430727,0,0.430727,0.967422],
             7 => [-1.06757,-0.565949,-0.180012,0.180012,0.565949,1.06757],
             8 => [-1.15035,-0.67449,-0.318639,0,0.318639,0.67449,1.15035],
             9 => [-1.22064,-0.76471,-0.430727,-0.13971,0.13971,0.430727,0.76471,1.22064],
             10 => [-1.28155,-0.841621,-0.524401,-0.253347,0,0.253347,0.524401,0.841621, 1.28155],
             11 => [-1.33518,-0.908458,-0.604585,-0.348756,-0.114185,0.114185,0.348756,
	            0.604585,0.908458,1.33518],
             12 => [-1.38299,-0.967422,-0.67449,-0.430727,-0.210428,-1.39146e-16,0.210428,
	            0.430727,0.67449,0.967422,1.38299],
             13 => [-1.42608,-1.02008,-0.736316,-0.502402,-0.293381,-0.0965586,0.0965586,
	            0.293381,0.502402,0.736316,1.02008,1.42608],
             14 => [-1.46523,-1.06757,-0.791639,-0.565949,-0.366106,-0.180012,-2.78292e-16,
	            0.180012,0.366106,0.565949,0.791639,1.06757,1.46523],
             15 => [-1.50109,-1.11077,-0.841621,-0.622926,-0.430727,-0.253347,-0.0836517,
	            0.0836517,0.253347,0.430727,0.622926,0.841621,1.11077,1.50109],
             16 => [-1.53412,-1.15035,-0.887147,-0.67449,-0.488776,-0.318639,-0.157311,0,
	            0.157311,0.318639,0.488776,0.67449,0.887147,1.15035,1.53412]
           }
  
  def initialize(size)
    if not size.is_a? Integer then
      raise "Alphabet Size not an Integer"
    elsif (size < 2) or (size > 16) then
      raise "Alphabet Size not in range 2 .. 16"
    end
    @size = size
    @cuts = @@cuts[size]
  end

  def sax_value(value)

    @cuts.each_index do | index |
      if value < @cuts[index] then
        return index
      end
    end
    return @cuts.size
  end

end

class Deviator

  def initialize
    @n = 0
    @mean = 0.0
    @m2 = 0.0
  end

  def apply(val)
    @n = @n+1
    delta = val - @mean
    @mean = @mean + delta/@n
    delta2 = val - @mean
    @m2= @m2 + delta*delta2
    return @mean
  end

  def variance
    if @n < 2 then
      raise "Deviator has less than 2 samples"
    else
      return @m2 / (@n - 1)
    end
  end

  def std_deviation
    return Math.sqrt(variance)
  end

  def mean
    return @mean
  end

  def reset
    @mean = 0.0
    @n = 0.0
    @m2 = 0.0
  end

  def normalize(val)
    return (val - @mean) / std_deviation
  end
end

class PAA
  def initialize(box_size)
    if not box_size.is_a? Integer then
      raise("Box Size not an Integer")
    elsif box_size <= 0 then
      raise("Box Size not Positive")
    end
    @box_size = box_size
  end

  def zbox(stamp)
    stamp.to_i / @box_size.to_i
  end 

  def create(time_series)
    boxes = Hash.new(0.0)
    counts = Hash.new(0)
    # iterate the timeseries 
    time_series.each do |stamp, value|
      box = zbox(stamp)
      boxes[box] += value
      counts[box] += 1
    end

    # Now resolve boxes
    result = Hash.new
    boxes.each do | stamp, value |
      result[stamp] = value / counts[stamp]
    end
    return result
  end

  def self.last_n_boxes(boxes, n)
    last = boxes.max[0]
    first = (last - n + 1).to_i
    result = Array.new(n, nil)
    result.each_index {|index| result[index] = boxes[index + first]}
    return result
  end
    
end
