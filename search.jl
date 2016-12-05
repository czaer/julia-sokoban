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
#   ==(x,y) = begin

#             end
#   hash(x) =
  isless(x,y) = x.f < y.f ? true : false 
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
      childwrapper = StateWrapper(child, parent.g+1, parent.g +1 + child.hVal , dir, parent)
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
      #state = delete!(openlist)
      
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

function findGoal2(currentState::State, board::Board)
    openlist = Collections.PriorityQueue()
    closedlist = Dict{State,Int64}()
    current = StateWrapper(currentState, 0, 0, 'x')
    current.f = current.g + current.s.hVal
    enqueue!(openlist, current, current.f)
    #pathlimit = currentState.hVal - 1
    pathlimit = 10 #alex mentioned dfs works fast for small boards, lets try this?
    it = 0

    while(true)
                println(it)
        visitlist = Set{StateWrapper}()
        #seen = Set{State}()
        #nodes = 0

        while(length(openlist) > 0)
            state = dequeue!(openlist)
            if(state.s.hVal == 0)
                return state
            end
            #nodes += 1
            #state.f = state.s.hVal + state.g
            if state.f <= pathlimit
                #push!(closedlist, state)
                closedlist[state.s] = state.g 
    #            push!(closedlist, state.s)
                for child in getChildren(state, board)
                    oldVal = get(closedlist,child.s,child.g)
                    oldVal < child.g ?  continue : closedlist[child.s] = child.g
                    
                    # if haskey(closedlist, child)
                    #     #println("closed")
                    #     continue
                    # end

                    # if in(closedlist, child.s)
                    #     #println("closed")
                    #     continue
                    # end

                    # if in(seen, child.s)
                    #     #println("seen")
                    #     continue
                    # end
                    # push!(seen, child.s)

                    # child.g = state.g + 1
                    # child.f = child.g + child.s.hVal

                    #enqueue!(openlist, child)
                    push!(visitlist, child)
                end
            else
                #println("moved to visit set")
                push!(visitlist, state)
            end
        end

        
        # println("it: $it")
        # if (length(visitlist) <= 0)
        #     println("didn't find answer")
        #     return nothing
        # end

        # low = visitlist[1].f
        # for x in visitlist
        #     if x.f < low
        #     low = x.f
        #     end
        # end
        # pathlimit = low
        it += 1

        pathlimit = pathlimit + 1
        for item in visitlist
            enqueue!(openlist, item, item.f)
        end
        #enqueue!(openlist, visitlist)
    end

end