#include("gameState.jl")

#gameState.hVal will be heuristic
#return the state we want to move to
type StateWrapper
  s::State
  g::Int64
  f::Int64
  #prev + move = State
  move::Char
  prev::StateWrapper
  #StateWrapper(currentState) = new(nothing, currentState, 0, 0, nothing)
  #StateWrapper(prev, s, g, f, move) = new(prev, s, g, f, move)
  StateWrapper(s, g, f, move) = new(s, g, f, move)
  StateWrapper(s, g, f, move, prev) = new(s, g, f, move, prev)
end

function getChildren(parent::StateWrapper, board::Board)
  directions = ['U','D','L','R']
  children = StateWrapper[]
  for dir in directions
    legal, child = move(dir, parent.s, board)
    if(legal)
      childwrapper = StateWrapper(child, 0, 0, dir, parent)
      push!(children, childwrapper)
    end
  end
  return children
end

function getPath(state::StateWrapper)
  pathlist = Char[]
  if(!isdefined(state, :prev))
    return pathlist
  end
  while(isdefined(state, :prev))
    unshift!(pathlist, state.move)
    state = state.prev
  end
  return pathlist
end

function findGoal(currentState::State, board::Board)
  openlist = StateWrapper[]
  closedlist = StateWrapper[]
  visitlist = StateWrapper[]
  it = 0
  current = StateWrapper(currentState, 0, 0, 'x')
  current.f = current.g + current.s.hVal
  pathlimit = currentState.hVal - 1
  #pathlimit = 10 #alex mentioned dfs works fast for small boards, lets try this?


  while(true)
    pathlimit = pathlimit + 1
    push!(openlist, current)
    seen = Set()
    nodes = 0

    while(length(openlist) > 0)
      state = shift!(openlist)
      nodes += 1
      #h is 0 should be a goal node
      #println(state.s.hVal)
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
            println("closed")
            continue
          end

          if child in seen
            println("seen")

            continue
          end
          push!(seen, child)

          child.g = state.g + 1
          child.f = child.g + child.s.hVal
          unshift!(openlist, child)
        end
      else
        unshift!(visitlist, state)
      end
    end

    it += 1
    if (length(visitlist) <= 0)
      println("didn't find answer")
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
