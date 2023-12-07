const part = [0, 0]
const values = Dict{Char, Int}(c => i for (i, c) in enumerate(collect("23456789TJQKA")))
const newvalues = Dict{Char, Int}(c => i for (i, c) in enumerate(collect("J23456789TQKA")))

function score(hand, oldhand = Int[])
    most2, most = sort!([count(==(x), hand) for x in "23456789TJQKA"])[end-1:end]
    (most == 5 ? 6 : most == 4 ? 5 : most == 3 ? (most2 > 1 ? 4 : 3) :
     most == 2 ? (most2 == 2 ? 2 : 1) : 0),
    (isempty(oldhand) ? map(x -> values[x], hand) : map(x -> newvalues[x], oldhand))
end

const entries = filter(!isempty, split(read("day07.txt", String)))
const hands = [collect(h) for (i, h) in enumerate(entries) if isodd(i)]
const bids = [parse(Int, h) for (i, h) in enumerate(entries) if iseven(i)]
const zipped = collect(zip(hands, bids, map(score, hands)))
part[1] = sum(x[2] * i for (i, x) in enumerate(sort(zipped; by = last)))

function usejoker(hand)
    jloc = findall(==('J'), hand)
    jcount = length(jloc)
    jcount == 0 && return hand
    jcount == 5 && return fill('A', 5)
    noj = filter(!=('J'), hand)
    c = score(noj)[1] in [0, 2] ? sort(noj, by = x -> newvalues[x])[end] :
        first(filter(x -> count(==(x), noj) >= 2, noj))
    newhand = deepcopy(hand)
    newhand[jloc] .= c
    return newhand
end

const wilds = map(usejoker, hands)
const newzipped = collect(zip(wilds, bids, [score(wilds[i], hands[i]) for i in eachindex(hands)]))
part[2] = sum(x[2] * i for (i, x) in enumerate(sort!(newzipped; by = last)))

@show part[1], part[2] # (part[1], part[2]) = (248113761, 246285222)
