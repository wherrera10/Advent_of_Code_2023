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
