function day21()
    part = [0, 0]
    grid = Char.(stack(Iterators.map(collect, eachline("day21.txt")); dims=1))
    nrows, ncols = size(grid)
    start = first(findall(==('S'), grid))
    corners = CartesianIndex.([(1, 1), (nrows, 1), (1, ncols), (nrows, ncols)])
    even_inner, even_outer, odd_inner, odd_outer = bfs21(grid, [start], start, 130)
    part[1] = even_inner

    even_full = even_inner + even_outer
    odd_full = odd_inner + odd_outer
    remove_corners = odd_outer
    add_corners = bfs21(grid, corners, start, 64)[begin]
    
    n = 202300
    firststep = n * n * even_full
    second = (n + 1) * (n + 1) * odd_full
    third = n * add_corners
    fourth = (n + 1) * remove_corners
    part[2] = firststep + second + third - fourth

    return part
end

function bfs21(grid, starts, center, limit)
    manhattan(c1, c2) = abs(c1[1] - c2[1]) + abs(c1[2] - c2[2])
    dirs = CartesianIndex.([(0, 1), (1, 0), (0, -1), (-1, 0)]) # E S W N
    nrows, ncols = size(grid)
    halfway = (nrows + ncols) ÷ 4
    mat = deepcopy(grid)
    todo = Tuple{CartesianIndex, Int}[]
    even_inner, even_outer, odd_inner, odd_outer = 0, 0, 0, 0
    for c in starts
        mat[c] = '#'
        push!(todo, (c, 0))
    end
    while !isempty(todo)
        position, cost = popfirst!(todo)
        if isodd(cost)
            if manhattan(position, center) <= halfway
                odd_inner += 1
            else
                odd_outer += 1
            end
        elseif cost < halfway
            even_inner += 1
        else
            even_outer += 1
        end
        if cost < limit
            for nxt in position .+ dirs
                if 0 < nxt[1] <= nrows && 0 < nxt[2] <= ncols && mat[nxt] != '#'
                    mat[nxt] = '#'
                    push!(todo, (nxt, cost + 1))
                end
            end
        end
    end
    return even_inner, even_outer, odd_inner, odd_outer
end

@show day21()
