using Graphs

function day25()

	part = [0, 0]

	components = Dict{String, Set{String}}()
	names = String[]
	for line in filter!(!isempty, strip.(readlines("day25.txt")))
		a, btxt = split(line, r"\s*\:\s*")
		bs = split(strip(btxt))
		sa = get!(components, a, Set{String}())
		push!(names, a)
		for b in bs
			push!(sa, b)
			push!(names, b)
			barr = get!(components, b, Set{String}())
			push!(barr, a)
		end
	end
	vs = Dict(name => k for (k, name) in enumerate(sort!(unique(names))))
	println("There are $(length(vs)) components.")
	g = SimpleGraph()
	add_vertices!(g, length(vs))
	for (a, i) in vs
		for b in components[a]
			j = vs[b]
			if !has_edge(g, i, j)
				add_edge!(g, i, j)
			end
		end
	end
	println("There are $(length(edges(g))) edges.")
	@assert length(connected_components(g)) == 1
	alledges = sort!(collect(edges(g)), by = x -> length(get(components, x, 0)), rev = true)

	for e1 in alledges
		i, j = e1.src, e1.dst
		rem_edge!(g, i, j)
		for e2 in alledges
			m, n = e2.src, e2.dst
			i in [m, n] && j in [m, n] && continue
			rem_edge!(g, m, n)
			bri = bridges(g)
			if length(bri) > 0
				for e3 in bri
					p, q = e3.src, e3.dst
					rem_edge!(g, p, q)
					cc = connected_components(g)
					if length(cc) == 2
						part[1] = prod(map(length, cc))
						break
					end
					add_edge!(g, p, q)
				end
			end
			part[1] > 0 && break
			add_edge!(g, m, n)
		end
		part[1] > 0 && break
		add_edge!(g, i, j)
	end

	return part
end


@show day25()
