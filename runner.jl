__precompile__()
#only include files with functions directly called in this file, otherwise error
#println(LOAD_PATH)
#push!(LOAD_PATH, "/Path/To/My/Module/")
include("gameState.jl")
include("search.jl")
include("solve.jl")
#Pkg.update()
#using AIGameState

#using AISolve

using Base.DataFmt
using Base.Collections
#import Base.==


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
#         println(walls)
#         println(length(Set(walls)))
#         println(switches)
#         println(typeof(switches))
#         println(Set(switches))

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

        board = Board(inpSize[2], inpSize[1], Set(walls), Set(switches))
        #println(typeof(board))

        #println(typeof(initPlayer))
        #println(typeof(initBoxes))

        state = State(initPlayer,Set(initBoxes), board, true)
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
println("Please enter a file containing the initial board state. e.g. input.txt :  ")
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
# println("We will now try to solve the game. Please enter a duration in seconds to compute. Enter \'0\' to run indefinitely")
# maxDuration = chomp(readline(STDIN))
# println("Now solving for $(maxDuration) seconds.")

#we use our search to find these simple deadlocks, so need to set closedlist/badlocs
closedlist = Dict{State,Int64}()
badLocs = Set{Array{Int64,1}}()
lookup = oneBoxDL(gameState, board)
#println(lookup)
println("heuristic build completed, main solving now")
            # println(lookup[LocTup([2,2],[4,2])])
            # println(lookup[LocTup([3,2],[4,2])])
            # println(lookup[LocTup([4,2],[4,2])])

#readline(STDIN)

#finished, runTime, solnMoveSeq = doSolve(board,gameState, maxDuration)
closedlist = Dict{State,Int64}()
code, goal, val = @time search4(gameState, board, false)
println(val)
println(goal)
println(getPath(goal))
#Profile.print()

for item in getPath(goal)
  println(item)
end


# println("Sokoban solving terminated in $(runTime) seconds.")
# println("Did it finish?  $(finished)")
# writeSolnToFile(inputFilename * ".soln",['U','D','D','R','L'])
# println("The solution movelist has been written to file $(inputFilename).soln")

#animate if we have time
