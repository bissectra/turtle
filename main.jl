include("./turtle.jl")

t = Turtle()

add_node!(t, 0.5 + 0.5im)
move!(t, 1)
add_node!(t, 0.5 - 0.5im)
add_node!(t, 0.5 - 0.5im) # does nothing, since the node already exists
plot!(t)