let
    part = [0, 0]

    txt = read("day07.txt", String)
    entries = split(replace(txt, "T" => "a", "J" => "b", "Q" => "c", "K" => "d", "A" => "e"))
    hands = [h for (i, h) in enumerate(entries) if isodd(i)]
    handvals = [parse(Int, hand, base=16) for hand in hands]
    bids = [parse(Int, h) for (i, h) in enumerate(entries) if iseven(i)]
    function score(hand)
        most2, most = sort!([count(==(x), hand) for x in "123456789abcde"])[end-1:end]
        return most * 10 + most2
    end
    scores = map(score, hands)
    fullscores = sort!([(scores[i],  handvals[i], bids[i]) for i in eachindex(bids)])
    part[1] = sum((x[3] * i for (i, x) in enumerate(fullscores)))

    function wildscore(sco, hand)
        numj = count(==('b'), hand)
        return numj == 0 ? sco : numj == 5 ? 50 : numj == 4 ? 50 : numj == 3 ? (sco == 32 ? 50 : 41) :
            numj == 2 ? (sco == 32 ? 50 : sco == 22 ? 41 : 31) :
            (sco == 41 ? 50 : sco == 31 ? 41 : sco == 22 ? 32 : sco == 21 ? 31 : 21)
    end
    wildscores = [wildscore(scores[i], hands[i]) for i in eachindex(hands)]
    wildhandvals = [parse(Int, replace(hand, "b" => "1"), base=16) for hand in hands]
    fullwildscores = sort!([(wildscores[i], wildhandvals[i], bids[i]) for i in eachindex(bids)])
    part[2] = sum(x[3] * i for (i, x) in enumerate(fullwildscores))

    @show part[1], part[2] # (248113761, 246285222)
end
