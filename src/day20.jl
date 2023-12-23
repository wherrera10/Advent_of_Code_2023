abstract type Module20 end

mutable struct FF <: Module20
    name::String
    state::Bool # low, high; off, on; false, true
    outputs::Vector{String}
    FF(name, arr) = new(name, false, arr)
end

mutable struct Conj <: Module20
    name::String
    inputs::Dict{String, Bool} # inputs and current state, starts low
    outputs::Vector{String}
    function Conj(name, outputs)
        return new(name, Dict{String, Bool}(), outputs)
    end
end

mutable struct Broad <: Module20
    name::String
    outputs::Vector{String}
end

mutable struct Button <: Module20 end

mutable struct OutputModule <: Module20
    name::String
end

mutable struct Circuit20
    lowpulses::Int
    highpulses::Int
    presscount::Int
    rxlow::Bool
    origin::String
    targetsrx::String
    byname::Dict{String, Module20}
    pulsequeue::Vector{Tuple{String, String, Bool}}
    racertimes::Dict{String, Vector{Int}}
    Circuit20() = new(0, 0, 0, false, "", "",
       Dict("output" => OutputModule("output"), "rx" => OutputModule("rx")),
       Tuple{String, String, Bool}[], Dict{String, Vector{Int}}())
end

function countone(state, p::Bool)
    if p
        state.highpulses += 1
    else
        state.lowpulses += 1
    end
end

q!(state, from, name, p) = push!(state.pulsequeue, (from, name, p))

function pulse!(state, from, m0::FF, pulse::Bool)
    pulse && return # high, nada
    m0.state = !m0.state
    out = m0.state
    for m in m0.outputs
        countone(state, out)
        q!(state, m0.name, m, out)
    end
end

function pulse!(state, from, m0::Broad, pulse)
    for m in m0.outputs
        countone(state, false)
        q!(state, m0.name, m, pulse)
    end
end

function pulse!(state, from, m0::Conj, pulse::Bool)
    m0.inputs[from] = pulse
    out = length(m0.inputs) == 1 ? !pulse : all(p -> p[2], m0.inputs) ? false : true
    out && haskey(state.racertimes, m0.name) && push!(state.racertimes[m0.name], state.presscount)
    for m in m0.outputs
        countone(state, out)
        q!(state, m0.name, m, out)
    end
end

function pulse!(state, from, m::OutputModule, pulse)
    if m.name == "rx" && !pulse
        state.rxlow = true
    end
end

function pressbutton(state, p=false)
    countone(state, p)
    state.presscount += 1
    pulse!(state, "button", state.byname[state.origin], p)
    while !isempty(state.pulsequeue)
        f, m, p = popfirst!(state.pulsequeue)
        pulse!(state, f, state.byname[m], p)
    end
end

function day20()
    part = [0, 0]
    state = Circuit20()
    lines = filter(!isempty, readlines("day20.txt"))
    for(i, line) in enumerate(lines)
        mod, outputlist = split(line, " -> ")
        outputs = split(outputlist, ", ")
        if startswith(line, "broadcaster")
            b = Broad(mod, outputs)
            state.origin = mod
            state.byname[mod] = b
        elseif startswith(line, '%')
            b = FF(mod[begin+1:end], outputs)
            state.byname[mod[begin+1:end]] = b
        elseif startswith(line, '&')
            b = Conj(mod[begin+1:end], outputs)
            state.byname[mod[begin+1:end]] = b
        else
            error("Unknown input line $line")
        end
    end
    for (name1, m) in state.byname # find inputs to each Conj module, start as low
        if m isa Conj
            for (name2, m1) in state.byname
                if !(m1 isa OutputModule) && name1 ∈ m1.outputs
                    m.inputs[name2] = false
                end
            end
        end
    end
    for (name, m) in state.byname # search for feed to "rx" output module
        if !(m isa OutputModule) && "rx" ∈ m.outputs
            state.targetsrx = name
        end
    end
    for (name, m) in state.byname # set up Conj timings for each feed to targetrx
        if m isa Conj && state.targetsrx ∈ m.outputs
            state.racertimes[name] = Int[]
        end
    end
    for i in 1:1_000_000
        #i % 10 == 0 && println("Press %i")
        pressbutton(state)
        if i == 1000
            part[1] = state.lowpulses * state.highpulses
        end
        if state.rxlow && part[2] == 0
            part[2] = i
        end
    end

    diffs = Int[]
    for times in values(state.racertimes)
        push!(diffs, diff(times)[begin])
    end
    part[2] = lcm(filter(>(0), diffs))

    return part
end

@show day20() # 925955316, 241528477694627
