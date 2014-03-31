require 'test/unit'
require 'app2container'

class App2ContainerTest < Test::Unit::TestCase
  def setup(options={})
    App2Container.convert(
      "test-app",
      "latest",
      options
    )
  end
end
