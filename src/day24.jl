using JuMP, Ipopt

const T3 = Tuple{Float64, Float64, Float64}

function day24()
	part = [0, 0]

	p0, v0 = T3[], T3[]
	for line in filter(!isempty, strip.(readlines("day24.txt")))
		x, y, z, vx, vy, vz = parse.(Float64, split(line, r"[\s\@,]+"))
		push!(p0, T3((x, y, z)))
		push!(v0, T3((vx, vy, vz)))
	end
	boun = (200000000000000, 400000000000000)
	for i in firstindex(p0):lastindex(p0)-1, j in i+1:lastindex(p0)
		x, y = rays_intersection(p0[i], p0[j], v0[i], v0[j])
		x isa Nothing && continue
		if boun[1] <= x <= boun[2] && boun[1] <= y <= boun[2]
			part[1] += 1
		end
	end

	model = Model(Ipopt.Optimizer)
	set_silent(model)
	@variables(model, begin x; y; z; vx; vy; vz end)

	# Solvable with just 3 points for constraints (same line / plane  for all points)
	t_1 = @variable(model, t_1)
	@constraint(model, p0[1][1] + v0[1][1] * t_1 == x + vx * t_1)
	@constraint(model, p0[1][2] + v0[1][2] * t_1 == y + vy * t_1)
	@constraint(model, p0[1][3] + v0[1][3] * t_1 == z + vz * t_1)
	t_2 = @variable(model, t_2)
	@constraint(model, p0[2][1] + v0[2][1] * t_2 == x + vx * t_2)
	@constraint(model, p0[2][2] + v0[2][2] * t_2 == y + vy * t_2)
	@constraint(model, p0[2][3] + v0[2][3] * t_2 == z + vz * t_2)
	t_3 = @variable(model, t_3)
	@constraint(model, p0[3][1] + v0[3][1] * t_3 == x + vx * t_3)
	@constraint(model, p0[3][2] + v0[3][2] * t_3 == y + vy * t_3)
	@constraint(model, p0[3][3] + v0[3][3] * t_3 == z + vz * t_3)

	@objective(model, Min, 1.0)
	JuMP.optimize!(model)
	#solution_summary(model)
	part[2] = Int.(round(value(x) + value(y) + value(z)))

	return part
end

""" Intersection of rays from p0, p1 with velocities v0, v1 """
function rays_intersection(p0, p1, v0, v1)
	dx = p1[1] - p0[1]
	dy = p1[2] - p0[2]
	det = v1[1] * v0[2] - v1[2] * v0[1]
	u = (dy * v1[1] - dx * v1[2]) / det
	v = (dy * v0[1] - dx * v0[2]) / det
	(u < 0 || v < 0) && return nothing, nothing

	m0 = v0[2] / v0[1]
	m1 = v1[2] / v1[1]
	b0 = p0[2] - m0 * p0[1]
	b1 = p1[2] - m1 * p1[1]
	x = (b1 - b0) / (m0 - m1)
	y = m0 * x + b0
	return isfinite(x) ? (x, y) : (nothing, nothing)
end

@time day24()
