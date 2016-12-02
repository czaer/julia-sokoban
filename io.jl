#include("gameState.jl")
using Base.DataFmt

function printBoard(board,inp,val)
  for inpCount in 2:2:length(inp)
    board[inp[inpCount],inp[inpCount+1]] = val
  end
end

function setUp(filename)
    gameInput = "bad"
    try
        gameInput = open(filename)
    catch e
        return "could not open file"
    end

    try
        inpSize = readdlm(IOBuffer(readline(gameInput)),Int)
        inpWalls = readdlm(IOBuffer(readline(gameInput)),Int)
        inpBoxes = readdlm(IOBuffer(readline(gameInput)),Int)
        inpSwitches = readdlm(IOBuffer(readline(gameInput)),Int)
        inpPlayer = readdlm(IOBuffer(readline(gameInput)),Int)
        

        walls = [[inpWalls[inpCount],inpWalls[inpCount+1]] for inpCount = 2:2:length(inpWalls)]
        switches = [[inpSwitches[inpCount],inpSwitches[inpCount+1]] for inpCount = 2:2:length(inpSwitches)]
        #println(walls)
        #println(typeof(Set(walls)))
        #println(switches)

        # initBoard = [EMPTY for i = 1:inpSize[2], j = 1:inpSize[1]]
        # printBoard(initBoard,inpWalls,WALL)
        # printBoard(initBoard,inpSwitches,SWITCH)
        
        initPlayer = [inpPlayer[1], inpPlayer[2]]
        
        initBoxes = [[inpBoxes[inpCount],inpBoxes[inpCount+1]] for inpCount = 2:2:length(inpBoxes)]
        
        #println(initBoxes)
        # initBoard = Board(inpSize[2], inpSize[1], Set(walls), Set(switches))
        #         println(initBoard)
        # println(length(initBoard.walls))
        # initState = State(initPlayer,initBoxes)
        # initBoard, initState
        Board(inpSize[2], inpSize[1], Set(walls), Set(switches)) , State(initPlayer,initBoxes)
    catch e
        return "Initial board parsing failed, check input file contents"
    end
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