include("./turtle.jl")

tri = ngon(3)
squ = ngon(4)
hex = ngon(6)
dod = ngon(12)

t = Turtle()

tile!(t, dod)
tile!(t, 2, tri, tri, squ)
move!(t, 4)
tile!(t, 1, tri, squ, tri)
move!(t, 3)
tile!(t, 3, squ, hex)
move!(t, 4)
tile!(t, 1, squ, tri)
move!(t, 3)
tile!(t, 3, tri, tri, tri)

plot!(t)
