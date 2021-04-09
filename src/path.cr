require "crystalline/containers/heap"

def log(text)
    puts text
end

def shortestPath(grid, from, to)
  grid.printGrid
  log "finding path from #{from} to #{to}"
  list = [] of Location
  queue = Crystalline::Containers::MinHeap(Int32, Array(Location)).new
  list << from
  queue.push(0, list)
  while !queue.empty?
    path = queue.pop.as(Array(Location))
    last = path[path.size - 1]
    if last.equal? to
      # path to destination
      return makePath(path)
    end
    generateNext(grid, to, path, queue, Direction::UP)
    generateNext(grid, to, path, queue, Direction::DOWN)
    generateNext(grid, to, path, queue, Direction::LEFT)
    generateNext(grid, to, path, queue, Direction::RIGHT)
  end
  return [] of Int32
end

#try to find the way via this direction
def generateNext(grid, to, path, queue, direction)
  log "generateNext #{direction}"
  last = path.last
  nextLocation = last.nextLocation(direction)
  if (grid.validMove(last, direction) || nextLocation.equal?(to))
    log "considering this direction"
    newPath = path.dup
    if !hasLoop(newPath, nextLocation)
      newPath << nextLocation
      cost = newPath.size + nextLocation.distance(to)
      log "no loop, adding #{nextLocation} at cost #{cost} to path: #{newPath}"
      queue.push(cost, newPath)
    end
  else
    log "invalid direction"
  end
end

# check for loops
def hasLoop(path, nextLocation)
  path.each { |l|
    if l.equal? nextLocation
      return true
    end
  }
  return false
end

# make a list of directions from a list of locations
def makePath(list)
  path = [] of Int32
  last = list.delete_at(0)
  list.each { |loc|
    dir = last.getDirection(loc)
    path << dir
    last = loc
  }
  return path
end
