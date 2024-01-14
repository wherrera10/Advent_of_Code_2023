const day2game = [Int16[], Int16[], Int16[]]

function day02()
	part = [0, 0]
	part1vals = [12, 13, 14] # red, green, blue
	games = Vector{Vector{Int}}[]
	for (i, line) in enumerate(readlines("day02.txt"))
		push!(games, deepcopy(day2game))
		numcols = split(line, r"\:|\;")[begin+1:end]
		for nc in numcols
			foreach(i -> push!(games[end][i], 0), 1:3)
			nc = split(nc, ",")
			for s in nc
				n, c = strip.(split(s))
				i = c[1] == 'r' ? 1 : c[1] == 'g' ? 2 : 3
				games[end][i][end] = parse(Int, n)
			end
		end
	end
	part[1] = sum(gamenum * all(!any(game[i][j] > part1vals[i] for i in 1:3, 
	   j in eachindex(game[begin]))) for (gamenum, game) in enumerate(games))
	part[2] = sum(prod(maximum(game[i][j] for j in eachindex(game[begin]))
	   for i in 1:3) for game in games)
	return part
end

@time day02()
