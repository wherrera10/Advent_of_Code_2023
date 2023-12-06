let

    part = [0, 0]

    lines = split(read("day06.txt", String), "\n")

    times, distances = [[parse(Int, x) for x in split(lines[i])[2:end]] for i in 1:2]

    part1bests(t, d) = count((t - wait) * wait > d for wait in 1:t)

    part[1] = prod([part1bests(times[r], distances[r]) for r in eachindex(times)])


    bigtime, bigdist = [parse(Int, prod(split(lines[i])[2:end])) for i in 1:2]

    begintime = findfirst(w -> (bigtime - w) * w > bigdist, 1:bigtime)
    endtime = findlast(w -> (bigtime - w) * w > bigdist, 1:bigtime)

    part[2] = endtime - begintime + 1

    @show part[1], part[2]

end