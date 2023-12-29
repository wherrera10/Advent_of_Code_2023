const dirs = CartesianIndex.([(0, 1), (1, 0), (0, -1), (-1, 0)]) # E S W N

function day21()
	part = [0, 0]
	grid = Char.(stack(Iterators.map(collect, eachline("day21.txt")), dims = 1))
	nrows, ncols = size(grid)
	start = first(findall(==('S'), grid))

	@show nrows, ncols, start
	grid[start] = '.'
	paths = [start]
	for _ in 1:nrows÷2-1
		newpaths = empty(paths)
		for p in paths
			append!(newpaths, neighbors(p, grid, nrows, ncols))
		end
		unique!(newpaths)
		empty!(paths)
		append!(paths, newpaths)
	end
	part[1] = length(unique(paths))
	@show part[1]

	reached = Int[]
	biggrid = repeat(grid, outer = (5, 5))
	start2 = CartesianIndex(nrows * 2 + nrows ÷ 2 + 1, ncols * 2 + ncols ÷ 2 + 1)
	biggrid[start2] = 'O'
	empty!(reached)
	foreach(_ -> floodfill!(biggrid), 1:nrows÷2)
	push!(reached, count(==('O'), biggrid))
	foreach(_ -> floodfill!(biggrid), 1:nrows)
	push!(reached, count(==('O'), biggrid))
	foreach(_ -> floodfill!(biggrid), 1:nrows)
	push!(reached, count(==('O'), biggrid))
	a = (reached[3] - 2 * reached[2] + reached[1]) / big"2"
	b = (4 * reached[2] - 3 * reached[1] - reached[3]) / big"2"
	c = BigFloat(reached[1])
	t = (26501365 - nrows ÷ 2) ÷ nrows
	part[2] = BigInt(round(a * t^2 + b * t + c))

	return part
end

function neighbors(c, grid, nrows, ncols)
	neigh = CartesianIndex[]
	for d in dirs
		newc = d + c
		if 1 <= newc[1] <= nrows && 1 <= newc[2] <= ncols && grid[newc] == '.'
			push!(neigh, newc)
		end
	end
	return neigh
end

function floodfill!(grid)
	current = findall(==('O'), grid)
	grid[current] .= '.'
	for c in current, d in dirs
		if grid[c+d] != '#'
			grid[c+d] = 'O'
		end
	end
end

@show day21()
