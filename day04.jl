const lines = strip.(filter(!isempty, readlines("day04.txt")))
const wins = Vector{Int}[]
const allcards = collect(1:length(lines))
const part = [0, 0]

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

let
    i = 0
    while i < length(allcards)
        i += 1
        append!(allcards, wins[allcards[i]])
    end
    part[2] = length(allcards)
end

@show part
