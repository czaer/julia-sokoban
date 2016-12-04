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
  State(guy, boxes, board::Board) = new(guy,boxes,computeHZero(guy, boxes, board))
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
    elseif in(guyDest, state.boxes)
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
            push!(bxs, pushBoxLoc)
            #not sure which way the logic flows here
            #bxs.pop!(guyDest)
            deleteat!(bxs, findin(bxs, guyDest))
            setBoxes(bxs, newState, board )
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
    state.hVal = computeHZero(state.guy, state.boxes, board)
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

function computeHZero(guy::Array{Int64,1},boxes::Array{Array{Int64,1},1}, board::Board)
    return 0

end
