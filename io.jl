include("gameState.jl")
using Base.DataFmt

function printBoard(board,inp,val)
  for inpCount in 2:2:length(inp)
    board[inp[inpCount],inp[inpCount+1]] = val
  end
end

#todo, error handling
function setUp(filename)

    gameInput = open(filename)
    
    inpSize = readdlm(IOBuffer(readline(gameInput)),Int)
    inpWalls = readdlm(IOBuffer(readline(gameInput)),Int)
    inpBoxes = readdlm(IOBuffer(readline(gameInput)),Int)
    inpSwitches = readdlm(IOBuffer(readline(gameInput)),Int)
    inpPlayer = readdlm(IOBuffer(readline(gameInput)),Int)
    
    initBoard = [EMPTY for i = 1:inpSize[2], j = 1:inpSize[1]]
    printBoard(initBoard,inpWalls,WALL)
    printBoard(initBoard,inpSwitches,SWITCH)
    
    initPlayer = [inpPlayer[1], inpPlayer[2]]
    
    initBoxes = [[inpBoxes[inpCount],inpBoxes[inpCount+1]] for inpCount = 2:2:length(inpBoxes)]
    
    initState = State(initPlayer,initBoxes)
end

function stateToAscii(state)
    println(state)
end

#solnMoveSeq is char array [U, D, U, L...]
function writeSolnToFile(fn, solnMoveSeq)
    f = open(fn,"w")
    print(f,string(length(solnMoveSeq)," "))
    [print(f,string(i," ")) for i in solnMoveSeq]
    close(f)
end