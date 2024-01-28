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

""" method as in https://github.com/maneatingape/advent-of-code-rust/blob/main/src/year2023/day12.rs """
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
    for (row, g) in enumerate(@view groups[2:end])
        previous = (row - 1) * length(pattern)
        current = row * length(pattern)
        springsum = 0
        for i in start:start+wiggle
            if pattern[i + g] == '#'
                springsum = 0
            elseif table[previous + i - 1] > 0 &&
               pattern[i - 1] != '#' && broken[i + g] - broken[i] == g
                springsum += table[previous + i - 1]
            end
            table[current + i + g] = springsum
        end
        start += g + 1
    end
    return springsum
end

@show day12()
