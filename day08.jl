let
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
    command() = begin cindex = cindex < maxindex ? cindex + 1 : 1; LR[cindex] end
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

    @show part[2]
end
