include("./turtle.jl")

t = Turtle()

function ngon!(t::Turtle, n::Int, size::Real, direction::Real)
    w = size * cis(direction)
    for i in 1:n
        move!!(t, w)
        w *= cis(2π/n)
    end
end

function trap!(t::Turtle, size::Real, direction::Real)
    w = size * cis(direction)
    move!!(t, w)
    w *= cis(π/2)
    move!!(t, 2w)
    w *= cis(3π/4)
    move!!(t, w*sqrt(2))
    w *= cis(π/4)
    move!!(t, w)
end

move!!(t, 0.5 + 0.5im)
move!!(t, 0.5 + 0.5im)
move!!(t, -0.5 + 0.5im)
move!!(t, 0.5 - 0.5im)
move!(t, 2)
ngon!(t, 5, 0.5, 0)
move!!(t, -10.0 + 0.0im)
trap!(t, 5, π/4)
plot!(t)