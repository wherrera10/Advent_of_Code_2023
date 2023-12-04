const txt = read("day03.txt", String)
const chars = collect(txt)
const locations = Vector{Pair{Int, Vector{Int}}}()
const gearnumbers = Dict{Int, Set{Int}}()
const part = [0, 0]

function surroundsymbols(a, i, rows, cols)
    ret = Pair{Char, Int}[]
    x0, y0 = mod1(i, cols), (i - 1) ÷ cols + 1
    xrange = max(1, x0-1):min(cols, x0+1)
    yrange = max(1, y0-1):min(rows, y0+1)
    for x in xrange, y in yrange
        x == x0 && y == y0 && continue
        j = (y - 1) * cols + x
        c = a[j]
        c != '.' && !isspace(c) && !isdigit(c) && push!(ret, c => j)
    end
    return ret
end

for m in eachmatch(r"\d+", txt)
    range = m.match.offset+1:m.match.offset+m.match.ncodeunits
    n = parse(Int, txt[range])
    push!(locations, n => sort!(collect(range)))
end

for loc in locations
    bysymbol = false
    for i in last(loc)
        !isempty(surroundsymbols(chars, i, 140, 141)) && (bysymbol = true)
    end
    bysymbol && (part[1] += first(loc))
end

for loc in locations
    for i in loc[2], p in unique(surroundsymbols(chars, i, 140, 141))
        if any(p -> p[1] ==('*'), p)
            !haskey(gearnumbers, p[2]) && (gearnumbers[p[2]] = Set{Int}())
            push!(gearnumbers[p[2]], loc[1])
        end
    end
end

for gear in gearnumbers
    if length(gear[2]) == 2
        part[2] += prod(gear[2])
    end
end

@show part
