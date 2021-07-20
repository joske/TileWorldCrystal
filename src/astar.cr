require "crystalline"

include Crystalline
include Containers
include Algorithms

# node holder
class Node
  property :location, :path, :score
  def initialize(l : Location, p : Array(Location), s : Int32)
    @location = l
    @path = p
    @score = s
  end
  def <=>(other : Node)
    @score <=> other.score
  end

  def ===(other : Node)
    @location === other.location
  end

  def to_s
    "Node(@#{@location}, path=#{@path}, score=#{@score})"
  end
end

def astar(grid, from, to)
  nodecmp = -> (x: Int32, y: Int32) { (y <=> x) == 1 }
  open_list = Containers::PriorityQueue(Node).new(nodecmp)
  closed_list = Set(Node).new
  fromNode = Node.new(from, [] of Location, 0)
  open_list.push(fromNode, 0)
  until open_list.empty?
    current = open_list.pop.as(Node)
    puts "current=#{current}"
    if current.location == to
      # arrived
      return current.path
    end
    closed_list.add(current)
    checkNeighbor(grid, open_list, closed_list, current, Direction::UP, from, to)
    checkNeighbor(grid, open_list, closed_list, current, Direction::DOWN, from, to)
    checkNeighbor(grid, open_list, closed_list, current, Direction::LEFT, from, to)
    checkNeighbor(grid, open_list, closed_list, current, Direction::RIGHT, from, to)
  end
  [] of Location
end

def checkNeighbor(grid, open_list, closed_list, current, direction, from, to)
    puts "check #{direction}"
  nextLocation = current.location.nextLocation(direction)
  if grid.validMove(current.location, direction) || nextLocation.equal?(to)
    h = nextLocation.distance(to)
    g = current.location.distance(from) + 1
    new_path = current.path.clone 
    new_path.push(nextLocation)
    child = Node.new(nextLocation, new_path, g + h)
    lowerChild = closed_list.select() { |node|
      node.location.equal?(child.location) && node.score < child.score
    }
    if (lowerChild.empty?)
        puts "adding child #{child}"
        open_list.push(child, child.score)
    end
    
  end
end
