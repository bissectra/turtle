include("./turtle.jl")

tile = Tile([0.0 + 0.0im, 1.0 + 0.0im, 1.0 + 2.0im, 0.0 + 1.0im])
t = Turtle([tile])

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

tile!(t, 1, 0, 2, true)
plot!(t)