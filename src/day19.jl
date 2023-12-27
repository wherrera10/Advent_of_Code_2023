function day19()
    part = [0, 0]

    workflows = Dict{String, Vector{Vector{String}}}()
    wrk, par = split(read("day19.txt", String), "\n\n")
    for line in filter!(!isempty, strip.(split(wrk, "\n")))
        rul, tests = split(line[begin:end-1], "{")
        workflows[rul] = [split(s, ":") for s in split(tests, ",")]
    end
    parts = [[parse(Int, m.match) for m in eachmatch(r"\d+", line)] for line in filter!(!isempty, split(par, "\n"))]

    # part 1
    for p in parts
        wrule = "in"
        while true
            rules = workflows[wrule]
            x, m, a, s = p # xmas, hahaha
            for r in rules
                if length(r) == 1
                    wrule = first(r)
                    break
                end
                c = first(r)[1]
                n = parse(Int, first(r)[3:end])
                k = c == 'x' ? x : c == 'm' ? m : c == 'a' ? a : s
                if first(r)[2] == '>' && k > n
                    wrule = last(r)
                    break
                elseif first(r)[2] == '<' && k < n
                    wrule = last(r)
                    break
                end
            end
            if wrule == "A"
                part[1] += sum(p)
                break
            elseif wrule == "R"
                break
            end
        end
    end

    # part 2 is via the recursive function below this one
    part[2] = countcombos(workflows, [1:4000, 1:4000, 1:4000, 1:4000], "in")

    return part
end

function countcombos(workflows, rvec, flow::String)
    flow == "R" && return 0
    flow == "A" && return prod(r.stop - r.start + 1 for r in rvec)
    usedefault, combocount, rulelist = true, 0, workflows[flow]
    rules = rulelist[begin:end-1]
    default = rulelist[end][begin]

    for r in rules
        c = first(r)[1:1]
        n = parse(Int, first(r)[3:end])
        ridx = findfirst(c, "xmas")[begin] # giggles
        rang = rvec[ridx]
        succeed, fail = first(r)[2] == '<' ? (rang.start:n-1, n:rang.stop) : (n+1:rang.stop, rang.start:n) 
        if !isempty(succeed)
            newrvec = deepcopy(rvec)
            newrvec[ridx] = succeed
            combocount += countcombos(workflows, newrvec, r[end])
        end
        if !isempty(fail)
            rvec = deepcopy(rvec)
            rvec[ridx] = fail
        else
            usedefault = false # if all of range succeeded, the default path is not taken
            break # so processing complete before we reach end of the rules
        end
    end
    if usedefault
        combocount += countcombos(workflows, rvec, default)
    end
    return combocount
end


@show day19()
