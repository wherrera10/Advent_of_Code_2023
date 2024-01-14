function day07()
    part = [0, 0]
    txt = read("day07.txt", String)
    entries = split(replace(txt, "T" => "a", "J" => "b", "Q" => "c", "K" => "d", "A" => "e"))
    hands = [h for (i, h) in enumerate(entries) if isodd(i)]
    wildhands = map(s -> replace(s, "b" => "1"), hands)
    bids = [parse(Int, h) for (i, h) in enumerate(entries) if iseven(i)]

    function score(hand)
        most2, most = sort!([count(==(x), hand) for x in "123456789abcde"])[end-1:end]
        return most * 10 + most2
    end

    function wildscore(sco, hand)
        numj = count(==('b'), hand)
        return numj == 0 ? sco : numj == 5 ? 50 : numj == 4 ? 50 : numj == 3 ? (sco == 32 ? 50 : 41) :
            numj == 2 ? (sco == 32 ? 50 : sco == 22 ? 41 : 31) :
            (sco == 41 ? 50 : sco == 31 ? 41 : sco == 22 ? 32 : sco == 21 ? 31 : 21)
    end

    scores = map(score, hands)
    wildscores = map(i -> wildscore(scores[i], hands[i]), eachindex(scores))

    part[1] = sum(x[3] * i for (i, x) in enumerate(sort!(collect(zip(scores, hands, bids)))))
    part[2] = sum(x[3] * i for (i, x) in enumerate(sort!(collect(zip(wildscores, wildhands, bids)))))
    return part
end

@time day07() # 248113761, 246285222
