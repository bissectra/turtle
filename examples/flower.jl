include("../turtle.jl")

n = 4 # any positive even number will do
alpha = pi / (2n)
r = cos(alpha)
r = (r + 1 / r) / 2 # any value between cos(alpha) and 1/cos(alpha) will do

tri = Tile([0.0 + 0.0im, r, cis(alpha)])

t = Turtle()

tile!(t, tri)
for i in 2:4n
	reverse = (i % 2 == 0)
	start = (i % 2 == 0) ? 3 : 1
	tile!(t, i, tri, start = start, reverse = reverse)
end
move!(t, 2)

for i in 1:2n-1
	tile!(t, 1, tri, start = 2)
	tile!(t, 4, tri)
	tile!(t, 5, tri, start = 3, reverse = true)
	tile!(t, 6, tri, reverse = true)
	move!(t, 4)
	tile!(t, 1, tri, start = 3)
	move!(t, 2, 3)
	tile!(t, 4, tri, start = 3, reverse = true)
	move!(t, 3)
end

tile!(t, 1, tri, start = 2)
tile!(t, 4, tri)
tile!(t, 5, tri, start = 3, reverse = true)
tile!(t, 6, tri, reverse = true)
move!(t, 4)
tile!(t, 1, tri, start = 3)
move!(t, 2, 3)
tile!(t, 6, tri, start = 3, reverse = true)
move!(t, 1)

colors = Dict(
	3 => RGB(6 / 255, 141 / 255, 157 / 255),
)

plot!(t, colors = colors, output = "flower.svg")
