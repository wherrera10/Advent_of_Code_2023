function day23()
    part = [0, 0]

    grid = stack(Iterators.map(collect, eachline("day23.txt")), dims=1)
    nrows, ncols = size(grid)
    @show nrows, ncols

    start = CartesianIndex(1, 2)
    goal = CartesianIndex(nrows, ncols-1)
    prior = Set{CartesianIndex}([start])
    part[1] = dfs_max(neighbors, start, goal, grid, nrows, ncols, CartesianIndex[], prior, 0)

    peaks = Set{CartesianIndex{2}}([start, goal])
    distances = Dict{CartesianIndex, Vector{Tuple{Int, CartesianIndex}}}()
    for c in CartesianIndices(grid) # Find the points where the > v are in part 1
        grid[c] != '#' && length(neighbors2(c, grid, nrows, ncols)) > 2 && push!(peaks, c)
    end
    for c in peaks
        path = [c]
        newpath = empty(path)
        beenthere = Set{CartesianIndex}([c])
        steps = 0
        while !isempty(path)
            newpath = empty(path)
            steps += 1
            for p in path, neigh in neighbors2(p, grid, nrows, ncols)      
                if neigh ∉ beenthere
                    if neigh in peaks
                        tvec = get!(distances, c, Tuple{Int, CartesianIndex}[])
                        push!(tvec, (steps, neigh))
                        push!(beenthere, neigh)
                    else
                        push!(newpath, neigh)
                        push!(beenthere, neigh)
                    end
                end
            end
            path, newpath = newpath, path
        end
    end

    part[2] = dfs_max2(start, goal, grid, nrows, ncols, distances, Set{CartesianIndex}(), 0, 0)
   
    return part
end

const dirs = CartesianIndex.([(0, 1), (1, 0), (0, -1), (-1, 0)]) # E S W N

function neighbors(c, grid, nrows, ncols)
    neigh, ch = CartesianIndex[], grid[c]
    slopes = Dict('>' => 1, 'v' => 2, '<' => 3, '^' => 4)
    if ch ∈ ['>', 'v', '<', '^']
        c2 = c + dirs[slopes[ch]]
        grid[c2] != '#' && push!(neigh, c2)
    else
        for d in dirs
            c2 = c + d
            if 1 <= c2[1] <= nrows && 1 <= c2[2] <= ncols && grid[c2] != '#'
                push!(neigh, c2)
            end
        end
    end
    return neigh
end

function dfs_max(neighbors, pos, goal, grid, nrows, ncols, path, beenthere, longest)
    if pos == goal
        longest = max(longest, length(path))
    end
    for neigh in neighbors(pos, grid, nrows, ncols)
        if neigh ∉ beenthere
            push!(path, neigh)
            push!(beenthere, neigh)
            longest = dfs_max(neighbors, neigh, goal, grid, nrows, ncols, path, beenthere, longest)
            delete!(beenthere, neigh)
            pop!(path)
        end
    end
    return longest
end

function neighbors2(c, grid, nrows, ncols)
    neigh = CartesianIndex[]
    for d in dirs
        c2 = c + d
        if 1 <= c2[1] <= nrows && 1 <= c2[2] <= ncols && grid[c2] != '#'
            push!(neigh, c2)
        end
    end
    return neigh
end

function dfs_max2(pos, goal, grid, nrows, ncols, distances, beenthere, distance, longest)
    if pos == goal && distance > longest
        longest = distance
    end    
    for (d, c) in distances[pos]
        if c ∉ beenthere
            push!(beenthere, c)
            longest = dfs_max2(c, goal, grid, nrows, ncols, distances, beenthere, distance + d, longest)
            delete!(beenthere, c)
        end
    end
    return longest
end

@show day23()
