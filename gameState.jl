EMPTY = 0
WALL = 1
SWITCH = 2

up = [-1,0]
left = [0,-1]
down = [1,0]
right = [0,1]

type Board
    h::Int64
    v::Int64
    walls::Set{Array{Int64,1}}
    switches::Set{Array{Int64,1}}
end

type State
  guy::Array{Int64}
  boxes::Array{Int64,1}
  hVal::Int64
end

function computeHVal!(state::State, board::Board)
    #iff gameState = goal then hVal= 0
    #if guy can't move, return maxint
    #too slow version. foreach switch, pathfind the nearest box. add up distances
    h = length(state.boxes)
    for box in state.boxes
        if in(box, board.switches) 
            h-=1
        end
    end
    state.hVal = h
    println(state.hVal)
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

