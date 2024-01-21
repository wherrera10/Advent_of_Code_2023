using BenchmarkTools, LLVM.Interop
import Base.:+

const CI = Tuple{Int, Int}
Base.:+(x::CI, y::CI) = (x[1] + y[1], x[2] + y[2])

function day23()
    part = [0, 0]

    grid = stack(Iterators.map(collect, eachline("day23.txt")), dims = 1)
    nrows, ncols = size(grid)
    start = (1, 2)
    goal = (nrows, ncols-1)
    used = falses(nrows, ncols)
    part[1] = dfs(grid, used, start, 0, goal)

    replace!(grid, '^' => '.', '>' => '.', 'v' => '.', '<' => '.')

    # see https://github.com/Zentrik's entry, using it for speed
    idx_to_idx = Dict{CI, Int}()
    adjacency_list = NTuple{4, CI}[]
    process_node!(adjacency_list, idx_to_idx, grid, start, goal, start)

    goal_node_idx = idx_to_idx[goal]
    lost_length = adjacency_list[goal_node_idx][1][2]
    goal_node_idx = adjacency_list[goal_node_idx][1][1]
    path_mask = UInt64(0)
    part[2] = lost_length + compressed_dfs(path_mask, idx_to_idx[start], 0, goal_node_idx, adjacency_list)
    
    return part
end

const dir23 = [(-1, 0), (0, 1), (1, 0), (0, -1)]

function dfs(grid, used, c, path_length, goal)
    checkbounds(Bool, grid, c[1], c[2]) || return 0
    ch = grid[c[1], c[2]]
    ch == '#' && return 0
    used[c[1], c[2]] && return 0
    c == goal && return path_length
    used[c[1], c[2]] = true
    if ch == '.'
        result = maximum(d -> dfs(grid, used, c + d, path_length + 1, goal), dir23)
    else
        d = ch == '^' ? dir23[1] : ch == '>' ? dir23[2] : ch == 'v' ? dir23[3] : ch == '<' ? dir23[4] : error("Bad char $ch in grid")
        result = dfs(grid, used, c + d, path_length + 1, goal)
    end
    used[c[1], c[2]] = false
    return result
end


function add_child(adjacency_list, idx_to_idx, parent_node, child_node, path_len)
    incx = (1, 0)
    for node in (parent_node, child_node)
        if !haskey(idx_to_idx, node)
            idx_to_idx[node] = length(adjacency_list) + 1
            push!(adjacency_list, Tuple(incx for _ in 1:4))
        end
    end
    idx = idx_to_idx[parent_node]
    next_free_idx = findfirst(==(incx), adjacency_list[idx])
    new_tuple = Base.setindex(adjacency_list[idx], (idx_to_idx[child_node], path_len), next_free_idx)
    adjacency_list[idx] = new_tuple
end

function process_node!(adjacency_list, idx_to_idx, grid, node, goal_node, parent_node)
    path_len = node != parent_node

    while true
        grid[node[1], node[2]] = 'X'
        path_len += 1

        if node == goal_node
            add_child(adjacency_list, idx_to_idx, parent_node, node, path_len - 1)
            add_child(adjacency_list, idx_to_idx, node, parent_node, path_len - 1)
            break
        end

        possible_paths = 0
        for d in dir23
            next_node = node + d
            checkbounds(Bool, grid, next_node[1], next_node[2]) || continue
            next_node == parent_node && continue

            possible_paths += grid[next_node[1], next_node[2]] == '.'

            if grid[next_node[1], next_node[2]] == 'B'
                add_child(adjacency_list, idx_to_idx, parent_node, next_node, path_len)
                add_child(adjacency_list, idx_to_idx, next_node, parent_node, path_len)
            end
        end

        possible_paths == 0 && break

        if possible_paths == 1
            for d in dir23
                next_node = node + d
                checkbounds(Bool, grid, next_node[1], next_node[2]) || continue

                if grid[next_node[1], next_node[2]] == '.'
                    node = next_node
                    break
                end
            end
        else
            grid[node[1], node[2]] = 'B'

            add_child(adjacency_list, idx_to_idx, parent_node, node, path_len - 1)
            add_child(adjacency_list, idx_to_idx, node, parent_node, path_len - 1)

            for d in dir23
                next_node = node + d
                checkbounds(Bool, grid, next_node[1], next_node[2]) || continue

                if grid[next_node[1], next_node[2]] == '.'
                    process_node!(adjacency_list, idx_to_idx, grid, next_node, goal_node, node)
                end
            end

            break
        end
    end
end


function compressed_dfs(path_mask, node, path_length, goal_node, adjacency_list)
    node == goal_node && return path_length

    assume(node > 0)
    assume(node < 64)
    path_mask |= UInt64(1) << node
    max_len = 0
    for child in @inbounds adjacency_list[node]
        @inbounds child_node = child[1]
        assume(child_node > 0)
        assume(child_node < 64)
        (path_mask & UInt64(1) << child_node) != 0 && continue

        @inbounds max_len = max(max_len, compressed_dfs(path_mask, child_node, path_length + child[2], goal_node, adjacency_list))
    end

    return max_len
end

@btime day23()
@show day23()
