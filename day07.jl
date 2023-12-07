const part = [0, 0]

const txt = read("day07.txt", String)
const entries = split(replace(txt, "T" => "a", "J" => "b", "Q" => "c", "K" => "d", "A" => "e"))
const hands = [h for (i, h) in enumerate(entries) if isodd(i)]
const bids = [parse(Int, h) for (i, h) in enumerate(entries) if iseven(i)]
const wildhands = map(s -> replace(s, "b" => "1"), hands)

function score(hand)
    most2, most = sort!([count(==(x), hand) for x in "123456789abcde"])[end-1:end]
    return most * 10 + most2
end

function wildscore(sco, hand)
    numj = count(==('b'), hand)
    return numj == 5 ? 50 : numj == 4 ? 50 : numj == 3 ? (sco == 32 ? 50 : 41) :
           numj == 2 ? (sco == 32 ? 50 : sco == 22 ? 41 : 31) :
           (sco == 41 ? 50 : sco == 31 ? 41 : sco == 22 ? 32 : sco == 21 ? 31 : 21)
end

const scores = map(score, hands)
const wildscores = map(i -> wildscore(scores[i], hands[i]), eachindex(scores))

part[1] = sum(x[3] * i for (i, x) in enumerate(sort!(collect(zip(scores, hands, bids)))))

part[2] = sum(x[3] * i for (i, x) in enumerate(sort!(collect(zip(wildscores, wildhands, bids)))))

@show part[1], part[2] # (part[1], part[2]) = (248113761, 246285222)
