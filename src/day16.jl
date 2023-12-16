function day16()
    part = [0, 0]

    grid = [collect(strip(row)) for row in readlines("day16.txt")]
    nrows, ncols = length(grid), length(grid[1])

    part[1] = countgrid(grid, nrows, ncols, 1, 1, 2)

    part2starts = Vector{Int}[]
    for row in [1, nrows], col in 1:ncols
        push!(part2starts, [row, col, row == 1 ? 2 : 4])
    end
    for row in 1:nrows, col in [1, ncols]
        push!(part2starts, [row, col, col == 1 ? 1 : 3])
    end
    part[2] = maximum(countgrid(grid, nrows, ncols, r...) for r in part2starts)

    return part
end

function countgrid(grid, nrows, ncols, startx, starty, dir)
    directions = [(0, 1), (1, 0), (0, -1), (-1, 0)] # E S W N
    energized = falses(nrows, ncols)
    energized[startx, starty] = true
    rays = [[startx, starty, dir]]
    splitrays = Set{Vector{Int}}()
        for idx in 1:1200
        idx % 100 == 0 && print(idx, "\b\b\b\b\b\b\b\b\b\b")
        nrays = length(rays)
        for i in 1:nrays
            rays[i][1] ==  0 && continue
            ray = rays[i]
            d = ray[3]
            x, y = ray[1] + directions[d][1], ray[2] + directions[d][2]
            if x < 1 || y < 1 || x > nrows || y > ncols
                rays[i] = [0, 0, 0]
                continue
            else
                ray[1], ray[2] = x, y
                energized[x, y] = true
            end
            if grid[x][y] == '.'
                continue
            elseif grid[x][y] == '/'
                ray[3] = 5 - d
            elseif grid[x][y] == '\\'
                ray[3] = d == 1 ? 2 : d == 2 ? 1 : d == 3 ? 4 : 3
            elseif grid[x][y] == '-'
                if d == 2 || d == 4
                    ray[3] = 1
                    newray = [ray[1], ray[2], 3]
                    if newray ∉ splitrays
                        push!(rays, newray)
                        push!(splitrays, newray)
                    end
                end
            elseif grid[x][y] == '|'
                if d == 1 || d == 3
                    ray[3] = 2
                    newray = [ray[1], ray[2], 4]
                    if newray ∉ splitrays
                        push!(rays, newray)
                        push!(splitrays, newray)
                    end
                end
            end
        end
        filter!(r -> !iszero(r), rays)
    end
    return sum(energized)
end

@show day16()
