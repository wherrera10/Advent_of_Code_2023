function day11()
    part = [0, 0]
    mat = reshape(filter(!=(Int32('\n')), read("day11.txt")), 140, 140)'
    nr, nc = Int[], Int[]
    for (i, r) in enumerate(eachrow(mat))
        all(==(Int32('.')), r) && push!(nr, i)
    end
    for (i, c) in enumerate(eachcol(mat))
        all(==(Int32('.')), c) && push!(nc, i)
    end

    xp = [2, 1_000_000]
    gal = Tuple.(findall(==(UInt8('#')), mat))
    for k in eachindex(xp), i in 1:lastindex(gal)-1, j in i+1:lastindex(gal)
        x1, y1 = gal[i]
        x2, y2 = gal[j]
        part[k] += dist(x1, y1, x2, y2) + xpan(x1, x2, nr, xp[k]) + xpan(y1, y2, nc, xp[k])
    end

    return part
end

dist(x1, y1, x2, y2) = abs(x1 - x2) + abs(y1 - y2)
xpan(a, b, empties, xpan) = count(i -> i ∈ empties, a < b ? (a:b-1) : (b:a-1)) * (xpan - 1)

@show day11()

