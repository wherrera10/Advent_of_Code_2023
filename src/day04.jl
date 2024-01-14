using Memoize

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

@time day04()
