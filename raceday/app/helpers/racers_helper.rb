module RacersHelper
  # Instance method toRacer.
  def toRacer(value)
  return value.is_a?(Racer) ? value : Racer.new(value)
  end
end
