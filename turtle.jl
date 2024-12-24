using Makie, CairoMakie

const Point = Complex{Float64}
struct Node
    position::Point
    neighbors::Vector{Node}
    function Node(position::Point)
        new(position, [])
    end
end

Base.show(io::IO, node::Node) = print(io, "Node($(round(node.position, digits=2)))")

struct Turtle
    root::Ref{Node}
    function Turtle()
        root = Ref(Node(0.0 + 0.0im))
        new(root)
    end
end

Base.show(io::IO, turtle::Turtle) = print(io, "Turtle($(turtle.root[]))")

function link!(node1::Node, node2::Node)
    node1 == node2 && return
    node1 in node2.neighbors && return
    node2 in node1.neighbors && return
    push!(node1.neighbors, node2)
    push!(node2.neighbors, node1)
    return nothing
end

function dfs(callback::Function, node::Node, visited::Set{Node}=Set{Node}())
    node in visited && return
    callback(node)
    push!(visited, node)
    for neighbor in node.neighbors
        dfs(callback, neighbor, visited)
    end
    return nothing
end

function add_node!(turtle::Turtle, position::Point)
    root = turtle.root[]
    node = Node(root.position + position)
    link!(root, node)
    return nothing
end

function move!(turtle::Turtle, index::Int)
    root = turtle.root[]
    turtle.root[] = root.neighbors[index]
    return nothing
end

function plot!(turtle::Turtle, output::String="output.png")
    fig = Figure(size=(800, 800))
    ax = Axis(fig[1, 1], aspect = DataAspect())
    hidedecorations!(ax)
    hidespines!(ax)
    root = turtle.root[]
    dfs(root) do node
        scatter!(ax, [reim(node.position)], color= node == root ? :red : :blue)
        for neighbor in node.neighbors
            lines!(ax, [reim(node.position), reim(neighbor.position)], color=:blue)
        end
    end
    save(output, fig)
    return nothing
end