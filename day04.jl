const lines = strip.(filter(!isempty, readlines("day04.txt")))
const wins = Vector{Int}[]
const part1scores = Int[]
const allcards = Int[]
const part = [0, 0]

for (cardnum, line) in enumerate(lines)
    wintxt, gottxt = strip.(split(line, r"\:|\|"))[2:3]
    winners = [parse(Int, s) for s in split(wintxt, r"\s+")]
    haves = [parse(Int, s) for s in split(gottxt, r"\s+")]
    matches = intersect(winners, haves)
    if isempty(matches)
        push!(wins, Int[])
        push!(part1scores, 0)
    else
        push!(wins, filter(<=(length(lines)), cardnum+1:cardnum+length(matches)))
        push!(part1scores, 2^(length(matches)-1))
    end
end

part[1] = sum(part1scores)

append!(allcards, collect(1:length(lines)))

let
    i = 1
    while true
        append!(allcards, wins[allcards[i]])
        i += 1
        i > length(allcards) && break
    end
    part[2] = length(allcards)
end

@show part

