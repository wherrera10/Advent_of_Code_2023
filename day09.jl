let
    part = [0, 0]
    lines = [[[parse(Int, x) for x in split(strip(s))]] for s in filter(!isempty, readlines("day09.txt"))]

    for a in deepcopy(lines)
        while any(!iszero, a[end])
            push!(a, [a[end][i] - a[end][i - 1] for i in firstindex(a[end])+1:lastindex(a[end])])
        end
        for row in lastindex(a)-1:-1:firstindex(a)
            push!(a[row], a[row+1][end] + a[row][end])
            pushfirst!(a[row], a[row][begin] - a[row+1][begin])
        end
        part[1] += a[begin][end]
        part[2] += a[begin][begin]
    end

    @show part[1], part[2]  # (2008960228, 1097)
end
