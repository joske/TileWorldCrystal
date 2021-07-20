require "./spec_helper"
require "../src/astar.cr"

describe Tileworld do
  # TODO: Write tests

  it "works" do
    grid = Grid.new(0, 0, 0, 0)
    from = Location.new(0, 0)
    to = Location.new(1, 1)
    path = astar(grid, from, to)
    path.size.should eq 2
  end
end
