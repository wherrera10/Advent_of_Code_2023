function day12()
    part = [0, 0]
    for line in readlines("day12.txt")
        empty!(defectcache)
        pattern, grouptxt = split(line)
        groups = [parse(Int, x) for x in split(grouptxt, ",")]
        part[1] += countdefects(pattern, 1, groups, 1)

        empty!(defectcache)
        pattern2 = join([pattern for _ in 1:5], "?")
        groups2 = repeat(groups, 5)
        part[2] += countdefects(pattern2, 1, groups2, 1)
    end

    return part
end

const defectcache = Dict{Pair{Int, Int}, Int}()

function countdefects(pat, pidx, grp, gidx)
    plen, glen = length(pat), length(grp)
    while pidx <= plen && pat[pidx] == '.' # skip past '.'
        pidx += 1
    end
    haskey(defectcache, pidx => gidx) && return defectcache[pidx => gidx]
    if gidx == glen + 1 # done with groups
        n = all(c -> c ∈ ['.', '?'], pat[pidx:end]) # no more defects needed
        defectcache[pidx => gidx] = Int(n)
        return Int(n)
    end
    pidx > plen && return 0 # done with pattern, but still have group to fulfill
    g, i = grp[gidx], pidx
    lastwashash = false
    while g > 0 && i <= length(pat) && pat[i] ∈ ['?', '#']
        lastwashash |= pat[i] == '#'
        i += 1
        g -= 1
    end
    g > 0 && (lastwashash || i > length(pat)) && return 0 # group donne and no spacer yet
    g > 0 && i <= length(pat) && return countdefects(pat, i + 1, grp, gidx)
    matchcount = 0
    if i > length(pat) || pat[i] != '#' # spacer found, do next group
        matchcount += countdefects(pat, i + 1, grp, gidx + 1)
    end
    j = pidx
    while i <= length(pat) && pat[j] == '?' && pat[i] ∈ ['#', '?']
        lastwashash |= pat[i] == '#'
        j += 1
        i += 1
        if i > length(pat) || pat[i] != '#'
            matchcount += countdefects(pat, i + 1, grp, gidx + 1) # . or ? so do next group
        end
    end
    if !lastwashash && i <= length(pat) # can also count matches from one further along pat
        matchcount += countdefects(pat, i + 1, grp, gidx)
    end
    defectcache[pidx => gidx] = matchcount
    return matchcount
end

@show day12()
