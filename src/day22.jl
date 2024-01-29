function day22()
    part = [0, 0]
    bricks = [parse.(Int, split(line, r",|~")) for line in eachline("day22.txt")]
    sort!(bricks, by = b -> b[3])
    nbricks = length(bricks)
    heights = zeros(Int, 100)
    indices = fill(typemax(Int32), 100)
    safe = trues(nbricks)
    dominator = Tuple{Int, Int}[]

    for (i, (x1, y1, z1, x2, y2, z2)) in enumerate(bricks)
        start = 10 * y1 + x1;
        stop = 10 * y2 + x2;
        step = y2 > y1 ? 10 : 1
        height = z2 - z1 + 1
        top = 0;
        previous = typemax(Int32)
        underneath = 0;
        parent = 0;
        depth = 0;

        for j in start+1:step:stop+1
            top = max(top, heights[j])
        end

        for j in start+1:step:stop+1
            if heights[j] == top
                index = indices[j]
                if index != previous
                    previous = index
                    underneath += 1
                    if underneath == 1
                        parent, depth = dominator[previous]
                    else
                        # Find common ancestor
                        a, b = parent, depth
                        x, y = dominator[previous]
                        while b > y
                            a, b = dominator[a]
                        end
                        while y > b
                            x, y = dominator[x]
                        end
                        while a != x
                            a, b = dominator[a]
                            x = dominator[x][begin]
                        end
                        parent, depth = a, b
                    end
                end
            end
            heights[j] = top + height
            indices[j] = i
        end
        if underneath == 1
            safe[previous] = false
            parent = previous
            depth = dominator[previous][begin+1] + 1
        end

        push!(dominator, (parent, depth))
    end

    part[1] = sum(safe)
    part[2] = sum(d -> d[2], dominator)

    return part
end

@time day22()
