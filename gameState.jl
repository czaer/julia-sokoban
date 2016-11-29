EMPTY = 0
WALL = 1
SWITCH = 2

up = [-1,0]
left = [0,-1]
down = [1,0]
right = [0,1]

type State
  Guy
  Boxes
end

function checkWall(board,loc)
  board[loc[1], loc[2]] == WALL
end

function Move(state,board,dir)
  newState = State(state.Guy,state.Boxes)
  newState.Guy += dir

  if checkWall(board,newState.Guy)
    print("guywall!")
    return 0
  end

  for i in (1:length(newState.Boxes))
    box = newState.Boxes[i]
    if newState.Guy == box
      box += dir
      if checkWall(board,box)
        print("boxwall!")
        return 0
      end
      for oldbox in state.Boxes
        if box == oldbox
          print("boxbox!")
          return 0
        end
      end
      newState.Boxes[i] = box
      break
    end
  end

  return newState
end
