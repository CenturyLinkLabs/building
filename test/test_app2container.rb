require 'test/unit'
require 'building'

class BuildingTest < Test::Unit::TestCase
  def setup(options={})
    Building.convert(
      "test-app",
      "latest",
      options
    )
  end
end
