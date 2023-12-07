let
    part = [0, 0]
    values = Dict{Char, Int}(c => i for (i, c) in enumerate(collect("23456789TJQKA")))

    function score(hand)
        most2, most = sort!([count(==(x), hand) for x in cards])[end-1:end]
        return most == 5 ? 6 : most == 4 ? 5 : most == 3 ? (most2 > 1 ? 4 : 3) :
               most == 2 ? (most2 == 2 ? 2 : 1) : 0
    end

    function lt_hands(a, b)
        ca, cb = score(a), score(b)
        ca != cb && return ca < cb
        return [values[x] for x in a] < [values[x] for x in b]
    end
    function lt_hands(a, b, a1, b1)
        ca, cb = score(a), score(b)
        ca != cb && return ca < cb
        return [newvalues[x] for x in a1] < [newvalues[x] for x in b1]
    end

    entries = filter(!isempty, split(read("day07.txt", String)))
    hands = [collect(h) for (i, h) in enumerate(entries) if isodd(i)]
    bids = [parse(Int, h) for (i, h) in enumerate(entries) if iseven(i)]
    ranked = sort(zip(hands, bids), lt = (x, y) -> lt_hands(x[1], y[1]))
    part[1] = sum(x[2] * i for (i, x) in enumerate(ranked))

    function usejoker(hand)
        jloc = findall(==('J'), hand)
        jcount = length(jloc)
        jcount == 0 && return hand
        jcount == 5 && return fill('A', 5)
        noj = filter(!=('J'), hand)
        c =  score(noj) in [0, 2] ? sort(noj, by = x -> newvalues[x])[end] :
                                    first(filter(x -> count(==(x), noj) >= 2, noj))
        newhand = deepcopy(hand)
        newhand[jloc] .= c
        return newhand
    end

    newvalues = Dict{Char, Int}(c => i for (i, c) in enumerate(collect("J23456789TQKA")))
    newzipped = zip(map(usejoker, hands), bids, hands)
    newranked = sort(newzipped, lt = (x, y) -> lt_hands(x[1], y[1], x[3], y[3]))
    part[2] = sum(x[2] * i for (i, x) in enumerate(newranked))

    @show part[1], part[2] # (part[1], part[2]) = (248113761, 246285222)
end
