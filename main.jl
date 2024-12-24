include("./turtle.jl")

t = Turtle()

move!!(t, 0.5 + 0.5im)
move!!(t, 0.5 + 0.5im)
move!!(t, -0.5 + 0.5im)
move!!(t, 0.5 - 0.5im)
plot!(t)