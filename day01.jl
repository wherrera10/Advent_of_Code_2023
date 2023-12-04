
const lines = filter(!isempty, strip.(readlines("day01.txt")))
part1() = sum(parse(Int, s[findfirst(isdigit, s)] * s[findlast(isdigit, s)]) for s in lines)

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

part2() = sum(fnum(str) * 10 + lnum(str) for str in lines)

part1(), part2() # (54940, 54208)

