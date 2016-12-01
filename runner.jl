#note, include just brings in files, resulting in one global scope
#java style classes woule be modules in julia, which use keywords using and import
#include("gameState.jl")
include("io.jl")
include("solve.jl")

println("Welcome to Sokoban!") 
println("Please enter a file containing the initial board state. e.g. input.txt :  ")
#todo, handle quotes or no quotes
inputFilename = chomp(readline(STDIN))
println("Loading game from $(inputFilename)") 
gameState = setUp(inputFilename)

#setup initial game state 
#if io fail, recover and ask for a new filename
println("The initial board state has been loaded. Here is the board")
stateToAscii(gameState)

println("We will now try to solve the game. Please enter a duration in seconds to compute. Enter \'0\' to run indefinitely")
maxDuration = chomp(readline(STDIN))
println("Now solving for $(maxDuration) seconds.")

finished, runTime, solnMoveSeq = doSolve(gameState, maxDuration)

#run solver, timer
#stop timer, validate solution
#success?
println("Sokoban solving terminated in $(runTime) seconds.")
println("Did it finish?  $(finished)")
writeSolnToFile(inputFilename * ".out")
println("The solution movelist has been written to file (intial state name + _solution")
#animate if we have time
