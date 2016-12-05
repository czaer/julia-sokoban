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

function equalStates(x::State, y::State)
  if x.guy != y.guy
    return false
  end
  if x.boxes != y.boxes
    return false
  end
#   if x.hVal != y.hVal
#     return false
#   end
  return true
end

function inList(l, x::State)
  for y in l
    if equalStates(x, y)
      return true
    end
  end
  return false
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
  closedlist = State[]
  visitlist = StateWrapper[]
  it = 0
  current = StateWrapper(currentState, 0, 0, 'x')
  current.f = current.g + current.s.hVal
  pathlimit = currentState.hVal - 1
  #pathlimit = 10 #alex mentioned dfs works fast for small boards, lets try this?


  while(true)
    pathlimit = pathlimit + 1
    push!(openlist, current)
    seen = State[]
    nodes = 0

    while(length(openlist) > 0)
      state = shift!(openlist)
      #println("state: $state")
      #println("openlist: $openlist")
      #readline(STDIN)
      nodes += 1
      #h is 0 should be a goal node
      #println(state.s.hVal)
      if(state.s.hVal == 0)
        return state
      end

      #do we need pathLimit?
      state.f = state.s.hVal + state.g
      if(state.f <= pathlimit)
        unshift!(closedlist, state.s)
        #println("closedlist: $closedlist")
        #readline(STDIN)

        for child in getChildren(state, board)
          if inList(closedlist, child.s)
            #println("closed")
            continue
          end

          if inList(seen, child.s)
            #println("seen")
            continue
          end
          push!(seen, child.s)
          #println("seen: $seen")
          #readline(STDIN)

          child.g = state.g + 1
          child.f = child.g + child.s.hVal
          unshift!(openlist, child)
          #println("openlist after add child: $openlist")
          #readline(STDIN)
        end
      else
        #println("moved to visit set")
        unshift!(visitlist, state)
      end
    end

    it += 1
    println("it: $it")
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
    visitlist = StateWrapper[]
    closedlist = State[]
  end
end
