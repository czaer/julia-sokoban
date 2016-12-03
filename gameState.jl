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
  State(guy, boxes, board::Board) = new(guy,boxes,computeHInit(guy, boxes, board))
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
    @match direction begin
        'U' =>  begin
                    guyDest = [state.guy[1]-1, state.guy[2]]
                    pushBoxLoc = [guyDest[1]-1, guyDest[2]]
                end
        'D' => begin
                    guyDest = [state.guy[1]+1, state.guy[2]]
                    pushBoxLoc = [guyDest[1]+1, guyDest[2]]
                end
        'L' => begin
                    guyDest = [state.guy[1], state.guy[2]-1]
                    pushBoxLoc = [guyDest[1], guyDest[2]-1]
                end
        'R' => begin 
                    guyDest = [state.guy[1], state.guy[2]+1]
                    pushBoxLoc = [guyDest[1], guyDest[2]+1]
                end
    end

    moveExecuted = false
    newState = nothing

    if in(guyDest, board.walls)
        newState = state
    elseif in(guyDest, board.boxes)
        if in(pushBoxLoc, board.walls)
            newState = state
        elseif in(pushBoxLoc, state.boxes)
            newState = state
        else
            #is clear or switch
            newState = deepcopy(state)
            #newState.guy = guyDest
            setGuy(guyDest, newState, board)
            bxs = deepcopy(newState.boxes)
            bxs.push!(pushBoxLoc)
            bxs.pop!(guyDest)
            setBoxes(bxs, newState, board )
            moveExecuted = true
        end
    else
        #there isa switch but not box or blank tile
        newState = deepcopy(state)
        setGuy(guyDest)
        moveExecuted = true
    end
    moveExecuted, newState
end

function computeH!(state::State, board::Board)
    state.hVal = computeHInit(state.guy, state.boxes, board)
end

function computeHInit(guy::Array{Int64,1},boxes::Array{Array{Int64,1},1}, board::Board)
    #iff gameState = goal then hVal= 0
    #if guy can't move, return maxint
    #too slow version. foreach switch, pathfind the nearest box. add up distances
    h = length(boxes)
    for box in boxes
        if in(box, board.switches) 
            h-=1
        end
    end
    return h
    #println(state.hVal)
end


# function checkWall(board,loc)
#   board[loc[1], loc[2]] == WALL
# end

# function checkSwitch(board,loc)
#   board[loc[1], loc[2]] == SWITCH
# end

# function Move(state,board,dir)
#   newState = State(state.Guy,state.Boxes)
#   newState.Guy += dir

#   if checkWall(board,newState.Guy)
#     print("guywall!")
#     return 0
#   end

#   for i in (1:length(newState.Boxes))
#     box = newState.Boxes[i]
#     if newState.Guy == box
#       box += dir
#       if checkWall(board,box)
#         print("boxwall!")
#         return 0
#       end
#       for oldbox in state.Boxes
#         if box == oldbox
#           print("boxbox!")
#           return 0
#         end
#       end
#       newState.Boxes[i] = box
#       break
#     end
#   end

#   return newState
# end
