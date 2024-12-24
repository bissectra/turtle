include("./turtle.jl")

trap = Tile([0.0 + 0.0im, 1.0 + 0.0im, 1.0 + 2.0im, 0.0 + 1.0im])
tiles = [trap, ngon(3), ngon(4), ngon(6), ngon(12)]
t = Turtle()

tile!(t, tiles[2], 0, 2, true)
tile!(t, tiles[1], 3pi/2, 2, false)
plot!(t)
