const moves = [[0, 1], [1, 0], [0, -1], [-1, 0]]
const charmove = Dict{Char, Vector{Int}}('L' => [1, 4], '|' => [2, 4], '-' => [1, 3], '7' => [2, 3],
                                         'F' => [1, 2], 'J' => [3, 4], '.' => Int[])

function floodfill!(m::Matrix, x, y, xdim, ydim)
    for i in max(1, x-1):min(x+1, xdim), j in max(1, y-1):min(y+1, ydim)
        if m[i, j] == '.'
            m[i, j] = ' '
            floodfill!(m, i, j, xdim, ydim)
        end
    end
end

function day10()
    part = [0, 0]
    mat = Char.(reshape(collect(read("day10.txt")), (141, 140))')
    x, y, move = 43, 26, 1
    visited = Dict{Vector{Int}, Int}([x, y] => 0)
    nvisited = 0
    mat[x, y] = '7'
    while true
        move = first(setdiff(charmove[mat[x, y]], [3, 4, 1, 2][move]))
        x, y = [x, y] .+ moves[move]
        nvisited += 1
        if haskey(visited, [x, y])
            break
        else
            visited[[x, y]] = nvisited
        end
    end
    part[1] = (nvisited + 1) ÷ 2

    graph = fill('.', 280, 282)
    for (x, y) in keys(visited)
        c = mat[x, y]
        graph[2x-1, 2y-1] = c
        if c == '-' || c == 'L' || c == 'F'
            graph[2x-1, 2y] = '-'
        end
        if c == '|' || c == '7' || c == 'F'
            graph[2x, 2y-1] = '|'
        end
    end
    for x in 1:280, y in [1, 282]
        graph[x, y] == '.' && floodfill!(graph, x, y, 280, 282)
    end
    part[2] = count(==('.'), graph[1:2:280, 1:2:281])

    return part
end

@show day10()
