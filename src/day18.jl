function day18()
    part = [0, 0]

    lines = readlines("day18.txt")
    dir = CartesianIndex.([(0, 1), (1, 0), (0, -1), (-1, 0)]) # E S W N
    pos1, pos2 = CartesianIndex(0, 0), CartesianIndex(0, 0)
    total, circ = 0 , 0
    total2, circ2 = 0, 0
    for line in lines
        d, n, c = strip.(split(line))
        direc = d == "U" ? 4 : d == "R" ? 1 : d == "D" ? 2 : d == "L" ? 3 : 100
        oldpos = pos1
        pos1 += parse(Int, n) * dir[direc]
        total += oldpos[1] * pos1[2] - oldpos[2] * pos1[1]
        circ += abs(oldpos[1] - pos1[1]) + abs(pos1[2] - oldpos[2])

        d, n = parse(Int, c[end-1:end-1]), parse(Int, string(c[3:end-2]), base=16)
        direc = d == 0 ? 1 : d == 1 ? 2 : d == 2 ? 3 : d == 3 ? 4 : 100
        oldpos = pos2
        pos2 += n * dir[direc]
        total2 += oldpos[1] * pos2[2] - oldpos[2] * pos2[1]
        circ2 += abs(oldpos[1] - pos2[1]) + abs(pos2[2] - oldpos[2])
    end

    part[1] = (abs(total) +  circ) ÷ 2 + 1
    part[2] = (abs(total2) +  circ2) ÷ 2 + 1

    return part

end

day18()
