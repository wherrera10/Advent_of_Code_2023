using DataStructures

function day17()
    part = [0, 0]

    function solve(grid, nrows, ncols, smin, smax)
        q = PriorityQueue{Tuple{Int,Int,Int},Int}()
        cost = fill(typemax(Int32), nrows, ncols, 2)
        cost[begin, begin, :] .= 0
        enqueue!(q, (1, 1, 1), 0)
        enqueue!(q, (1, 1, 2), 0)
        while !isempty(q)
            x, y, direction = dequeue!(q)
            x == nrows && y == ncols && return min(cost[nrows, ncols, 1], cost[nrows, ncols, 2])
            if direction == 1  # we moved horizontal, so now we need to move vertical
                steps = 0
                for i in 1:smax
                    x - i < 1 && break
                    steps += Int(grid[x - i, y])
                    if i >= smin && cost[x-i,y,2] > steps + cost[x,y,1]
                        cost[x-i,y,2] = steps + cost[x,y,1]
                        q[(x - i, y, 2)] = cost[x - i, y, 2]
                    end
                end
                steps = 0
                for i in 1:smax
                    x + i > nrows && break
                    steps += Int(grid[x + i, y])
                    if i >= smin && cost[x+i,y,2] > steps + cost[x,y,1]
                        cost[x+i,y,2] = steps + cost[x,y,1]
                        q[(x + i, y, 2)] = cost[x + i, y, 2]
                    end
                end
            else
                steps = 0
                for j in 1:smax
                    y - j < 1 && break
                    steps += Int(grid[x, y - j])
                    if j >= smin && cost[x, y - j, 1] > steps + cost[x, y, 2]
                        cost[x, y - j, 1] = steps + cost[x, y, 2]
                        q[(x, y - j, 1)] = cost[x, y - j, 1]
                    end
                end
                steps = 0
                for j in 1:smax
                    y + j > ncols && break
                    steps += Int(grid[x, y + j])
                    if j >= smin && cost[x, y + j, 1] > steps + cost[x, y, 2]
                        cost[x, y + j, 1] = steps + cost[x, y, 2]
                        q[(x, y + j, 1)] = cost[x, y + j, 1]
                    end
                end
            end
        end
    end

    grid = reduce(hcat, (parse.(Int, s) for s in collect.(readlines("day17.txt"))))
    nrows, ncols = size(grid)
    part[1] = solve(grid, nrows, ncols, 1, 3)
    part[2] = solve(grid, nrows, ncols, 4, 10)
    return part

end

@show day17()
