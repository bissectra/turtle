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

struct Tile
    sides::Vector{Float64}
    angles::Vector{Float64}
    function Tile(polygon::Vector{Point})
        n = length(polygon)
        n < 3 && error("Polygon must have at least 3 sides")
        sides = [abs(polygon[i] - polygon[mod1(i + 1, n)]) for i in 1:n]
        a(p1, p2, p3) = mod2pi(angle((p1 - p2) / (p3 - p2)))
        angles = [a(polygon[mod1(i - 1, n)], polygon[i], polygon[mod1(i + 1, n)]) for i in 1:n]
        new(sides, angles)
    end
end

struct Turtle
    root::Ref{Node}
    tiles::Vector{Tile}
    function Turtle(tiles::Vector{Tile} = Tile[])
        root = Ref(Node(0.0 + 0.0im))
        new(root, tiles)
    end
end

function tile!(turtle::Turtle, index::Int, direction::Real)
    tile = turtle.tiles[index]
    w = cis(direction)
    for i in 1:length(tile.sides)
        move!!(turtle, tile.sides[i] * w)
        w *= cis(tile.angles[mod1(i+1, length(tile.sides))])
    end
    return nothing
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

function Base.intersect(p1::Point, p2::Point, p3::Point)
    # Check if p3 is on the line segment defined by p1 and p2
    x1, y1 = reim(p1)
    x2, y2 = reim(p2)
    x3, y3 = reim(p3)

    # Check for colinearity
    t = (x3 - x1) * (y2 - y1) - (y3 - y1) * (x2 - x1)
    if abs(t) > 1e-6
        return false
    end

    # Check if p3 is inside the line segment
    in_bounds_x = (x1 <= x3 <= x2) || (x2 <= x3 <= x1)
    in_bounds_y = (y1 <= y3 <= y2) || (y2 <= y3 <= y1)
    return in_bounds_x && in_bounds_y
end

function Base.intersect(p1::Point, p2::Point, p3::Point, p4::Point)
    x1, y1 = reim(p1)
    x2, y2 = reim(p2)
    x3, y3 = reim(p3)
    x4, y4 = reim(p4)
    a = (x1 - x2) * (y3 - y1) + (y1 - y2) * (x1 - x3)
    b = (x1 - x2) * (y4 - y1) + (y1 - y2) * (x1 - x4)
    c = (x3 - x4) * (y1 - y3) + (y3 - y4) * (x3 - x1)
    d = (x3 - x4) * (y2 - y3) + (y3 - y4) * (x3 - x2)
    return a * b < 0 && c * d < 0
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
    # Node not found, create a new one. But before, let's check if the new edge would intersect with any existing edge
    dfs(root) do node
        for neighbor in node.neighbors
            if intersect(node.position, neighbor.position, position)
                error("New edge intersects with existing edge")
            end
            if intersect(node.position, neighbor.position, root.position, position)
                error("New edge intersects with existing edge")
            end
        end
    end
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