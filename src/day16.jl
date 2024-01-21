using BenchmarkTools

const N, E, S, W = (-1, 0), (0, 1), (1, 0), (0, -1)
const dir16 = [N, E, S, W]

function day16()
	part = [0, 0]

	grid = stack(Iterators.map(collect, eachline("day16.txt")), dims = 1)
	nrows, ncols = size(grid)
    energized = zeros(UInt8, nrows, ncols)
	countgrid!(grid, energized, 1, 1, E)
	part[1] = count(!=(0x0), energized)

    energized = zeros(UInt8, nrows, ncols)

    for x in 1:nrows
        energized .= 0x0
        countgrid!(grid, energized, x, 1, E)
        part[2] = max(part[2], count(!=(0x0), energized))

        energized .= 0x0
        countgrid!(grid, energized, x, ncols, W)
        part[2] = max(part[2], count(!=(0x0), energized))
    end

    for y in 1:ncols
        energized .= 0x0
        countgrid!(grid, energized, 1, y, S)
        part[2] = max(part[2], count(!=(0x0), energized))

        energized .= 0x0
        countgrid!(grid, energized, nrows, y, N)
        part[2] = max(part[2], count(!=(0x0), energized))
    end

    return part
end

function countgrid!(grid, energized, startx, starty, dir)
    checkbounds(Bool, grid, startx, starty) || return

	b = dir == N ? 1 : dir == E ? 2 : dir == S ? 4 : 8
	energized[startx, starty] & b != 0 && return
    energized[startx, starty] |= b

	ch = grid[startx, starty]
	if ch == '|'
		if dir == E || dir == W
			dir = N
			countgrid(grid, energized, startx + S[1], starty + S[2], S)
		end
	elseif ch == '-'
		if dir == N || dir == S
			dir = E
			countgrid(grid, energized, startx + W[1], starty + W[2], W)
		end
	elseif ch == '/'
		dir = dir == N ? E : dir == E ? N : dir == S ? W : S
	elseif ch == '\\'
		dir = dir == N ? W : dir == E ? S : dir == S ? E : N
	end
    countgrid!(grid, energized, startx + dir[1], starty + dir[2], dir)
end

@btime day16()
@show day16() # day16() = [6361, 6701]
