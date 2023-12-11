function day11()
    part = [0, 0]
    txt = filter(!=(Int32('\n')), read("day11.txt"))
    mat = reshape(txt, 140, 140)'
    needrow, needcol = Int[], Int[]
    for (i, r) in enumerate(eachrow(mat))
        all(==(Int32('.')), r) && push!(needrow, i)
    end
    for (i, c) in enumerate(eachcol(mat))
        all(==(Int32('.')), c) && push!(needcol, i)
    end

    xp = [2, 1_000_000]
    gal = findall(==(UInt8('#')), mat)
    for k in eachindex(xp), i in 1:lastindex(gal)-1, j in i+1:lastindex(gal)
        x1, y1 = Tuple(gal[i])
        x2, y2 = Tuple(gal[j])
        if x1 > x2
            x1, x2 = x2, x1
        end
        if y1 > y2
            y1, y2 = y2, y1
        end
        part[k] += dist(x1, y1, x2, y2) + xxp(x1, x2, needrow, xp[k]) + yxp(y1, y2, needcol, xp[k])
    end

    return part
end

dist(x1, y1, x2, y2) = abs(x1 - x2) + abs(y1 - y2)
xxp(x1, x2, nr, mult) = count(i -> i ∈ nr, x1:x2-1) * (mult - 1)
yxp(y1, y2, nc, mult) = count(i -> i ∈ nc, y1:y2-1) * (mult - 1)

day11()

