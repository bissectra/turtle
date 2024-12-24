using Makie, CairoMakie, Colors

const Point = Complex{Float64}
struct Node
	position::Point
	neighbors::Vector{Node}
	Node(position::Point) = new(position, [])
end

Base.show(io::IO, node::Node) = print(io, "Node($(round(node.position, digits=2)))")

struct Turtle
	root::Ref{Node}
    Turtle() = new(Ref(Node(0.0 + 0.0im)))
	Turtle(root::Node) = new(Ref(root))
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

function dfs(callback::Function, node::Node, visited::Set{Node} = Set{Node}())
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
	return add_node!(turtle.root[], position)
end

function add_node!(root::Node, position::Point)::Node
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
	return turtle.root[]
end

function move!(turtle::Turtle, position::Point, create::Bool = false)
	root = turtle.root[]
	if create
		node = add_node!(turtle, position)
		link!(root, node)
		turtle.root[] = node
		return turtle.root[]
	end
	position += root.position
	for neighbor in root.neighbors
		if abs(neighbor.position - position) < 1e-6
			turtle.root[] = neighbor
			return turtle.root[]
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

function plot!(turtle::Turtle; colors=nothing, output = "output.png", number_edges = false, plot_root = false)
	root = turtle.root[]
	fs = faces(root)
	if isnothing(colors)
        colors = distinguishable_colors(maximum([length(face) for face in fs]))	
	end
	fig = Figure()
	ax = Axis(fig[1, 1], aspect = DataAspect())
	hidedecorations!(ax)
	hidespines!(ax)
    for face in fs
        polygon = [reim(node.position) for node in face]
        poly!(ax, polygon, color=(colors[length(polygon)], 0.5))
    end
	dfs(root) do node
		for (i, neighbor) in enumerate(node.neighbors)
			text_position = reim((2 * node.position + neighbor.position) / 3)
			mid_position = (node.position + neighbor.position) / 2
			lines!(ax, [reim(node.position), reim(mid_position)], color = :blue)
			if number_edges
				scatter!(ax, [text_position], color = :black, markersize = 20)
				text!(ax, text_position, text = string(i), color = :white, align = (:center, :center))
			end
		end
	end
    plot_root && scatter!(ax, [reim(root.position)], color = :red, markersize = 20)
	save(output, fig)
	return nothing
end

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

function tile!(turtle::Turtle, index::Int, tile::Tile, start::Int = 1, reverse::Bool = false)
    root = turtle.root[]
    direction = root.neighbors[index].position - root.position
    tile!(turtle, tile, angle(direction), start, reverse)
    return nothing
end

function tile!(turtle::Turtle, tile::Tile, direction::Real = 0, start::Int = 1, reverse::Bool = false)
	w = cis(direction)
	range = reverse ? vcat(start:-1:1, length(tile.sides):-1:start+1) : vcat(start:length(tile.sides), 1:start-1)
	for i in range
		move!!(turtle, tile.sides[i] * w)
		w *= cis(π - tile.angles[mod1(i + (reverse ? 0 : 1), length(tile.sides))])
	end
	return nothing
end

function ngon(n::Int, size::Real = 1.0)::Tile
	points = [cis(2π * i / n) for i in 0:n-1]
	side = abs(points[2] - points[1])
	return Tile(points / side * size)
end

function next(u::Node, v::Node)
    # returns next edge in the cycle
    # sort v's neighbors by angle
    neighbors = v.neighbors
    n = length(neighbors)
    angles = [angle(neighbor.position - v.position) for neighbor in neighbors]
    order = sortperm(angles)
    # return the neighbor that comes before u
    for i in 1:n
        if neighbors[order[i]] == u
            return neighbors[order[mod1(i - 1, n)]]
        end
    end
    error("u is not a neighbor of v")
end

function face(u::Node, v::Node)
    # returns the face that the edge uv is part of
    ans = [u, v]
    while true
        u, v = v, next(u, v)
        if v == ans[1]
            return ans
        end
        push!(ans, v)
    end
end

Base.isless(u::Node, v::Node) = reim(u.position) < reim(v.position)

function faces(root::Node)
    # returns all faces in the graph, withouth duplicates, and without the outer face
    ans = Vector{Node}[]
    dfs(root) do node
        for neighbor in node.neighbors
            f = face(node, neighbor)
            # find the minimum element in f
            min_index = argmin(f)
            # if the node is the minimum element, add the face
            if f[min_index] == node
                push!(ans, f)
            end
        end
    end
    # remove face with highest length
    max_index = argmax([length(face) for face in ans])
    splice!(ans, max_index)
    return ans
end

function tile!(turtle::Turtle, n::Int, tiles::Vararg{Tile, N}) where N
    tile!(turtle, n, tiles[1])
    n = length(turtle.root[].neighbors)
    for tile in tiles[2:end]
        tile!(turtle, n, tile)
        n += 1
    end
    return nothing
end

function move!(turtle::Turtle, indices::Vararg{Int, N}) where N
    for index in indices
        move!(turtle, index)
    end
    return turtle.root[]
end

function transform(f::Function, root::Node)::Node
    new_nodes = Dict{Node, Node}()
    new_root = Node(f(root.position))
    new_nodes[root] = new_root

    dfs(root) do node
        new_node = get!(new_nodes, node, Node(f(node.position)))
        for neighbor in node.neighbors
            new_neighbor = get!(new_nodes, neighbor, Node(f(neighbor.position)))
            link!(new_node, new_neighbor)
        end
    end
    return new_root
end

function transform(f::Function, turtle::Turtle)
	Turtle(transform(f, turtle.root[]))
end

function nodes(root::Node)
	ans = Node[]
	dfs(root) do node
		push!(ans, node)
	end
	return ans
end

function destruct!(node::Node)
	for neighbor in node.neighbors
		deleteat!(neighbor.neighbors, findfirst(x->x===node, neighbor.neighbors))
	end
	return nothing
end

function merge!(node1::Node, node2::Node)
	abs(node1.position - node2.position) < 1e-6 || error("Nodes are not at the same position")
	for neighbor in node2.neighbors
		link!(node1, neighbor)
	end
	destruct!(node2)
	return nothing
end

function merge!(turtle1::Turtle, turtle2::Turtle)
	root1 = turtle1.root[]
	root2 = turtle2.root[]
	delta = root1.position - root2.position
	root2 = transform(p -> p + delta, root2)
	nodes1 = nodes(root1)
	nodes2 = nodes(root2)
	for node1 in nodes1, node2 in nodes2
		if abs(node1.position - node2.position) < 1e-6
			merge!(node1, node2)
		end
	end
	return nothing
end

function transform!(f::Function, turtle::Turtle, moves::Vararg{Int, N}) where N
	new_turtle = transform(f, turtle)
	move!(new_turtle, moves...)
	merge!(turtle, new_turtle)
	return nothing
end