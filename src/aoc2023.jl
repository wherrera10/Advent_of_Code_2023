function day01()
    lines = filter(!isempty, strip.(readlines("day01.txt")))
    part1 = sum(parse(Int, s[findfirst(isdigit, s)] * s[findlast(isdigit, s)]) for s in lines)
    part2 = sum(fnum(str) * 10 + lnum(str) for str in lines)
    return part1, part2 # (54940, 54208)
end

const snums = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

function fnum(str)
    for i in eachindex(str)
        if isdigit(str[i])
            return parse(Int, str[i])
        end
        for j in eachindex(snums)
            if startswith(str[i:end], snums[j])
                return j
            end
        end
    end
end

function lnum(str)
    for i in length(str):-1:1
        if isdigit(str[i])
            return parse(Int, str[i])
        end
        for j in eachindex(snums)
            if startswith(str[i:end], snums[j])
                return j
            end
        end
    end
end

@time day01()

function day02()
    lines = filter(!isempty, strip.(readlines("day02.txt")))
    part1given = Dict("red" => 12, "green" => 13, "blue" => 14)
    part1possibles = Int[]
    powers = Int[]
    part = [0, 0]

    for (gamenum, line) in enumerate(lines)
        gameshowings = split(line, r":|;")[2:end]
        pairvec = Pair{String, Int}[]
        for showing in gameshowings
            pairs = strip.(split(showing, ","))
            d = Dict{String, Int}()
            for pair in pairs
                num, colr = strip.(split(pair, r"\s+"))
                push!(pairvec, colr => parse(Int, num))
            end
        end
        maxshow = Dict{String, Int}()
        for (clr, cnt) in pairvec
            maxshow[clr] = max(get!(maxshow, clr, 0), cnt)
        end
        push!(powers, prod(values(maxshow)))
        ispossible = true
        for (colr, cnt) in maxshow
            if cnt > part1given[colr]
                ispossible = false
            end
        end
        ispossible && push!(part1possibles, gamenum)
    end

    part .= sum(part1possibles), sum(powers)
    @show(part)
end

@time day02()

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
    @show part
end

@time day03()

function day04()
    lines = strip.(filter(!isempty, readlines("day04.txt")))
    wins = Vector{Int}[]
    allcards = collect(1:length(lines))
    part = [0, 0]

    for (cardnum, line) in enumerate(lines)
        wintxt, gottxt = strip.(split(line, r"\:|\|"))[2:3]
        matches = [parse(Int, s) for s in split(wintxt, r"\s+") ] ∩ [parse(Int, s) for s in split(gottxt, r"\s+")]
        if isempty(matches)
            push!(wins, Int[])
        else
            push!(wins, filter(<=(length(lines)), cardnum+1:cardnum+length(matches)))
            part[1] += 2^(length(matches)-1)
        end
    end

    i = 0
    while i < length(allcards)
        i += 1
        append!(allcards, wins[allcards[i]])
    end
    part[2] = length(allcards)

    @show part[1], part[2]
end

@time day04()

function day05()
    groups = strip.(filter(!isempty, split(read("day05.txt", String), "\n\n")))
    part1seeds = [parse(Int, s) for s in split(groups[1], r"\s+")[2:end]]
    dicts = Dict{Vector{Int}, Vector{Int}}[]
    part = [0, 0]

    for grp in groups[2:end]
        d = Dict{Vector{Int}, Vector{Int}}()
        lines = split(grp, "\n")[2:end]
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

    getinterval(sta, sto) = (sto-sta) ÷ 1000

    ranges = [part1seeds[i]:getinterval(part1seeds[i], part1seeds[i]+part1seeds[i+1]-1
       ):part1seeds[i]+part1seeds[i+1]-1 for i in 1:2:length(part1seeds)-1]

    bestrange = findmin([minimum(location, r) for r in ranges])[2]

    r = ranges[bestrange].start:ranges[bestrange].stop
    while length(r) > 100_000
        qdelt = (r.stop - r.start) ÷ 4
        r = findmin(location(x) for x in r.start:getinterval(r.start, r.stop):r.stop)[2] < 500 ?
           (r.start:r.stop-qdelt) : (r.start+qdelt:r.stop)
    end
    part[2] = minimum(location, r)

    @show part[1], part[2] # (part[1], part[2]) = (51580674, 99751240)
end

@time day05()

function day06()
    part = [0, 0]

    lines = split(read("day06.txt", String), "\n")
    times, distances = [[parse(Int, x) for x in split(lines[i])[2:end]] for i in 1:2]

    part1bests(t, d) = count((t - wait) * wait > d for wait in 1:t)

    part[1] = prod([part1bests(times[r], distances[r]) for r in eachindex(times)])

    bigtime, bigdist = [parse(Int, prod(split(lines[i])[2:end])) for i in 1:2]
    begintime = findfirst(w -> (bigtime - w) * w > bigdist, 1:bigtime)

    part[2] = bigtime - begintime - begintime + 1

    @show part[1], part[2] # (440000, 26187338)
end

@time day06()

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
    @show part[1], part[2] # (part[1], part[2]) = (248113761, 246285222)
end

@time day07()

function day08()
    part = [0, 0]
    LRtxt, equations = split(read("day08.txt", String), "\n\n")
    LR = collect(strip(LRtxt))
    nodes = Dict{String, Pair{String}}()
    for eq in filter(!isempty, strip.(split(equations, "\n")))
        n, l, r = string.(split(eq, r"[\s\=,\(\)]+"))
        nodes[n] = Pair(l, r)
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

    @show part[1]

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

    @show part[2] # part[1] = 18673    part[2] = 17972669116327
end

@time day08()

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
    @show part[1], part[2]  # (2008960228, 1097)
end

@time day09()


uconst moves = [[0, 1], [1, 0], [0, -1], [-1, 0]]
const charmove = Dict{Char, Vector{Int}}('L' => [1, 4], '|' => [2, 4], '-' => [1, 3], '7' => [2, 3],
                                         'F' => [1, 2], 'J' => [3, 4], '.' => Int[])
used(frompos) = [3, 4, 1, 2][frompos]

function day10()
    part = [0, 0]
    mat = Char.(reshape(collect(read("day10.txt")), (141, 140))')
    x, y, move = 43, 26, 1
    visited = Dict{Vector{Int}, Int}([x, y] => 0)
    nvisited = 0
    mat[x, y] = '7'
    while true
        move = first(setdiff(charmove[mat[x, y]], used(move)))
        x, y = [x, y] .+ moves[move]
        nvisited += 1
        if haskey(visited, [x, y])
            break
        else
            visited[[x, y]] = nvisited
        end
    end
    part[1] = nvisited ÷ 2

    graph = fill('.', 280, 282)
    for (x, y) in keys(visited)
        c = mat[x, y]
        graph[2x-1, 2y-1] = c
        if c == '-'
            graph[2x-1, 2y] = '-'
        elseif c == '|'
            graph[2x, 2y-1] = '-'
        elseif c == 'F'
            graph[2x-1, 2y] = '-'
            graph[2x, 2y-1] = '|'
        elseif c == 'L'
            graph[2x-1, 2y] = '-'
        elseif c == '7'
            graph[2x, 2y-1] = '|'
        end
    end

    locations = Vector{Int}[]
    for x in 1:280, y in [1, 282]
        graph[x, y] == '.' && push!(locations, [x, y])
    end
    while !isempty(locations)
        newlocations = empty(locations)
        for (x, y) in locations
            for i in max(1, x-1):min(x+1, 280), j in max(1, y-1):min(y+1, 282)
                if graph[i, j] == '.'
                    graph[i,j] = ' '
                    push!(newlocations, [i, j])
                end
            end
        end
        locations = newlocations
    end
    part[2] = count(==('.'), graph[1:2:280, 1:2:281])
    return part
end

@show day10() # (7173, 291),


