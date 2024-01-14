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

@time day08()
