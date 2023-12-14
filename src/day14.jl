function day14()
    part = [0, 0]
    rows = [[c == '.' ? 0x0 : c == 'O' ? 0x1 : 0x2 for c in string(a)] for a in readlines("day14.txt")]
    m = reduce(vcat, map(a -> a', rows))
    mr = rollnorth!(m)
    nrows, ncols = size(mr)
    part[1] = sum((nrows - i + 1) * (mr[i, j] == 0x1) for i in 1:nrows, j in 1:ncols)
    mcfirst = cycleroll!(m)
    mc = deepcopy(mcfirst)
    results = Set([m, mcfirst])
    cycles = 0
    for i in 1:typemax(Int32)
        mc = cycleroll!(mc)
        if mc in results
            cycles = i
            break
        end
        push!(results, mc)
    end
    target, indices = mc, Int[]
    for i in 1:typemax(Int32)
        mcfirst = cycleroll!(mcfirst)
        if mcfirst == target
            push!(indices, i)
            length(indices) > 3 && break
        end
    end
    idx = (1000000000 - indices[begin]) % diff(indices)[begin]
    m2 = deepcopy(m)
    foreach(_ -> begin m2 = cycleroll!(m2) end, 1:121+idx)
    part[2] = sum((nrows - i + 1) * (m2[i, j] == 0x1) for i in 1:nrows, j in 1:ncols)
    return part
end

function rollonce!(m)
    nrows, ncols = size(m)
    for i in 2:nrows
        for j in 1:ncols
            if m[i, j] == 0x1 && m[i - 1, j] == 0x0
                m[i, j], m[i - 1, j] = m[i - 1, j], m[i, j]
            end
        end
    end
    return m
end

function rollnorth!(mat)
    m = deepcopy(mat)
    for _ in 1:size(m, 1)
        rollonce!(m)
    end
    return m
end

function cycleroll!(mat)
    m = deepcopy(mat)
    for _ in 1:size(m, 1)
        rollonce!(m)
    end
    m = rotr90(m)
    for _ in 1:size(m, 1)
        rollonce!(m)
    end
    m = rotl90(m)
    m = rot180(m)
    for _ in 1:size(m, 1)
        rollonce!(m)
    end
    m = rot180(m)
    m = rotl90(m)
    for _ in 1:size(m, 1)
        rollonce!(m)
    end
    m = rotr90(m)
    return m
end


day14()

