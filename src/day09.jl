function day09()
    part = [0, 0]
    for line in eachline("day09.txt")
        a = [parse.(Int, split(line))]
        while !iszero(last(a))
            push!(a, diff(last(a)))
        end
        for row in lastindex(a)-1:-1:firstindex(a)
            push!(a[row], last(a[row+1]) + last(a[row]))
            pushfirst!(a[row], first(a[row]) - first(a[row+1]))
        end
        part[1] += last(first(a))
        part[2] += first(first(a))
    end
    return part # (2008960228, 1097)
end

@time day09()
