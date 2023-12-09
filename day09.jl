let
    part = [0, 0]
    lines = [[[parse(Int, x) for x in split(strip(s))]] for s in filter(!isempty, readlines("day09.txt"))]

    for a in deepcopy(lines)
        while any(!iszero, a[end])
            push!(a, [a[end][i] - a[end][i - 1] for i in 2:length(a[end])])
        end
        for row in length(a)-1:-1:1
            push!(a[row], a[row+1][end] + a[row][end])
            pushfirst!(a[row], a[row][begin] - a[row+1][begin])
        end
        part[1] += a[1][end]
        part[2] += a[1][begin]
    end

    @show part[1], part[2]  # (2008960228, 1097)
end
