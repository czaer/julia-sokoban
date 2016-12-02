#only include files with functions directly called in this file, otherwise error
include("gameState.jl") 
include("io.jl")
include("solve.jl")

println("Welcome to Sokoban!") 
println("Please enter a file containing the initial board state. e.g. input.txt :  ")
#todo, handle quotes or no quotes
inputFilename = chomp(readline(STDIN))
#println("Loading game from $(inputFilename)") 
board,gameState = setUp(inputFilename)

while typeof(gameState) == String
    println("Initial board setup had the following error, \"$(gameState)\". Please try again:")
    inputFilename = chomp(readline(STDIN))
    println("Loading game from $(inputFilename)") 
    board, gameState = setUp(inputFilename)
end

#setup initial game state 
#if io fail, recover and ask for a new filename
println("The initial board state has been loaded. Here is the board")
stateToAscii(gameState)

println("We will now try to solve the game. Please enter a duration in seconds to compute. Enter \'0\' to run indefinitely")
maxDuration = chomp(readline(STDIN))
println("Now solving for $(maxDuration) seconds.")

#println(computeHVal!(gameState,board))
finished, runTime, solnMoveSeq = doSolve(board,gameState, maxDuration)

#run solver, timer
#stop timer, validate solution
#success?
println("Sokoban solving terminated in $(runTime) seconds.")
println("Did it finish?  $(finished)")
writeSolnToFile(inputFilename * ".soln",['U','D','D','R','L'])
println("The solution movelist has been written to file $(inputFilename).soln")
#animate if we have time
