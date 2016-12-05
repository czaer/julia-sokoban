#__precompile__()
Pkg.add("Match")
using Match

# EMPTY = 0
# WALL = 1
# SWITCH = 2

# up = [-1,0]
# left = [0,-1]
# down = [1,0]
# right = [0,1]

type Board
    h::Int64
    v::Int64
    walls::Set{Array{Int64,1}}
    switches::Set{Array{Int64,1}}
end

#use the set methods to modify fields of this type, we must recompute h
type State
  guy::Array{Int64,1}
  boxes::Array{Array{Int64,1},1}
  hVal::Int64
  State(guy, boxes, board::Board) = new(guy,boxes,computeHcl(guy, boxes, board))
end

function setGuy(newGuy::Array{Int64,1}, state::State, board::Board)
    state.guy = newGuy
    computeH!(state, board)
end

function setBoxes(newBoxes::Array{Array{Int64,1},1}, state::State, board::Board)
    state.boxes = newBoxes
    computeH!(state, board)
end

#if a move is allowed, generates a new state after the move and returns that and true
#otherwise returns the original state and false
function move(direction::Char, state::State, board::Board)
  #println("initial state: $state")
    @match direction begin
        'U' =>  begin
                    guyDest = [state.guy[1]-1, state.guy[2]]
                    pushBoxLoc = [guyDest[1]-1, guyDest[2]]
                    #println("U")
                end
        'D' => begin
                    guyDest = [state.guy[1]+1, state.guy[2]]
                    pushBoxLoc = [guyDest[1]+1, guyDest[2]]
                    #println("D")
                end
        'L' => begin
                    guyDest = [state.guy[1], state.guy[2]-1]
                    pushBoxLoc = [guyDest[1], guyDest[2]-1]
                    #println("L")
                end
        'R' => begin
                    guyDest = [state.guy[1], state.guy[2]+1]
                    pushBoxLoc = [guyDest[1], guyDest[2]+1]
                    #println("R")
                end
    end

    moveExecuted = false
    newState = nothing

    if in(guyDest, board.walls)
        newState = state
        #println("1 newstate: $newState")
    elseif in(guyDest, state.boxes)
        if in(pushBoxLoc, board.walls)
            newState = state
            #println("2 newstate: $newState")
        elseif in(pushBoxLoc, state.boxes)
            newState = state
            #println("3 newstate: $newState")
        else
            #is clear or switch
            newState = deepcopy(state)
            #println("4 newstate: $newState")
            #newState.guy = guyDest
            setGuy(guyDest, newState, board)
            bxs = deepcopy(newState.boxes)
            push!(bxs, pushBoxLoc)
            #not sure which way the logic flows here
            #bxs.pop!(guyDest)
            #println(guyDest)
            #println(findfirst(bxs, guyDest))
            deleteat!(bxs, findfirst(bxs, guyDest))
            #println("5 boxes: $bxs")
            setBoxes(bxs, newState, board )
            #println("6 newstate: $newState")
            moveExecuted = true
        end
    else
        #there isa switch but not box or blank tile
        newState = deepcopy(state)
        setGuy(guyDest, newState, board)
        moveExecuted = true
    end
    moveExecuted, newState
end

function computeH!(state::State, board::Board)
    state.hVal = computeHcl(state.guy, state.boxes, board)
end

function generatePref(men::Array{Int64,1}, women::Array{Array{Int64,1},1})
  distances = Dict()
  i = 1
  for s in women
    distances[i] = (abs(men[1] - s[1])+abs(men[2] - s[2]))
    i += 1
  end
  ret = Int64[]
  for (key, value) in distances
    if length(ret) == 0
      push!(ret, key)
      continue
    end
    insterted = false
    for x in ret
      if value < distances[x]
        splice!(ret, findfirst(ret, x), [key, x])
        insterted = true
        break
      end
    end
    if !insterted
      push!(ret, key)
    end
  end
  return ret
end

function computeHInit(guy::Array{Int64,1}, boxes::Array{Array{Int64,1},1}, board::Board)
  switches = collect(board.switches)
  freeBoxes = trues(length(boxes))
  freeSwitches = trues(length(switches))
  prefBoxes = Array{Array{Int64}, 1}(0)
  prefSwitches = Array{Array{Int64}, 1}(0)
  pairs = Array{Int64}(0)
  #println("stupid boxes")
  for b in boxes
    push!(prefBoxes, generatePref(b, switches))
    push!(pairs, 0)
  end
  #println("1")
  for s in switches
    push!(prefSwitches, generatePref(s, boxes))
  end
#  println("2")
  while true in freeBoxes
    matched = false
    x = findfirst(freeBoxes, true)
  #  println("3")
  #  println("x: $x, prefBoxes: $prefBoxes")
    for w in prefBoxes[x]
      #println("4")
     if freeSwitches[w]
       freeSwitches[w] = false
       freeBoxes[x] = false
       pairs[x] = w
      # println("5")
       break
     else
      # println("6")
      # println("w: $w")
       old = findfirst(pairs, w)
      # println("pairs: $pairs")
      # println("7")
       for m in prefSwitches[w]
         #println("8")
         if m == x
           #println("9")
           #println("old: $old")
           freeBoxes[x] = false
           freeBoxes[old] = true
           pairs[old] = 0
           pairs[x] = w
           matched = true
           #println("10")
           break
         end
         if m == old
           break
         end
         if matched
           break
         end
       end
       if matched
         break
       end
     end
   end
 end
 #println("pairs at end: $pairs")
 hTotal = 0
 i = 1
 while i <= length(pairs)
   hTotal += (abs(boxes[i][1] - switches[pairs[i]][1]) + abs(boxes[i][2] - switches[pairs[i]][2]))
   i+=1
 end
 return hTotal
end

# assuming length(boxes) == length(switches)
function computeHInitOld(guy::Array{Int64,1},boxes::Array{Array{Int64,1},1}, board::Board)
    #iff gameState = goal then hVal= 0
    #if guy can't move, return maxint
    #too slow version. foreach switch, pathfind the nearest box. add up distances
    h = length(board.switches)
    for box in boxes
        if in(box, board.switches)
            #println("found")
            h-=1
        end
    end
    return h
    #println(state.hVal)
end

function computeHcl(guy::Array{Int64,1},boxes::Array{Array{Int64,1},1}, board::Board)
    totDist = 0
    for box in boxes
        clDist = clSwitchDist(box,board)
        totDist += clDist
    end
    totDist
end

function clSwitchDist(box, board::Board)
    vals = Int64[]
    for switch in board.switches
        push!(vals, abs(switch[1]-box[1])+abs(switch[2]-box[2]))
        #println(vals)
    end
    minFuck = vals[1]
    for fuckYou in vals
        if fuckYou < minFuck
            minFuck = fuckYou
        end
    end
    minFuck
end

