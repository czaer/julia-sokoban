#__precompile__()
Pkg.add("Match")
#Pkg.add("hashing")
#Pkg.add("Base.isequal")
using Match

import Base.isequal
import Base.hash

# using hashing
# using isequal
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
    #boxes::Array{Array{Int64,1},1}
    boxes::Set{Array{Int64,1}}
    hVal::Int64
    State(guy, boxes, board::Board) = new(guy,boxes,computeHcl(guy, boxes, board))

end

function isequal(A::State, B::State)
    #println("called eq")
    A.guy[1] == B.guy[1] && A.guy[2] == B.guy[2] && A.boxes == B.boxes
end

# function ==(A::State, B::State)
#     println("called eq")
#     A.guy[1] == B.guy[1] && A.guy[2] == B.guy[2] && A.boxes == B.boxes
# end

# function hash(x::State)
#     println("called hash1")
#     hsh = squares[x.guy[1],x.guy[2]]
#     for box in x.boxes
#         hsh = hsh $ squares[box[1],box[2]]
#     end
#     return hsh % 941083987
# end
# function hash(A::State, h::UInt64)
#     println("called hash2")
#     hsh = squares[x.guy[1],x.guy[2]] 
#     for box in x.boxes
#         hsh = hsh $ squares[box[1],box[2]]
#     end
#     return hash(hsh % 941083987 + h)
# end

# function Base.hash(x::State)
#     println("called hash1")
#     return hash(x.guy) + hash(x.boxes)
# end

function Base.hash(x::State)
    #println("called hash1")
    hsh = squares[x.guy[1],x.guy[2]]
    for box in x.boxes
        hsh = hsh $ squares[box[1],box[2]]
    end
    #println(hsh % 941083987)
    return hsh % 941083987
end

function Base.hash(A::State, h::UInt64)
    println("called hash2")
    return hash(x.guy) + hash(x.boxes) + hash(h)
end


# function setGuy(newGuy::Array{Int64,1}, state::State, board::Board)
#     state.guy = newGuy
#     computeH!(state, board)
# end

# function setBoxes(newBoxes::Array{Array{Int64,1},1}, state::State, board::Board)
#     state.boxes = newBoxes
#     computeH!(state, board)
# end

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
    elseif in(badLocs, pushBoxLoc)
        #if we put box here we can't get it to a goal ever
        newState = state
    elseif in(guyDest, state.boxes)
        if in(pushBoxLoc, board.walls)
            newState = state
        elseif in(pushBoxLoc, state.boxes)
            newState = state
        else
            #is clear or switch
            newState = deepcopy(state)
            #println("4 newstate: $newState")
            newState.guy = guyDest
            #setGuy(guyDest, newState, board)
            #bxs = deepcopy(newState.boxes)
            push!(newState.boxes, pushBoxLoc)
            #not sure which way the logic flows here
            #bxs.pop!(guyDest)
            #println(guyDest)
            #println(findfirst(bxs, guyDest))

            #deleteat!(newState.boxes, findfirst(newState.boxes, guyDest))
            delete!(newState.boxes,guyDest)
            
            #println("5 boxes: $bxs")
            #setBoxes(bxs, newState, board )
            computeH!(newState,board)
            #println("6 newstate: $newState")
            moveExecuted = true
        end
    else
        #there isa switch but not box or blank tile
        newState = deepcopy(state)
        newState.guy = guyDest
        computeH!(newState,board)
        #setGuy(guyDest, newState, board)
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
function computeHInitOld(guy::Array{Int64,1},boxes::Set{Array{Int64,1}}, board::Board)
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

function computeHcl(guy::Array{Int64,1},boxes::Set{Array{Int64,1}}, board::Board)
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
    mf = vals[1]
    for fy in vals
        if fy < mf
            mf = fy
        end
    end
    mf
end


function oneBoxDL(state::State, board::Board)
    allSquares = Set(reshape([[h,v] for h in 1:board.h, v in 1:board.v],1, board.h*board.v))
    badSquares = Set{Array{Int64,1}}()
    for wall in board.walls
        delete!(allSquares, wall)
    end
    for square in allSquares
        canReach = false
        for goal in board.switches
            if reachable(square, goal, state, board)
                canReach = true
                break
            end
        end
        if !canReach
            push!(badSquares, square)
        end
    end
    badSquares
end

function reachable(src::Array{Int64,1},dest::Array{Int64,1},state::State, board::Board)
    state2 = deepcopy(state)
    state2.boxes = Set([src])
    board2 = deepcopy(board)
    board2.switches = Set([dest])
    computeH!(state2,board2)
    code, goal, val = search4(state2,board2)
    return code == "found"
end
