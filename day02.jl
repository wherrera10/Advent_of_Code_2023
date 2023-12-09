function day02()
    lines = filter(!isempty, strip.(readlines("day02.txt")))
    part1given = Dict("red" => 12, "green" => 13, "blue" => 14)
    part1possibles = Int[]
    powers = Int[]
    part = [0, 0]

    for (gamenum, line) in enumerate(lines)
        gameshowings = split(line, r":|;")[2:end]
        pairvec = Pair{String, Int}[]
        for showing in gameshowings
            pairs = strip.(split(showing, ","))
            d = Dict{String, Int}()
            for pair in pairs
                num, colr = strip.(split(pair, r"\s+"))
                push!(pairvec, colr => parse(Int, num))
            end
        end
        maxshow = Dict{String, Int}()
        for (clr, cnt) in pairvec
            maxshow[clr] = max(get!(maxshow, clr, 0), cnt)
        end
        push!(powers, prod(values(maxshow)))
        ispossible = true
        for (colr, cnt) in maxshow
            if cnt > part1given[colr]
                ispossible = false
            end
        end
        ispossible && push!(part1possibles, gamenum)
    end

    part .= sum(part1possibles), sum(powers)
    @show(part)
end

@time day02()
