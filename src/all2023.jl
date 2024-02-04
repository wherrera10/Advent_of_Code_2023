#=====================================================================================

 Day     Seconds
=================
day01   0.0020703
day02   0.0005306
day03   0.0008936
day04   0.0007012
day05   0.001427
day06   0.0033411
day07   0.0006545
day08   0.0072264
day09   0.0004193
day10   0.0045974
day12   0.0329516
day13   0.0205552
day14   0.0390052
day15   0.0025725
day16   0.0146756
day17   0.0245665
day18   0.0003224
day19   0.0011843
day20   0.0212883
day21   0.0308489
day22   0.001042
day23   0.0698638
day24   0.0069634
day25   0.0174461
=================
Total   0.3051472


======================================================================================#

using BenchmarkTools
using DataStructures
using Graphs
using Ipopt
using JuMP
using Memoize
using MetaGraphsNext
import LLVM.Interop.assume # little documented optimization, see code in github.com/Zentrik
import Base.:+

function day01()
    part = [0, 0]
    snums = Dict("one" => '1', "two" => '2', "three" => '3', "four" => '4', "five" => '5', "six" => '6', "seven" => '7', "eight" => '8', "nine" => '9')
    s1, s2 = Char[], Char[]
    for line in Iterators.filter(!isempty, strip.(readlines("day01.txt")))
        empty!(s1)
        empty!(s2)
        for (i, c) in enumerate(line)
            if isdigit(c)
                push!(s1, c)
                push!(s2, c)
            end
            for (v, k) in snums
                startswith((@view line[i:end]), v) && push!(s2, k)
            end
        end
        part[1] += parse(Int, s1[begin] * s1[end])
        part[2] += parse(Int, s2[begin] * s2[end])
    end
    return part
end


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

function surroundsymbols(a, i, rows, cols)
    ret = Pair{Char, Int}[]
    x0, y0 = mod1(i, cols), (i - 1) ÷ cols + 1
    xrange = max(1, x0 - 1):min(cols, x0 + 1)
    yrange = max(1, y0 - 1):min(rows, y0 + 1)
    for x in xrange, y in yrange
        x == x0 && y == y0 && continue
        j = (y - 1) * cols + x
        c = a[j]
        c != '.' && !isspace(c) && !isdigit(c) && push!(ret, c => j)
    end
    return ret
end


function day03()
    txt = read("day03.txt", String)
    chars = collect(txt)
    locations = Vector{Pair{Int, Vector{Int}}}()
    gearnumbers = Dict{Int, Set{Int}}()
    part = [0, 0]

    for m in eachmatch(r"\d+", txt)
        range = m.match.offset+1:m.match.offset+m.match.ncodeunits
        n = parse(Int, txt[range])
        push!(locations, n => sort!(collect(range)))
    end

    for loc in locations
        bysymbol = false
        for i in last(loc)
            !isempty(surroundsymbols(chars, i, 140, 141)) && (bysymbol = true)
        end
        bysymbol && (part[1] += first(loc))
    end

    for loc in locations
        for i in loc[2], p in unique(surroundsymbols(chars, i, 140, 141))
            if any(p -> p[1] == ('*'), p)
                !haskey(gearnumbers, p[2]) && (gearnumbers[p[2]] = Set{Int}())
                push!(gearnumbers[p[2]], loc[1])
            end
        end
    end

    for gear in gearnumbers
        if length(gear[2]) == 2
            part[2] += prod(gear[2])
        end
    end
    return part
end


const scores4 = Dict{Int, Int}()
@memoize scoring(i) = scores4[i] < 1 ? 0 : scores4[i] + sum(scoring(j) for j in i+1:i+scores4[i])

function day04()
    part = [0, 0]
    lines = readlines("day04.txt")
    for (i, line) in enumerate(lines)
        winners, have = [parse.(Int, split(s)) for s in split(line, r"\:|\|")[begin+1:end]]
        scores4[i] = length(intersect(winners, have))
        if scores4[i] > 0
            part[1] += exp2(scores4[i] - 1)
        end
    end
    part[2] = sum(scoring(i) + 1 for i in eachindex(lines))
    return part
end


function day05()
	groups = strip.(split(read("day05.txt", String), "\n\n"))
	part1seeds = [parse(Int, s) for s in split(groups[begin], r"\s+")[2:end]]
	dicts = Dict{Vector{Int}, Vector{Int}}[]
	part = [0, 0]

	for grp in groups[begin+1:end]
		d = Dict{Vector{Int}, Vector{Int}}()
		lines = split(grp, "\n")[begin+1:end]
		for line in lines
			v, k, delt = [parse(Int, strip(s)) for s in split(strip(line), r"\s+")]
			d[[k, k + delt - 1]] = [v, v + delt - 1]
		end
		push!(dicts, d)
	end

	function location(i)
		for d in dicts
			for (rk, rv) in d
				if i in rk[1]:rk[2]
					i = rv[1] - rk[1] + i
					break
				end
			end
		end
		return i
	end

    part[1] = minimum(location, part1seeds)

    getinterval(sta, sto) = (sto - sta) ÷ 100

	ranges = [part1seeds[i]:getinterval(part1seeds[i], part1seeds[i] + part1seeds[i+1] - 1
       ) : part1seeds[i]+part1seeds[i+1]-1 for i in 1:2:length(part1seeds)-1]
	bestrange = findmin([minimum(location, r) for r in ranges])[begin+1]
	r = ranges[bestrange].start:ranges[bestrange].stop
	while length(r) > 1000
		qdelt = (r.stop - r.start) ÷ 4
		r = findmin(location(x) for x in r.start:getinterval(r.start, r.stop):r.stop)[2] < 50 ?
			(r.start:r.stop-qdelt) : (r.start+qdelt:r.stop)
	end
	part[2] = minimum(location, r)

	return part
end


function day06()
    part = [0, 0]

    lines = split(read("day06.txt", String), "\n")
    times, distances = [[parse(Int, x) for x in split(lines[i])[2:end]] for i in 1:2]

    part1bests(t, d) = count((t - wait) * wait > d for wait in 1:t)

    part[1] = prod([part1bests(times[r], distances[r]) for r in eachindex(times)])

    bigtime, bigdist = [parse(Int, prod(split(lines[i])[2:end])) for i in 1:2]
    begintime = findfirst(w -> (bigtime - w) * w > bigdist, 1:bigtime)

    part[2] = bigtime - begintime - begintime + 1

    return part 
end


function day07()
    part = [0, 0]
    txt = read("day07.txt", String)
    entries = split(replace(txt, "T" => "a", "J" => "b", "Q" => "c", "K" => "d", "A" => "e"))
    hands = [h for (i, h) in enumerate(entries) if isodd(i)]
    wildhands = map(s -> replace(s, "b" => "1"), hands)
    bids = [parse(Int, h) for (i, h) in enumerate(entries) if iseven(i)]

    function score(hand)
        most2, most = sort!([count(==(x), hand) for x in "123456789abcde"])[end-1:end]
        return most * 10 + most2
    end

    function wildscore(sco, hand)
        numj = count(==('b'), hand)
        return numj == 0 ? sco : numj == 5 ? 50 : numj == 4 ? 50 : numj == 3 ? (sco == 32 ? 50 : 41) :
            numj == 2 ? (sco == 32 ? 50 : sco == 22 ? 41 : 31) :
            (sco == 41 ? 50 : sco == 31 ? 41 : sco == 22 ? 32 : sco == 21 ? 31 : 21)
    end

    scores = map(score, hands)
    wildscores = map(i -> wildscore(scores[i], hands[i]), eachindex(scores))

    part[1] = sum(x[3] * i for (i, x) in enumerate(sort!(collect(zip(scores, hands, bids)))))
    part[2] = sum(x[3] * i for (i, x) in enumerate(sort!(collect(zip(wildscores, wildhands, bids)))))
    return part
end


function day08()
    part = [0, 0]
    LRtxt, equations = split(read("day08.txt", String), "\n\n")
    LR = collect(strip(LRtxt))
    nodes = Dict{String,Vector{String}}()
    for eq in Iterators.filter(!isempty, split(equations, "\n"))
        n, l, r = string.(split(eq, r"[\s\=,\(\)]+"))
        nodes[n] = [l, r]
    end
    node = "AAA"
    cindex, maxindex = 0, length(LR)
    command() = LR[mod1(cindex += 1, maxindex)]
    for steps in 1:typemax(Int32)
        c = command()
        l, r = nodes[node]
        node = c == 'L' ? l : r
        if node == "ZZZ"
            part[1] = steps
            break
        end
    end

    ghosts = collect(filter(s -> endswith(s, "A"), keys(nodes)))
    cindex = 0
    nsteps = zeros(Int, length(ghosts))
    for (i, g) in enumerate(ghosts)
        cindex = 0
        for steps in 1:typemax(Int32)
            c = command()
            l, r = nodes[g]
            g = c == 'L' ? l : r
            if endswith(g, "Z")
                nsteps[i] = steps
                break
            end
        end
    end
    part[2] = lcm(nsteps)

    return part # 18673, 17972669116327
end


function day09()
    part = [0, 0]
    for line in eachline("day09.txt")
        a = [parse.(Int, split(line))]
        while !iszero(last(a))
            push!(a, diff(last(a)))
        end
        for row in lastindex(a)-1:-1:firstindex(a)
            push!(a[row], last(a[row+1]) + last(a[row]))
            pushfirst!(a[row], first(a[row]) - first(a[row+1]))
        end
        part[1] += last(first(a))
        part[2] += first(first(a))
    end
    return part # 2008960228, 1097
end


function day10()
    part = [0, 0]
    moves = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    charmove = Dict{Char, Vector{Int}}('L' => [1, 4], '|' => [2, 4], '-' => [1, 3], '7' => [2, 3],
                                       'F' => [1, 2], 'J' => [3, 4], '.' => Int[])
    mat = Char.(reshape(collect(read("day10.txt")), (141, 140))')
    x, y, move, nvisited = 43, 26, 1, 0
    visited = Dict{Vector{Int}, Int}([x, y] => 0)
    mat[x, y] = '7'
    while true
        move = first(setdiff(charmove[mat[x, y]], [3, 4, 1, 2][move]))
        x, y = [x, y] .+ moves[move]
        nvisited += 1
        haskey(visited, [x, y]) && break
        visited[[x, y]] = nvisited
    end
    part[1] = (nvisited + 1) ÷ 2

    graph = fill('.', 280, 282)
    for (x, y) in keys(visited)
        c = mat[x, y]
        graph[2x-1, 2y-1] = c
        if c == '-' || c == 'L' || c == 'F'
            graph[2x-1, 2y] = '-'
        end
        if c == '|' || c == '7' || c == 'F'
            graph[2x, 2y-1] = '|'
        end
    end
    for x in 1:280, y in [1, 282]
        graph[x, y] == '.' && floodfill!(graph, x, y, 280, 282)
    end
    part[2] = count(==('.'), graph[1:2:280, 1:2:281])

    return part
end

function floodfill!(m::Matrix, x, y, xdim, ydim)
    for i in max(1, x-1):min(x+1, xdim), j in max(1, y-1):min(y+1, ydim)
        if m[i, j] == '.'
            m[i, j] = ' '
            floodfill!(m, i, j, xdim, ydim)
        end
    end
end


function day11()
    part = [0, 0]
    mat = reshape(filter(!=(Int32('\n')), read("day11.txt")), 140, 140)'
    nr, nc = Int[], Int[]
    for (i, r) in enumerate(eachrow(mat))
        all(==(Int32('.')), r) && push!(nr, i)
    end
    for (i, c) in enumerate(eachcol(mat))
        all(==(Int32('.')), c) && push!(nc, i)
    end

    xp = [2, 1_000_000]
    gal = Tuple.(findall(==(UInt8('#')), mat))
    for k in eachindex(xp), i in 1:lastindex(gal)-1, j in i+1:lastindex(gal)
        x1, y1 = gal[i]
        x2, y2 = gal[j]
        part[k] += dist(x1, y1, x2, y2) + xpan(x1, x2, nr, xp[k]) + xpan(y1, y2, nc, xp[k])
    end

    return part
end

dist(x1, y1, x2, y2) = abs(x1 - x2) + abs(y1 - y2)
xpan(a, b, empties, xpan) = count(i -> i ∈ empties, a < b ? (a:b-1) : (b:a-1)) * (xpan - 1)


struct Spring12
    pattern::Vector{Char}
    groups::Vector{Int}
end

function day12()
    part = [0, 0]
    springs = Spring12[]
    for line in readlines("day12.txt")
        pat, grouptxt = split(line)
        push!(springs, Spring12(collect(pat), [parse(Int, x) for x in split(grouptxt, ",")]))
    end

    part[1] = sum(solve12(s, 1) for s in springs)
    part[2] = sum(solve12(s, 5) for s in springs)

    return part
end

function solve12(spring, repeats)
    springsum = 0
    broken = zeros(Int, 200)
    table = zeros(Int, 10_000)

    pattern = repeat(vcat(spring.pattern, '?'), repeats)
    pattern[end] = '.'
    groups = repeat(spring.groups, repeats)
    for (i, b) in enumerate(pattern)
        b != '.' && (springsum += 1)
        broken[i + 1] = springsum
    end
    wiggle = length(pattern) - sum(groups) - length(groups) + 1
    siz = first(groups)
    springsum = 0
    valid = true
    for i in 1:wiggle
        if pattern[i + siz] == '#'
            springsum = 0
        elseif valid && broken[i + siz] - broken[i] == siz
            springsum += 1
        end
        table[i + siz] = springsum
        valid &= pattern[i] != '#'
    end
    start = siz + 1
    for (row, gsize) in enumerate(@view groups[2:end])
        previous = (row - 1) * length(pattern)
        current = row * length(pattern)
        springsum = 0
        for i in start:start+wiggle
            if pattern[i + gsize] == '#'
                springsum = 0
            elseif table[previous + i - 1] > 0 &&
               pattern[i - 1] != '#' && broken[i + gsize] - broken[i] == gsize
                springsum += table[previous + i - 1]
            end
            table[current + i + gsize] = springsum
        end
        start += gsize + 1
    end
    return springsum
end


function day13()
    part = [0, 0]

    patterns = split(read("day13.txt", String), "\n\n")
    mats = Matrix{Bool}[]
    for p in patterns
        rows = [[i =='#' for i in a] for a in split(p)]
        m = reduce(vcat, map(a -> a', rows))
        push!(mats, m)
        rdelta, cdelta = findmirror(m)
        part[1] += cdelta + 100 * rdelta
    end

    for m in mats
        oldr, oldc = findmirror(m)
        for i in eachindex(m)
            m[i] = !m[i]
            rdelta, cdelta = findmirror(m, oldr, oldc)
            m[i] = !m[i]
            if rdelta > 0 || cdelta > 0
                part[2] += cdelta + 100 * rdelta
                break
            end
        end
    end
    return part
end

function findmirror(m, forbidrow = 0, forbidcol = 0)
    nrows, ncols = size(m)
    rdelta, cdelta = 0, 0
    for i in 1:nrows-1
        i == forbidrow && continue
        d = min(i, nrows - i)
        if m[i-d+1:i, :] == reverse(m[i+1:i+d, :], dims=1)
            rdelta = i
            break
        end
    end
    for i in 1:ncols-1
        i == forbidcol && continue
        d = min(i, ncols - i)
        if m[:, i-d+1:i] == reverse(m[:, i+1:i+d], dims=2)
            cdelta = i
            break
        end
    end
    return rdelta, cdelta
end


function day14()
    part = [0, 0]
    targetspins = 1_000_000_000
    grid = stack(Iterators.map(collect, eachline("day14.txt")), dims = 1)
	nrows, ncols = size(grid)

    countrocks(grid, nrows, ncols) = sum((nrows - i + 1) * (grid[i, j] == 'O') for i in 1:nrows, j in 1:ncols)

    function rolln!(m, nrows, ncols)
        for row in 2:nrows, col in 1:ncols
            m[row, col] == 'O' && rockn!(m, row, col)
        end
    end

    function rockn!(m, row, col)
        while row > 1
            m[row-1, col] != '.' && return
            m[row, col] = '.'
            m[row-1, col] = 'O'
            row -= 1
        end
    end  

    function rollw!(m, nrows, ncols)
        for row in 1:nrows, col in 2:ncols
            m[row, col] == 'O' && rockw!(m, row, col)
        end
    end

    function rockw!(m, row, col)
        while col > 1
            m[row, col-1] != '.' && return           
            m[row, col] = '.'
            m[row, col-1] = 'O'           
            col -= 1
        end
    end  

    function rolls!(m, nrows, ncols)
        for row in nrows-1:-1:1, col in 1:ncols
            m[row, col] == 'O' && rocks!(m, row, col, nrows)
        end
    end

    function rocks!(m, row, col, nrows)
        while row < nrows
            m[row+1, col] != '.' && return
            m[row, col] = '.'
            m[row+1, col] = 'O'
            row += 1
        end
    end

    function rolle!(m, nrows, ncols)
        for row in 1:nrows, col in ncols-1:-1:1
            m[row, col] == 'O' && rocke!(m, row, col, ncols)
        end
    end

    function rocke!(m, row, col, ncols)
        while col < ncols      
            m[row, col+1] != '.' && return           
            m[row, col] = '.'
            m[row, col+1] = 'O'           
            col += 1
        end
    end

    mat = deepcopy(grid)
    rolln!(mat, nrows, ncols)
    part[1] = countrocks(mat, nrows, ncols)

    cycleroll!(m, r, c) = (rolln!(m, r, c); rollw!(m, r, c); rolls!(m, r, c); rolle!(m, r, c))

    pastmats = String[]
    pastscores = Int[]
    idx = 0  
    while true   
        cycleroll!(grid, nrows, ncols)
        s = String(vec(grid))
        idx = findfirst(==(s), pastmats)
        if !isnothing(idx)
            precycle = idx
            cyclelength = length(pastmats) - precycle + 1
            remaining = mod1(targetspins - precycle + 1, cyclelength)
            part[2] = pastscores[precycle + remaining - 1]
            break
        end
        push!(pastmats, s)
        push!(pastscores, countrocks(grid, nrows, ncols))
    end
    return part
end


function day15()
    part = [0, 0]

    hash15(c::Integer, prev) = ((prev + Int(c)) * 17) % 256
    hash15(v::Vector) = reduce(hash15, v, init = 0)
    hash15(s::AbstractString) = hash15(Int.(collect(s)))

    part1steps = split(read("day15.txt", String), ",")
    part[1] = sum(hash15.(part1steps))

    part2steps = Tuple{String, Int, Int}[]
    for s in filter(!isempty, strip.(part1steps))
        if last(s) == '-'
            push!(part2steps, (s[begin:end-1], hash15(s[begin:end-1]), 0))
        else
            b, i = split(s, "=")
            push!(part2steps, (b, hash15(b), parse(Int, i)))
        end
    end
    boxes = [Vector{Tuple{String, Int, Int}}() for _ in 1:256]
    for t in part2steps
        b = boxes[t[2] + 1] # zero based index to 1-based here
        if t[3] == 0 # remove
            filter!(x -> t[1] != x[1], b)
        else # add or replace
            if isempty(b)
                push!(b, t) # add
            else
                for (i, lens) in enumerate(b)
                    if t[1] == lens[1]
                        b[i] = t  # replace
                        break
                    end
                    if i == lastindex(b)
                        push!(b, t) # add
                    end
                end
            end
        end
    end
    for (bnum, box) in enumerate(boxes), (slotnum, lens) in enumerate(box)
        part[2] += bnum * slotnum * lens[3]
    end

    return part
end


const N, E, S, W = (-1, 0), (0, 1), (1, 0), (0, -1)
const dir16 = [N, E, S, W]

function day16()
	part = [0, 0]

	grid = stack(Iterators.map(collect, eachline("day16.txt")), dims = 1)
	nrows, ncols = size(grid)
    energized = zeros(UInt8, nrows, ncols)
	countgrid!(grid, energized, 1, 1, E)
	part[1] = count(!=(0x0), energized)

    energized = zeros(UInt8, nrows, ncols)

    for x in 1:nrows
        energized .= 0x0
        countgrid!(grid, energized, x, 1, E)
        part[2] = max(part[2], count(!=(0x0), energized))

        energized .= 0x0
        countgrid!(grid, energized, x, ncols, W)
        part[2] = max(part[2], count(!=(0x0), energized))
    end

    for y in 1:ncols
        energized .= 0x0
        countgrid!(grid, energized, 1, y, S)
        part[2] = max(part[2], count(!=(0x0), energized))

        energized .= 0x0
        countgrid!(grid, energized, nrows, y, N)
        part[2] = max(part[2], count(!=(0x0), energized))
    end

    return part
end

function countgrid!(grid, energized, startx, starty, dir)
    checkbounds(Bool, grid, startx, starty) || return

	b = dir == N ? 1 : dir == E ? 2 : dir == S ? 4 : 8
	energized[startx, starty] & b != 0 && return
    energized[startx, starty] |= b

	ch = grid[startx, starty]
	if ch == '|'
		if dir == E || dir == W
			dir = N
			countgrid!(grid, energized, startx + S[1], starty + S[2], S)
		end
	elseif ch == '-'
		if dir == N || dir == S
			dir = E
			countgrid!(grid, energized, startx + W[1], starty + W[2], W)
		end
	elseif ch == '/'
		dir = dir == N ? E : dir == E ? N : dir == S ? W : S
	elseif ch == '\\'
		dir = dir == N ? W : dir == E ? S : dir == S ? E : N
	end
    countgrid!(grid, energized, startx + dir[1], starty + dir[2], dir)
end


function day17()
    part = [0, 0]

    function solve(grid, nrows, ncols, smin, smax)
        q = PriorityQueue{Tuple{Int,Int,Int},Int}()
        cost = fill(typemax(Int32), nrows, ncols, 2)
        cost[begin, begin, :] .= 0
        enqueue!(q, (1, 1, 1), 0)
        enqueue!(q, (1, 1, 2), 0)
        while !isempty(q)
            x, y, direction = dequeue!(q)
            x == nrows && y == ncols && return min(cost[nrows, ncols, 1], cost[nrows, ncols, 2])
            if direction == 1  # we moved horizontal, so now we need to move vertical
                steps = 0
                for i in 1:smax
                    x - i < 1 && break
                    steps += Int(grid[x - i, y])
                    if i >= smin && cost[x-i,y,2] > steps + cost[x,y,1]
                        cost[x-i,y,2] = steps + cost[x,y,1]
                        q[(x - i, y, 2)] = cost[x - i, y, 2]
                    end
                end
                steps = 0
                for i in 1:smax
                    x + i > nrows && break
                    steps += Int(grid[x + i, y])
                    if i >= smin && cost[x+i,y,2] > steps + cost[x,y,1]
                        cost[x+i,y,2] = steps + cost[x,y,1]
                        q[(x + i, y, 2)] = cost[x + i, y, 2]
                    end
                end
            else
                steps = 0
                for j in 1:smax
                    y - j < 1 && break
                    steps += Int(grid[x, y - j])
                    if j >= smin && cost[x, y - j, 1] > steps + cost[x, y, 2]
                        cost[x, y - j, 1] = steps + cost[x, y, 2]
                        q[(x, y - j, 1)] = cost[x, y - j, 1]
                    end
                end
                steps = 0
                for j in 1:smax
                    y + j > ncols && break
                    steps += Int(grid[x, y + j])
                    if j >= smin && cost[x, y + j, 1] > steps + cost[x, y, 2]
                        cost[x, y + j, 1] = steps + cost[x, y, 2]
                        q[(x, y + j, 1)] = cost[x, y + j, 1]
                    end
                end
            end
        end
    end

    grid = reduce(hcat, (parse.(Int, s) for s in collect.(readlines("day17.txt"))))
    nrows, ncols = size(grid)
    part[1] = solve(grid, nrows, ncols, 1, 3)
    part[2] = solve(grid, nrows, ncols, 4, 10)
    return part

end


function day18()
    part = [0, 0]

    lines = readlines("day18.txt")
    dir = CartesianIndex.([(0, 1), (1, 0), (0, -1), (-1, 0)]) # E S W N
    pos1, pos2 = CartesianIndex(0, 0), CartesianIndex(0, 0)
    total, circ = 0 , 0
    total2, circ2 = 0, 0
    for line in lines
        d, n, c = strip.(split(line))
        direc = d == "U" ? 4 : d == "R" ? 1 : d == "D" ? 2 : d == "L" ? 3 : 100
        oldpos = pos1
        pos1 += parse(Int, n) * dir[direc]
        total += oldpos[1] * pos1[2] - oldpos[2] * pos1[1]
        circ += abs(oldpos[1] - pos1[1]) + abs(pos1[2] - oldpos[2])

        d, n = parse(Int, c[end-1:end-1]), parse(Int, string(c[3:end-2]), base=16)
        direc = d == 0 ? 1 : d == 1 ? 2 : d == 2 ? 3 : d == 3 ? 4 : 100
        oldpos = pos2
        pos2 += n * dir[direc]
        total2 += oldpos[1] * pos2[2] - oldpos[2] * pos2[1]
        circ2 += abs(oldpos[1] - pos2[1]) + abs(pos2[2] - oldpos[2])
    end

    part[1] = (abs(total) +  circ) ÷ 2 + 1
    part[2] = (abs(total2) +  circ2) ÷ 2 + 1

    return part

end


function day19()
    part = [0, 0]

    workflows = Dict{String, Vector{Vector{String}}}()
    wrk, par = split(read("day19.txt", String), "\n\n")
    for line in filter!(!isempty, strip.(split(wrk, "\n")))
        rul, tests = split(line[begin:end-1], "{")
        workflows[rul] = [split(s, ":") for s in split(tests, ",")]
    end
    parts = [[parse(Int, m.match) for m in eachmatch(r"\d+", line)] for line in filter!(!isempty, split(par, "\n"))]

    # part 1
    for p in parts
        wrule = "in"
        while true
            rules = workflows[wrule]
            x, m, a, s = p # xmas, hahaha
            for r in rules
                if length(r) == 1
                    wrule = first(r)
                    break
                end
                c = first(r)[1]
                n = parse(Int, first(r)[3:end])
                k = c == 'x' ? x : c == 'm' ? m : c == 'a' ? a : s
                if first(r)[2] == '>' && k > n
                    wrule = last(r)
                    break
                elseif first(r)[2] == '<' && k < n
                    wrule = last(r)
                    break
                end
            end
            if wrule == "A"
                part[1] += sum(p)
                break
            elseif wrule == "R"
                break
            end
        end
    end

    # part 2 is via the recursive function below this one
    part[2] = countcombos(workflows, [1:4000, 1:4000, 1:4000, 1:4000], "in")

    return part
end

function countcombos(workflows, rvec, flow::String)
    flow == "R" && return 0
    flow == "A" && return prod(r.stop - r.start + 1 for r in rvec)
    usedefault, combocount, rulelist = true, 0, workflows[flow]
    rules = rulelist[begin:end-1]
    default = rulelist[end][begin]

    for r in rules
        c = first(r)[1:1]
        n = parse(Int, first(r)[3:end])
        ridx = findfirst(c, "xmas")[begin] # giggles
        rang = rvec[ridx]
        succeed, fail = first(r)[2] == '<' ? (rang.start:n-1, n:rang.stop) : (n+1:rang.stop, rang.start:n) 
        if !isempty(succeed)
            newrvec = deepcopy(rvec)
            newrvec[ridx] = succeed
            combocount += countcombos(workflows, newrvec, r[end])
        end
        if !isempty(fail)
            rvec = deepcopy(rvec)
            rvec[ridx] = fail
        else
            usedefault = false # if all of range succeeded, the default path is not taken
            break # so processing complete before we reach end of the rules
        end
    end
    if usedefault
        combocount += countcombos(workflows, rvec, default)
    end
    return combocount
end


function day20()
    part = [0, 0]
    G = Dict{String, Vector{String}}()
    GT = Dict{String, Dict{String, Int}}()
    T = Dict{String, Int}()
    S = Dict{String, Int}()
    for line in filter(!isempty, strip.(readlines("day20.txt")))
        a, b = split(line, " -> ")
        if a == "broadcaster"
            T[a] = -1
        elseif a[begin] == '%'
            a = a[begin+1:end]
            T[a] = S[a] = 0
        else
            a = a[begin+1:end]
            T[a] = 1
        end
        b = split(b, ", ")
        G[a] = b
        for c in b
            get!(GT, c, Dict{String, Int}())
            GT[c][a] = 0
        end
    end
    z, tc = [0 + 0im], [0]
    src = keys(GT["rx"])
    H = Dict(j => 0 for j in first([keys(GT[i]) for i in src]))
    function pushsignal()
        tc[begin] += 1
        q = Tuple{String, Int, Union{Int, String}}[]
        push!(q, ("broadcaster", 0, -1))
        while !isempty(q)
            u, p, par = popfirst!(q)
            z[begin] += (1 - p) + p * im 
            !haskey(T, u) && continue
            if T[u] == 0
                if p == 0
                    S[u] ⊻= 1
                    append!(q, [(v, S[u], u) for v in G[u]])
                end
            elseif T[u] == 1
                GT[u][par] = p
                n = 1 - all(!iszero, values(GT[u]))
                append!(q, [(v, n, u) for v in G[u]])
                if u ∈ src
                    for(k, v) in GT[u]
                        if v != 0 && H[k] == 0
                            H[k] = tc[begin]
                        end
                    end
                end
            else
                append!(q, [(v, p, u) for v in G[u]])
            end
        end
    end
    for _ in 1:999
        pushsignal()
    end
    part[1] = real(z[begin]) * imag(z[begin])
    while !all(!iszero, values(H))
        pushsignal()
    end
    part[2] = reduce((x, y) -> (x * y) ÷ gcd(x, y), values(H))
    return part
end


function day21()
    part = [0, 0]
    grid = Char.(stack(Iterators.map(collect, eachline("day21.txt")); dims=1))
    nrows, ncols = size(grid)
    start = first(findall(==('S'), grid))
    corners = CartesianIndex.([(1, 1), (nrows, 1), (1, ncols), (nrows, ncols)])
    even_inner, even_outer, odd_inner, odd_outer = bfs21(grid, [start], start, 130)
    part[1] = even_inner

    even_full = even_inner + even_outer
    odd_full = odd_inner + odd_outer
    remove_corners = odd_outer
    add_corners = bfs21(grid, corners, start, 64)[begin]
    
    n = 202300
    firststep = n * n * even_full
    second = (n + 1) * (n + 1) * odd_full
    third = n * add_corners
    fourth = (n + 1) * remove_corners
    part[2] = firststep + second + third - fourth

    return part
end

function bfs21(grid, starts, center, limit)
    manhattan(c1, c2) = abs(c1[1] - c2[1]) + abs(c1[2] - c2[2])
    dirs = CartesianIndex.([(0, 1), (1, 0), (0, -1), (-1, 0)]) # E S W N
    nrows, ncols = size(grid)
    halfway = (nrows + ncols) ÷ 4
    mat = deepcopy(grid)
    todo = Tuple{CartesianIndex, Int}[]
    even_inner, even_outer, odd_inner, odd_outer = 0, 0, 0, 0
    for c in starts
        mat[c] = '#'
        push!(todo, (c, 0))
    end
    while !isempty(todo)
        position, cost = popfirst!(todo)
        if isodd(cost)
            if manhattan(position, center) <= halfway
                odd_inner += 1
            else
                odd_outer += 1
            end
        elseif cost < halfway
            even_inner += 1
        else
            even_outer += 1
        end
        if cost < limit
            for nxt in position .+ dirs
                if 0 < nxt[1] <= nrows && 0 < nxt[2] <= ncols && mat[nxt] != '#'
                    mat[nxt] = '#'
                    push!(todo, (nxt, cost + 1))
                end
            end
        end
    end
    return even_inner, even_outer, odd_inner, odd_outer
end


function day22()
    part = [0, 0]
    bricks = [parse.(Int, split(line, r",|~")) for line in eachline("day22.txt")]
    sort!(bricks, by = b -> b[3])
    nbricks = length(bricks)
    heights = zeros(Int, 100)
    indices = fill(typemax(Int32), 100)
    safe = trues(nbricks)
    dominator = Tuple{Int, Int}[]

    for (i, (x1, y1, z1, x2, y2, z2)) in enumerate(bricks)
        start = 10 * y1 + x1;
        stop = 10 * y2 + x2;
        step = y2 > y1 ? 10 : 1
        height = z2 - z1 + 1
        top = 0;
        previous = typemax(Int32)
        underneath = 0;
        parent = 0;
        depth = 0;

        for j in start+1:step:stop+1
            top = max(top, heights[j])
        end

        for j in start+1:step:stop+1
            if heights[j] == top
                index = indices[j]
                if index != previous
                    previous = index
                    underneath += 1
                    if underneath == 1
                        parent, depth = dominator[previous]
                    else
                        # Find common ancestor
                        a, b = parent, depth
                        x, y = dominator[previous]
                        while b > y
                            a, b = dominator[a]
                        end
                        while y > b
                            x, y = dominator[x]
                        end
                        while a != x
                            a, b = dominator[a]
                            x = dominator[x][begin]
                        end
                        parent, depth = a, b
                    end
                end
            end
            heights[j] = top + height
            indices[j] = i
        end
        if underneath == 1
            safe[previous] = false
            parent = previous
            depth = dominator[previous][begin+1] + 1
        end

        push!(dominator, (parent, depth))
    end

    part[1] = sum(safe)
    part[2] = sum(d -> d[2], dominator)

    return part
end


import LLVM.Interop.assume # little documented optimization, see code in github.com/Zentrik
import Base.:+

const CI = Tuple{Int, Int}
Base.:+(x::CI, y::CI) = (x[1] + y[1], x[2] + y[2])
const dir23 = [(-1, 0), (0, 1), (1, 0), (0, -1)]

function day23()
    part = [0, 0]
    grid = stack(Iterators.map(collect, eachline("day23.txt")), dims = 1)
    nrows, ncols = size(grid)
    start = (1, 2)
    goal = (nrows, ncols-1)
    used = falses(nrows, ncols)
    part[1] = dfs(grid, used, start, 0, goal)

    # see https://github.com/Zentrik's entry, using it for speed
    replace!(grid, '^' => '.', '>' => '.', 'v' => '.', '<' => '.')
    idx_to_idx = Dict{CI, Int}()
    adjacency_list = NTuple{4, CI}[]
    process_node!(adjacency_list, idx_to_idx, grid, start, goal, start)

    goal_node_idx = idx_to_idx[goal]
    lost_length = adjacency_list[goal_node_idx][1][2]
    goal_node_idx = adjacency_list[goal_node_idx][1][1]
    path_mask = UInt64(0)
    part[2] = lost_length + compressed_dfs(path_mask, idx_to_idx[start], 0, goal_node_idx, adjacency_list)
    
    return part
end

function dfs(grid, used, c, path_length, goal)
    checkbounds(Bool, grid, c[1], c[2]) || return 0
    ch = grid[c[1], c[2]]
    ch == '#' && return 0
    used[c[1], c[2]] && return 0
    c == goal && return path_length
    used[c[1], c[2]] = true
    if ch == '.'
        result = maximum(d -> dfs(grid, used, c + d, path_length + 1, goal), dir23)
    else
        d = ch == '^' ? dir23[1] : ch == '>' ? dir23[2] : ch == 'v' ? dir23[3] : ch == '<' ? dir23[4] : error("Bad char $ch in grid")
        result = dfs(grid, used, c + d, path_length + 1, goal)
    end
    used[c[1], c[2]] = false
    return result
end

function add_child(adjacency_list, idx_to_idx, parent_node, child_node, path_len)
    incx = (1, 0)
    for node in (parent_node, child_node)
        if !haskey(idx_to_idx, node)
            idx_to_idx[node] = length(adjacency_list) + 1
            push!(adjacency_list, Tuple(incx for _ in 1:4))
        end
    end
    idx = idx_to_idx[parent_node]
    next_free_idx = findfirst(==(incx), adjacency_list[idx])
    new_tuple = Base.setindex(adjacency_list[idx], (idx_to_idx[child_node], path_len), next_free_idx)
    adjacency_list[idx] = new_tuple
end

function process_node!(adjacency_list, idx_to_idx, grid, node, goal_node, parent_node)
    path_len = node != parent_node

    while true
        grid[node[1], node[2]] = 'X'
        path_len += 1
        if node == goal_node
            add_child(adjacency_list, idx_to_idx, parent_node, node, path_len - 1)
            add_child(adjacency_list, idx_to_idx, node, parent_node, path_len - 1)
            break
        end
        possible_paths = 0
        for d in dir23
            next_node = node + d
            checkbounds(Bool, grid, next_node[1], next_node[2]) || continue
            next_node == parent_node && continue
            possible_paths += grid[next_node[1], next_node[2]] == '.'
            if grid[next_node[1], next_node[2]] == 'B'
                add_child(adjacency_list, idx_to_idx, parent_node, next_node, path_len)
                add_child(adjacency_list, idx_to_idx, next_node, parent_node, path_len)
            end
        end

        if possible_paths == 0
            break
        elseif possible_paths == 1
            for d in dir23
                next_node = node + d
                checkbounds(Bool, grid, next_node[1], next_node[2]) || continue

                if grid[next_node[1], next_node[2]] == '.'
                    node = next_node
                    break
                end
            end
        else
            grid[node[1], node[2]] = 'B'
            add_child(adjacency_list, idx_to_idx, parent_node, node, path_len - 1)
            add_child(adjacency_list, idx_to_idx, node, parent_node, path_len - 1)
            for d in dir23
                next_node = node + d
                checkbounds(Bool, grid, next_node[1], next_node[2]) || continue
                if grid[next_node[1], next_node[2]] == '.'
                    process_node!(adjacency_list, idx_to_idx, grid, next_node, goal_node, node)
                end
            end
            break
        end
    end
end

function compressed_dfs(path_mask, node, path_length, goal_node, adjacency_list)
    node == goal_node && return path_length
    path_mask |= UInt64(1) << node
    max_len = 0
    for child in @inbounds adjacency_list[node]
        @inbounds child_node = child[1]
        assume(child_node > 0)
        assume(child_node < 64)
        (path_mask & UInt64(1) << child_node) != 0 && continue
        @inbounds max_len = max(max_len, compressed_dfs(path_mask, child_node, path_length + child[2], goal_node, adjacency_list))
    end
    return max_len
end


const T3 = Tuple{Float64, Float64, Float64}

function day24()
	part = [0, 0]

	p0, v0 = T3[], T3[]
	for line in filter(!isempty, strip.(readlines("day24.txt")))
		x, y, z, vx, vy, vz = parse.(Float64, split(line, r"[\s\@,]+"))
		push!(p0, T3((x, y, z)))
		push!(v0, T3((vx, vy, vz)))
	end
	boun = (200000000000000, 400000000000000)
	for i in firstindex(p0):lastindex(p0)-1, j in i+1:lastindex(p0)
		x, y = rays_intersection(p0[i], p0[j], v0[i], v0[j])
		x isa Nothing && continue
		if boun[1] <= x <= boun[2] && boun[1] <= y <= boun[2]
			part[1] += 1
		end
	end

    model = Model(Ipopt.Optimizer)
    set_silent(model)
	@variables(model, begin x; y; z; vx; vy; vz end)

	# Solvable with just 3 points for constraints (same line / plane  for all points)
	t_1 = @variable(model)
	@constraint(model, p0[1][1] + v0[1][1] * t_1 == x + vx * t_1)
	@constraint(model, p0[1][2] + v0[1][2] * t_1 == y + vy * t_1)
	@constraint(model, p0[1][3] + v0[1][3] * t_1 == z + vz * t_1)
	t_2 = @variable(model)
	@constraint(model, p0[2][1] + v0[2][1] * t_2 == x + vx * t_2)
	@constraint(model, p0[2][2] + v0[2][2] * t_2 == y + vy * t_2)
	@constraint(model, p0[2][3] + v0[2][3] * t_2 == z + vz * t_2)
	t_3 = @variable(model)
	@constraint(model, p0[3][1] + v0[3][1] * t_3 == x + vx * t_3)
	@constraint(model, p0[3][2] + v0[3][2] * t_3 == y + vy * t_3)
	@constraint(model, p0[3][3] + v0[3][3] * t_3 == z + vz * t_3)

	@objective(model, Min, 1.0)
	JuMP.optimize!(model)
	#solution_summary(model)
	part[2] = Int.(round(value(x) + value(y) + value(z)))

	return part
end

""" Intersection of rays from p0, p1 with velocities v0, v1 """
function rays_intersection(p0, p1, v0, v1)
	dx = p1[1] - p0[1]
	dy = p1[2] - p0[2]
	det = v1[1] * v0[2] - v1[2] * v0[1]
	u = (dy * v1[1] - dx * v1[2]) / det
	v = (dy * v0[1] - dx * v0[2]) / det
	(u < 0 || v < 0) && return nothing, nothing

	m0 = v0[2] / v0[1]
	m1 = v1[2] / v1[1]
	b0 = p0[2] - m0 * p0[1]
	b1 = p1[2] - m1 * p1[1]
	x = (b1 - b0) / (m0 - m1)
	y = m0 * x + b0
	return isfinite(x) ? (x, y) : (nothing, nothing)
end


function day25()
    part = 0
    g = MetaGraph(Graph(); label_type=String)
    for line in readlines("day25.txt")
        vtx, neighbors = split(line, ':')
        vtx ∉ labels(g) && add_vertex!(g, vtx)
        for n in strip.(split(neighbors))
            n ∉ labels(g) && add_vertex!(g, n)
            add_edge!(g, vtx, n)
        end
    end
    while true
        cut = karger_min_cut(g)
        edges = karger_cut_edges(g, cut)
        if length(edges) == 3
            singles = count(isone, cut)
            part = (length(vertices(g)) - singles) * singles
            break
        end
    end
    return part
end

let tsum = 0.0
    println(" Day     Seconds\n=================")
    for f in [day01, day02, day03, day04, day05, day06, day07, day08, day09, day10, day12, day13,
       day14, day15, day16, day17, day18, day19, day20, day21, day22, day23, day24, day25]
        t = @belapsed $f()
        println(f, "   ", t)
        tsum += t
    end
    println("=================\nTotal   ", tsum)
end
