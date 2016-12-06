__precompile__()

include("gameState.jl")
include("search.jl")
Pkg.update()

using Base.DataFmt
using Base.Collections


function printBoard(board,inp,val)
  for inpCount in 2:2:length(inp)
    board[inp[inpCount],inp[inpCount+1]] = val
  end
end

#assuming x,y pairs start at 1; 1,1 is the top left square
#assuming outer edges explicityly contain walls; 1,1-n n,1-n 1-n,1 1-n,n should all be walls
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

        initPlayer = [inpPlayer[1], inpPlayer[2]]

        initBoxes = [[inpBoxes[inpCount],inpBoxes[inpCount+1]] for inpCount = 2:2:length(inpBoxes)]

        board = Board(inpSize[2], inpSize[1], Set(walls), Set(switches))

        state = State(initPlayer,Set(initBoxes), board)
        #println(typeof(state))
        #println(state)
        board, state
    catch e
        println(e)
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

println("Welcome to Sokoban!")
println("Please enter a file containing the initial board state. e.g. wikisoko.txt :  ")
#todo, handle quotes or no quotes
inputFilename = chomp(readline(STDIN))
#println("Loading game from $(inputFilename)")
board,gameState = setUp(inputFilename)
#println(setUp(inputFilename))

while typeof(gameState) <: String
    println("Initial board setup had the following error, \"$(gameState)\". Please try again:")
    inputFilename = chomp(readline(STDIN))
    println("Loading game from $(inputFilename)")
    board, gameState = setUp(inputFilename)
end

const squares = rand(1:2^32,board.h, board.v) #Array{Int64,2}

#setup initial game state
#if io fail, recover and ask for a new filename
println("The initial board state has been loaded. Here is the initial state variable")
stateToAscii(gameState)

println("computing static deadlocks")


#we use our search to find these simple deadlocks, so need to set closedlist/badlocs
closedlist = Dict{State,Int64}()
badLocs = Set{Array{Int64,1}}()
badLocs = oneBoxDL(gameState, board)
println("DL completed, main solving now")


closedlist = Dict{State,Int64}()
code, goal, val = @time search4(gameState, board)
println(val)
#println(goal)
println(getPath(goal))

writeSolnToFile(inputFilename * ".soln",getPath(goal))
println("The solution movelist has been written to file $(inputFilename).soln")

#animate if we have time
