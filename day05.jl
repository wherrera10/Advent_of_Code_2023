const groups = strip.(filter(!isempty, split(read("day05.txt", String), "\n\n")))
const part1seeds = [parse(Int, s) for s in split(groups[1], r"\s+")[2:end]]
const dicts = Dict{Vector{Int}, Vector{Int}}[]
const part = [0, 0]

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

part[1] = minimum([location(i) for i in part1seeds])

let  # plugged in various seed values to hand minimize
    part2seeds = [part1seeds[i]:part1seeds[i]+part1seeds[i+1]-1 for i in 1:2:length(part1seeds)-1]
    r = part2seeds[5]
    v = r.start+36530000:1:r.stop-374100000
    part[2] = findmin(location, v)[1]
end

@show part[1], part[2] # (part[1], part[2]) = (51580674, 99751240)
