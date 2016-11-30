#note, include just brings in files, resulting in one global scope
#java style classes woule be modules in julia, which use keywords using and import
include("gameState.jl")
include("initState.jl")
include("solve.jl")

println("Welcome to Sokoban!") 
println("Please enter a file containing the initial board state. e.g. \"input.txt\" :  ")
filename = readline(STDIN)
println("Loading game from $(filename)") 
gameState = setUp("$filename")

#setup initial game state 
#if io fail, recover and ask for a new filename
println("The initial board state has been loaded. Here is the board")
boardToAscii(gameState)

println("We will now try to solve the game. Please enter a duration in seconds to compute. Enter \'0\' to run indefinitely")
runDuration = readline(STDIN)
println("Now solving for $(runDuration) seconds.")

doSolve(gameState)

#run solver, timer
#stop timer, validate solution
#success?
println("Sokoban solving terminated in ??seconds. ?success??")
#write out solution
println("The solution movelist has been written to file (intial state name + _solution")
#animate if we have time
