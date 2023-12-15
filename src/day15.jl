function day15()
    part = [0, 0]

    hash15(c::Integer, prev) = ((prev + Int(c)) * 17) % 256
    hash15(v::Vector) = reduce(hash15, v, init = 0)
    hash15(s::AbstractString) = hash15(Int.(collect(s)))

    part1steps = split(read("day15.txt", String), ",")
    part[1] = sum(hash15.(part1steps))

    part2steps = Tuple{String, Int, Int}[]
    for s in filter(!isempty, strip.(part1steps))
        if last(s) == '-'
            push!(part2steps, (s[begin:end-1], hash15(s[begin:end-1]), 0))
        else
            b, i = split(s, "=")
            push!(part2steps, (b, hash15(b), parse(Int, i)))
        end
    end
    boxes = [Vector{Tuple{String, Int, Int}}() for _ in 1:256]
    for t in part2steps
        b = boxes[t[2] + 1] # zero based index to 1-based here
        if t[3] == 0 # remove
            filter!(x -> t[1] != x[1], b)
        else # add or replace
            if isempty(b)
                push!(b, t) # add
            else
                for (i, lens) in enumerate(b)
                    if t[1] == lens[1]
                        b[i] = t  # replace
                        break
                    end
                    if i == lastindex(b)
                        push!(b, t) # add
                    end
                end
            end
        end
    end
    for (bnum, box) in enumerate(boxes), (slotnum, lens) in enumerate(box)
        part[2] += bnum * slotnum * lens[3]
    end

    return part
end



@time day15()

