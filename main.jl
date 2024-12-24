include("./turtle.jl")

tri = ngon(3)
squ = ngon(4)
hex = ngon(6)
dod = ngon(12)

t = Turtle()

tile!(t, dod)
tile!(t, 2, tri)
tile!(t, 3, tri)
tile!(t, 4, squ)
move!(t, 4)
plot!(t)
