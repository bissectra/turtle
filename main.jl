include("./turtle.jl")

t = Turtle()

function ngon!(t::Turtle, n::Int, size::Real, direction::Real)
    w = size * cis(direction)
    for i in 1:n
        move!!(t, w)
        w *= cis(2π/n)
    end
end

move!!(t, 0.5 + 0.5im)
move!!(t, 0.5 + 0.5im)
move!!(t, -0.5 + 0.5im)
move!!(t, 0.5 - 0.5im)
move!(t, 2)
ngon!(t, 5, 0.5, 0)
plot!(t)