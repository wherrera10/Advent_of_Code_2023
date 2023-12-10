function day09()
    part = [0, 0]
    for a in [[parse.(Int, string.(split(line))) for line in readlines("day09.txt")]]
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
    @show part[1], part[2]  # (2008960228, 1097)
end

@time day09()
