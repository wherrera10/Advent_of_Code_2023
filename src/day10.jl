const moves = [[0, 1], [1, 0], [0, -1], [-1, 0]]
const charmove = Dict{Char, Vector{Int}}('L' => [1, 4], '|' => [2, 4], '-' => [1, 3], '7' => [2, 3],
                                         'F' => [1, 2], 'J' => [3, 4], '.' => Int[])
used(frompos) = [3, 4, 1, 2][frompos]

function day10()
    part = [0, 0]
    mat = Char.(reshape(collect(read("day10.txt")), (141, 140))')
    x, y, move = 43, 26, 1
    visited = Dict{Vector{Int}, Int}([x, y] => 0)
    nvisited = 0
    mat[x, y] = '7'
    while true
        move = first(setdiff(charmove[mat[x, y]], used(move)))
        x, y = [x, y] .+ moves[move]
        nvisited += 1
        if haskey(visited, [x, y])
            break
        else
            visited[[x, y]] = nvisited
        end
    end
    part[1] = nvisited ÷ 2

    graph = fill('.', 280, 282)
    for (x, y) in keys(visited)
        c = mat[x, y]
        graph[2x-1, 2y-1] = c
        if c == '-'
            graph[2x-1, 2y] = '-'
        elseif c == '|'
            graph[2x, 2y-1] = '-'
        elseif c == 'F'
            graph[2x-1, 2y] = '-'
            graph[2x, 2y-1] = '|'
        elseif c == 'L'
            graph[2x-1, 2y] = '-'
        elseif c == '7'
            graph[2x, 2y-1] = '|'
        end
    end

    locations = Vector{Int}[]
    for x in 1:280, y in [1, 282]
        graph[x, y] == '.' && push!(locations, [x, y])
    end
    while !isempty(locations)
        newlocations = empty(locations)
        for (x, y) in locations
            for i in max(1, x-1):min(x+1, 280), j in max(1, y-1):min(y+1, 282)
                if graph[i, j] == '.'
                    graph[i,j] = ' '
                    push!(newlocations, [i, j])
                end
            end
        end
        locations = newlocations
    end
    part[2] = count(==('.'), graph[1:2:280, 1:2:281])
    return part
end

@show day10() # (7173, 291),
