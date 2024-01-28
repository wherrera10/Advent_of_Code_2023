function day14()
    part = [0, 0]
    targetspins = 1_000_000_000
    grid = stack(Iterators.map(collect, eachline("day14.txt")), dims = 1)
	nrows, ncols = size(grid)

    countrocks(grid, nrows, ncols) = sum((nrows - i + 1) * (grid[i, j] == 'O') for i in 1:nrows, j in 1:ncols)

    function rolln!(m, nrows, ncols)
        for row in 2:nrows, col in 1:ncols
            m[row, col] == 'O' && rockn!(m, row, col)
        end
    end

    function rockn!(m, row, col)
        while row > 1
            m[row-1, col] != '.' && return
            m[row, col] = '.'
            m[row-1, col] = 'O'
            row -= 1
        end
    end  

    function rollw!(m, nrows, ncols)
        for row in 1:nrows, col in 2:ncols
            m[row, col] == 'O' && rockw!(m, row, col)
        end
    end

    function rockw!(m, row, col)
        while col > 1
            m[row, col-1] != '.' && return           
            m[row, col] = '.'
            m[row, col-1] = 'O'           
            col -= 1
        end
    end  

    function rolls!(m, nrows, ncols)
        for row in nrows-1:-1:1, col in 1:ncols
            m[row, col] == 'O' && rocks!(m, row, col, nrows)
        end
    end

    function rocks!(m, row, col, nrows)
        while row < nrows
            m[row+1, col] != '.' && return
            m[row, col] = '.'
            m[row+1, col] = 'O'
            row += 1
        end
    end

    function rolle!(m, nrows, ncols)
        for row in 1:nrows, col in ncols-1:-1:1
            m[row, col] == 'O' && rocke!(m, row, col, ncols)
        end
    end

    function rocke!(m, row, col, ncols)
        while col < ncols      
            m[row, col+1] != '.' && return           
            m[row, col] = '.'
            m[row, col+1] = 'O'           
            col += 1
        end
    end

    mat = deepcopy(grid)
    rolln!(mat, nrows, ncols)
    part[1] = countrocks(mat, nrows, ncols)

    cycleroll!(m, r, c) = (rolln!(m, r, c); rollw!(m, r, c); rolls!(m, r, c); rolle!(m, r, c))

    pastmats = String[]
    pastscores = Int[]
    idx = 0  
    while true   
        cycleroll!(grid, nrows, ncols)
        s = String(vec(grid))
        idx = findfirst(==(s), pastmats)
        if !isnothing(idx)
            precycle = idx
            cyclelength = length(pastmats) - precycle + 1
            remaining = mod1(targetspins - precycle + 1, cyclelength)
            part[2] = pastscores[precycle + remaining - 1]
            break
        end
        push!(pastmats, s)
        push!(pastscores, countrocks(grid, nrows, ncols))
    end
    return part
end

@show day14()
