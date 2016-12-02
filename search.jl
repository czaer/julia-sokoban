include("gameState.jl")

#hVal(gamestate) will be heuristic
#return the state we want to move to
type StateWrapper
  prev::StateWrapper
  s::State
  g
  f
  #prev + move = State
  move::Char
end

function getChildren(parent)
  directions = [u, d, l, r]
  children = StateWrapper[]
  for dir in directions
    legal, child = move(dir, parent.s)
    if(legal)
      childwrapper = (parent, child, 0, 0, dir)
    end
  end
  return children
end


fucntion findBestMove(currentState)
  openlist = []
  closedlist = []
  visitlist = []
  it = 0
  current.s = currentState
  current.g = 0
  current.f = current.g + current.s.h
  pahtlimit = currentState.h - 1

  while(true)
    pathlimit = pathlimit + 1
    push!(open, current)
    seen = Set()
    nodes = 0

    while(length(openlist > 0))
      state = shift!(openlist)
      nodes += 1
      #h is 0 should be a goal node
      if(state.s.h == 0)
        return state.s
      end

      #do we need pathLimit?
      state.f = state.s.h + state.g
      if(state.f <= pathlimit)
        unshift!(closedlist, state)
        #todo add a getChildren function to return a list of StateWrapper
        for(child in getChildren(state))
          if child in closedlist
            continue
          end

          if child in seen
            continue
          end
          push!(seen, child)

          child.g = state.g + 1
          child.f = child.g + child.s.h
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
