function day17()
    part = [0, 0]

    grid = reduce(hcat, (parse.(Int, s) for s in collect.(readlines("day17.txt"))))
    nrows, ncols = size(grid)
    for (i, runrange) in [[1, 2:4], [2, 5:11]]
        rh = fill(typemax(Int32), nrows, ncols)
        ch = fill(typemax(Int32), nrows, ncols)
        heatloss, newheatloss, rh[begin], ch[begin] = 1, 0, 0, 0
        while newheatloss != heatloss
            heatloss = sum(rh) + sum(ch)
            for s in runrange # s is the allowed straight path including origin point
                ch[s:nrows, :] = min.(ch[s:nrows, :], rh[1:nrows-s+1, :] +
                   sum([grid[i:nrows-s+i, :] for i in 2:s]))
                ch[1:nrows-s+1, :] = min.(ch[1:nrows-s+1, :], rh[s:nrows, :] +
                   sum([grid[i:nrows-s+i, :] for i in 1:s-1]))
                rh[:, s:ncols] = min.(rh[:, s:ncols], ch[:, 1:ncols-s+1] +
                   sum([grid[:, i:ncols-s+i] for i in 2:s]))
                rh[:, 1:ncols-s+1] = min.(rh[:, 1:ncols-s+1], ch[:, s:ncols] +
                   sum([grid[:, i:ncols-s+i] for i in 1:s-1]))
            end
            newheatloss = sum(rh) + sum(ch)
        end
        part[i] = min(last(rh), last(ch))
    end
    return part
end

@show day17()
