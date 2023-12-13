function day13()
    part = [0, 0]

    patterns = split(read("day13.txt", String), "\n\n")
    mats = Matrix{Bool}[]
    for p in patterns
        rows = [[i =='#' for i in a] for a in split(p)]
        m = reduce(vcat, map(a -> a', rows))
        push!(mats, m)
        rdelta, cdelta = findmirror(m)
        part[1] += cdelta + 100 * rdelta
    end

    for m in mats
        oldr, oldc = findmirror(m)
        for i in eachindex(m)
            m[i] = !m[i]
            rdelta, cdelta = findmirror(m, oldr, oldc)
            m[i] = !m[i]
            if rdelta > 0 || cdelta > 0
                part[2] += cdelta + 100 * rdelta
                break
            end
        end
    end
    return part
end

function findmirror(m, forbidrow = 0, forbidcol = 0)
    nrows, ncols = size(m)
    rdelta, cdelta = 0, 0
    for i in 1:nrows-1
        i == forbidrow && continue
        d = min(i, nrows - i)
        if m[i-d+1:i, :] == reverse(m[i+1:i+d, :], dims=1)
            rdelta = i
            break
        end
    end
    for i in 1:ncols-1
        i == forbidcol && continue
        d = min(i, ncols - i)
        if m[:, i-d+1:i] == reverse(m[:, i+1:i+d], dims=2)
            cdelta = i
            break
        end
    end
    return rdelta, cdelta
end

day13()

