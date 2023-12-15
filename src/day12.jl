using Memoize

struct Defects
    pat::Vector{UInt8}
    grp::Vector{Int}
end

function day12()
    part = [0, 0]
    defectlist = Defects[]
    for s in filter(!isempty, readlines("day12.txt"))
        p, x = split(s)
        pat = [c == '.' ? 0x0 : c == '#' ? 0x1 : 0x2 for c in p]
        grp = [parse(Int, string(s)) for s in split(x, ",")]
        push!(defectlist, Defects(pat, grp))
    end

    worklist = deepcopy(defectlist)

    for d in worklist
        n = processdefects(d)
        part[1] += n
    end
    @show part[1]

    part2start = time()
    worklist2 = [Defects(repeat(vcat(d.pat, [0x2]), 5)[begin:end-1], repeat(d.grp, 5)) for d in worklist]
    println("Part 2 worklist has $(length(worklist2)) items.")
    slock = ReentrantLock()
    @Threads.threads for d in worklist2
        n = processdefects(d)
        elap = time() - part2start
        println("results $n elapsed $(Int(round(elap))) seconds.")
        lock(slock)
        part[2] += n
        unlock(slock)
    end

    return part
end


""" 0x0 is .  0x1 is #  0x2 is ? """
@memoize function processdefects(d::Defects)
    pat, grp, nfound = d.pat, d.grp, 0
    #isempty(pat) && return isempty(grp) ? 1 : 0
    isempty(grp) && return (0x1 in pat) ? 0 : 1
    plen, glen = length(pat), length(grp)
    plen < sum(grp) + glen - 1 && return 0
    p, g = first(pat), first(grp)
    if 0x0 ∉ pat[begin:g] # . found in part of what we want to be run of # or ?
        if plen == g || pat[g+1] != 0x1
            nfound += processdefects(Defects(pat[g+2:end], grp[begin+1:end]))
        end
    end
    if p != 0x1 # not a #
        nfound += processdefects(Defects(pat[begin+1:end], grp))
    end
    return nfound
end


day12() # 7361,
