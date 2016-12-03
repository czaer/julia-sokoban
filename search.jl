#include("gameState.jl")

#gameState.hVal will be heuristic
#return the state we want to move to
type StateWrapper
  prev::StateWrapper
  s::State
  g::Int64
  f::Int64
  #prev + move = State
  move::Char
  #StateWrapper(currentState) = new(nothing, currentState, 0, 0, nothing)
  #StateWrapper(prev, s, g, f, move) = new(prev, s, g, f, move)
end

function getChildren(parent::StateWrapper, board::Board)
  directions = ['U','D','L','R']
  children = StateWrapper[]
  for dir in directions
    legal, child = move(dir, parent.s, board)
    if(legal)
      childwrapper = (parent, child, 0, 0, dir)
    end
  end
  return children
end

function getPath(state::StateWrapper)
  pathlist = Char[]
  if(state.parent == nothing)
    return pathlist
  end
  while(state.parent != nothing)
    unshift!(pathlist, state.move)
    state = state.parent
  end
  return pathlist
end

function findGoal(currentState, board)
  openlist = []
  closedlist = []
  visitlist = []
  it = 0
  current = StateWrapper(nothing, currentState, 0, 0, nothing)
  current.f = current.g + current.s.hVal
  pahtlimit = currentState.hVal - 1

  while(true)
    pathlimit = pathlimit + 1
    push!(open, current)
    seen = Set()
    nodes = 0

    while(length(openlist > 0))
      state = shift!(openlist)
      nodes += 1
      #h is 0 should be a goal node
      if(state.s.hVal == 0)
        return state
      end

      #do we need pathLimit?
      state.f = state.s.hVal + state.g
      if(state.f <= pathlimit)
        unshift!(closedlist, state)
        #todo add a getChildren function to return a list of StateWrapper
        for child in getChildren(state, board)
          if child in closedlist
            continue
          end

          if child in seen
            continue
          end
          push!(seen, child)

          child.g = state.g + 1
          child.f = child.g + child.s.hVal
          unshift!(openlist, child)
        end
      else
        unshift!(vistilist, state)
      end
    end

    it += 1
    if (len(visitlist) <= 0)
      return nothing
    end

    low = visitlist[1].f
    for x in visitlist
      if x.f < low
        low = x.f
      end
    end
    pathlimit = low

    append!(openlist, visitlist)
    visitlist = []
    closedlist = []
  end
end
