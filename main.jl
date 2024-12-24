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
move!(t, 2)
tile!(t, 3, squ, squ)
move!(t, 4)
tile!(t, 1, tri, tri, tri)
move!(t, 3)
tile!(t, 4, tri)
move!(t, 4)
tile!(t, 1, tri)
move!(t, 1)
tile!(t, 1, squ, squ)
move!(t, 1)
tile!(t, 1, tri, tri)
move!(t, 4)
tile!(t, 3, tri, tri, squ)
move!(t, 5)
tile!(t, 1, tri, tri, squ)
move!(t, 5)
tile!(t, 1, tri, tri, squ)
move!(t, 5)
tile!(t, 1, tri, tri, squ)
move!(t, 3)
tile!(t, 3, squ, squ)
move!(t, 2, 2)
tile!(t, 3, squ, squ)
move!(t, 1, 1, 1)
tile!(t, 1, squ, squ)
move!(t, 4, 4)
tile!(t, 1, squ, squ)
move!(t, 4, 4)
tile!(t, 1, squ)
move!(t, 4, 1, 1, 1, 1)
tile!(t, 1, squ, squ)
move!(t, 3, 3)
tile!(t, 1, squ, squ)
move!(t, 3, 3)
tile!(t, 1, squ)
move!(t, 1, 1, 1, 1, 1)
tile!(t, 1, tri)
move!(t, 1)
tile!(t, 1, squ)
move!(t, 5, 2)
tile!(t, 1, hex, tri)
move!(t, 3, 3)
tile!(t, 1, hex)
move!(t, 3)
tile!(t, 1, tri, tri, tri)
move!(t, 4, 1)
tile!(t, 1, hex, hex)
move!(t, 1)
tile!(t, 1, tri, tri)
move!(t, 3)
tile!(t, 3, tri, tri, tri)
move!(t, 2)
tile!(t, 3, tri)
move!(t, 1, 3)
tile!(t, 1, tri)
move!(t, 1)
tile!(t, 1, squ, squ)
move!(t, 3, 3)
tile!(t, 1, squ, squ)
move!(t, 1, 4, 1, 1, 1)
tile!(t, 1, tri, tri, tri)
move!(t, 1)
tile!(t, 1, tri)
move!(t, 4, 3)
tile!(t, 4, tri, tri)
move!(t, 1, 1, 1)
tile!(t, 1, tri, tri, squ)
move!(t, 3, 3)
tile!(t, 1, squ, squ)
move!(t, 4, 2)
tile!(t, 1, tri, tri, tri)
move!(t, 3, 3)
tile!(t, 1, tri, tri, tri)
move!(t, 1)
tile!(t, 4, tri)
move!(t, 5)
tile!(t, 4, squ, squ)
move!(t, 5)
tile!(t, 1, squ, squ)
move!(t, 4)
tile!(t, 1, squ, squ)
move!(t, 1)
tile!(t, 1, squ, squ)
move!(t, 1, 4)
tile!(t, 1, squ, tri, tri, tri)
move!(t, 5)
tile!(t, 1, tri, tri, tri, tri)
move!(t, 5)
tile!(t, 1, tri)
move!(t, 3, 3)
tile!(t, 5, tri)
move!(t, 3, 2)
tile!(t, 3, tri, tri, tri)
move!(t, 5)
tile!(t, 1, tri, tri, tri, tri)
move!(t, 3)
tile!(t, 5, tri)
move!(t, 1, 3)
tile!(t, 3, squ, tri)
move!(t, 3, 1)
tile!(t, 4, squ, squ)
move!(t, 4)
tile!(t, 1, tri)
move!(t, 1)
tile!(t, 1, tri)
move!(t, 1, 1)
tile!(t, 1, squ, squ)
move!(t, 1)
tile!(t, 1, tri)
move!(t, 1, 1)

q = transform(p -> conj(p), t)
move!(q, 1)

plot!(t, number_edges = false)
plot!(q, number_edges = false, output = "output_conj.png")
