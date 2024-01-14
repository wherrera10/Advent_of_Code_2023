function day01()
    part = [0, 0]
    snums = Dict("one" => '1', "two" => '2', "three" => '3', "four" => '4', "five" => '5',
       "six" => '6', "seven" => '7', "eight" => '8', "nine" => '9')
    s1, s2 = Char[], Char[]
    for line in Iterators.filter(!isempty, strip.(readlines("day01.txt")))
        empty!(s1)
        empty!(s2)
        for (i, c) in enumerate(line)
            if isdigit(c)
                push!(s1, c)
                push!(s2, c)
            end
            for (v, k) in snums
                startswith((@view line[i:end]), v) && push!(s2, k)
            end
        end
        part[1] += parse(Int, s1[begin] * s1[end])
        part[2] += parse(Int, s2[begin] * s2[end])
    end
    return part
end

@show day01() # 54940, 54208
