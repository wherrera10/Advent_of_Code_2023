mutable struct Brick
    zmin::Int
    blocks::Vector{CartesianIndex}
end

function day22()
    part = [0, 0]
    bricks = Brick[]
    for line in eachline("day22.txt")
        ends = [parse.(Int, x) for x in split.(split(line, "~"), ",")]
        xs, ys, zs = [min(ends[1][i], ends[2][i]):max(ends[1][i], ends[2][i]) for i in 1:3]
        push!(bricks, Brick(zs.start, vec([CartesianIndex(x, y, z) for x in xs, y in ys, z in zs])))
    end
    sort!(bricks, by = b -> b.zmin)
    bricks, moved = settle(bricks)
    for i in eachindex(bricks)
        _, moved = settle(vcat(bricks[begin:i-1], bricks[i+1:end]))
        moved == 0 && (part[1] += 1)
        part[2] += moved
    end
    return part # 454, 74287
end

function settle(brickdrop)
    bricks, settled = deepcopy(brickdrop), empty(brickdrop)
    occupied, moved = Set{CartesianIndex}(), Set{Int}()
    for i in eachindex(bricks)
        while true
            downone = [c - CartesianIndex(0, 0, 1) for c in bricks[i].blocks]
            if bricks[i].zmin == 1 || any(c ∈ occupied for c in downone)
                push!(settled, bricks[i])
                foreach(b -> push!(occupied, b), bricks[i].blocks)
                break
            end
            bricks[i].blocks = downone
            bricks[i].zmin -= 1
            push!(moved, i)
        end
    end
    return settled, length(moved)
end

@show day22()

