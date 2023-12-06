@time let

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

