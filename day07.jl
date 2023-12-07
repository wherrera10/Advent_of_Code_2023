let
    part = [0, 0]
    cards = collect("23456789TJQKA")
    values = Dict{Char, Int}(c => i for (i, c) in enumerate(cards))
    newvalues = Dict{Char, Int}(c => i for (i, c) in enumerate(collect("J23456789TQKA")))

    counts(hand) = [count(==(x), hand) for x in cards]
    is5(cnt) = any(==(5), cnt)
    is4(cnt) = any(==(4), cnt)
    isfh(cnt) = any(==(3), cnt) && any(==(2), cnt)
    is3(cnt) = any(==(3), cnt)
    is2p(cnt) = count(==(2), cnt) == 2
    is1p(cnt) = count(==(2), cnt) == 1
    ishc(cnt) = all(<=(1), cnt)
    function scorehand(hand)
        cnt = counts(hand)
        return is5(cnt) ? 6 : is4(cnt) ? 5 : isfh(cnt) ? 4 : is3(cnt) ? 3 : is2p(cnt) ? 2 : is1p(cnt) ? 1 : 0
    end

    function lt_hands(a, b)
        ca, cb = scorehand(a), scorehand(b)
        ca != cb && return ca < cb
        return [values[x] for x in a] < [values[x] for x in b]
    end

    function lt_hands(a, b, a1, b1)
        ca, cb = scorehand(a), scorehand(b)
        ca != cb && return ca < cb
        return [newvalues[x] for x in a1] < [newvalues[x] for x in b1]
    end

    entries = filter(!isempty, split(read("day07.txt", String)))
    hands = [collect(h) for (i, h) in enumerate(entries) if isodd(i)]
    bids = [parse(Int, h) for (i, h) in enumerate(entries) if iseven(i)]
    zipped = zip(hands, bids)
    ranked = sort(zipped, lt = (x, y) -> lt_hands(x[1], y[1]))
    part[1] = sum(x[2] * i for (i, x) in enumerate(ranked))

    function usejoker(hand)
        jloc = findall(==('J'), hand)
        jcount = length(jloc)
        jcount == 0 && return hand
        noj = filter(!=('J'), hand)
        cnt = counts(noj)
        c = 'J'
        if jcount == 1
            if is4(cnt) || is3(cnt)
                c = first(filter(x -> count(==(x), noj) >= 3, noj))
            elseif is2p(cnt) || ishc(cnt)
                c = sort(noj, by = x -> newvalues[x])[end]
            elseif is1p(cnt)
                c = first(filter(x -> count(==(x), noj) >= 2, noj))
            end
        elseif jcount == 2
            if is3(cnt) || is1p(cnt)
                c = first(filter(x -> count(==(x), noj) >= 2, noj))
            elseif ishc(cnt)
                c = sort(noj, by = x -> newvalues[x])[end]
            end
        elseif jcount >= 3
            jcount == 5 && return fill('A', 5)
            c = sort(noj, by = x -> newvalues[x])[end]
        end
        newhand = deepcopy(hand)
        newhand[jloc] .= c
        return newhand
    end

    newhands = map(usejoker, hands)
    newzipped = zip(newhands, bids, hands)
    newranked = sort(newzipped, lt = (x, y) -> lt_hands(x[1], y[1], x[3], y[3]))
    part[2] = sum(x[2] * i for (i, x) in enumerate(newranked))

    @show part[1], part[2] # (part[1], part[2]) = (248113761, 246285222)
end
