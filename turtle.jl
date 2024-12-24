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

function add_node!(turtle::Turtle, position::Point)::Node
    root = turtle.root[]
    position += root.position
    existing_node = nothing
    dfs(root) do node
        if abs(node.position - position) < 1e-6
            existing_node = node
            return
        end
    end
    !isnothing(existing_node) && return existing_node
    node = Node(position)
    link!(root, node)
    return node
end

function move!(turtle::Turtle, index::Int)
    root = turtle.root[]
    turtle.root[] = root.neighbors[index]
    return nothing
end

function move!(turtle::Turtle, position::Point, create::Bool=false)
    root = turtle.root[]
    if create
        node = add_node!(turtle, position)
        link!(root, node)
        turtle.root[] = node
        return nothing
    end
    position += root.position
    for neighbor in root.neighbors
        if abs(neighbor.position - position) < 1e-6
            turtle.root[] = neighbor
            return nothing
        end
    end
    error("No neighbor found at $position") 
end

move!!(turtle::Turtle, position::Point) = move!(turtle, position, true)

function Base.length(turtle::Turtle)
    ans = 0
    dfs(turtle.root[]) do node
        ans += 1
    end
    return ans
end

function plot!(turtle::Turtle, output::String="output.png")
    fig = Figure()
    ax = Axis(fig[1, 1], aspect = DataAspect())
    hidedecorations!(ax)
    hidespines!(ax)
    root = turtle.root[]
    dfs(root) do node
        scatter!(ax, [reim(node.position)], color= node == root ? :red : :blue, markersize=15)
        for (i, neighbor) in enumerate(node.neighbors)
            text_position = reim((2 * node.position + neighbor.position) / 3)
            mid_position = (node.position + neighbor.position) / 2
            lines!(ax, [reim(node.position), reim(mid_position)], color=:blue)
            scatter!(ax, [text_position], color=:white, markersize=20)
            text!(ax, text_position, text = string(i), color = :black, align = (:center, :center))
        end
    end
    save(output, fig)
    return nothing
end