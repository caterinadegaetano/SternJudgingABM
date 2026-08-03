#defining the ambiguity model Properties
mutable struct AmbiguityModelProps
    rep::Matrix{Vector{Float64}} #matrix of priors about reputation of agent j according to agent i 
    p_error::Float64
    p_observe::Float64 #probability of updating truthfully a prior
    p_misperception::Float64 #probability of updatini wrongly a prior (misperception)
    max_priors::Int64 #max number of priors stored by each agent
    p_mutation::Float64 #probability of having a random mutation
    p_evolve::Float64 #percentage of population that can change kind at each step
    n_evolve::Int64 #evolution happens every n steps
    n_played_log::Dict{Int, Vector{Int}}
    comparison_n_played_log::Vector{Tuple{Int,Int}}
    coop_window::Int64
    coop_window_count::Int64
    coop_window_log::Vector{Float64}
    b::Float64 #benefit of received cooperation
    c::Float64 #cost of giving cooperation
end
#Filling the model properties (defining parameters)
Ambiguity_properties = AmbiguityModelProps(
    Matrix{Vector{Float64}}(undef, N, N),
    0.02, 0.9, 0.05, 5, 0.001, 0.001, 50, Dict(id => Int[] for id in 1:25), Tuple{Int,Int}[], 50, 0, Float64[], 5.0, 1.0
)

#defining the NoisyInfo model Properties
mutable struct NoisyInfoModelProps
    rep::Matrix{Symbol} #matrix of subjective reputation of agent j according to agent i 
    p_error::Float64
    p_observe::Float64
    p_misperception::Float64
    p_noise::Float64
    p_mutation::Float64
    p_evolve::Float64 #percentage of population that can change kind at each step
    n_evolve::Int64 #evolution happens every n steps
    n_played_log::Dict{Int, Vector{Int}}
    comparison_n_played_log::Vector{Tuple{Int,Int}}
    coop_window::Int64
    coop_window_count::Int64
    coop_window_log::Vector{Float64}
    b::Float64 #benefit of received cooperation
    c::Float64 #cost of giving cooperation
end
#Filling the model properties (defining parameters)
Noisy_properties = NoisyInfoModelProps(
    Matrix{Symbol}(undef, N, N),
   0.02, 0.9, 0.05, 0.02, 0.001, 0.001, 50, Dict(id => Int[] for id in 1:25), Tuple{Int,Int}[], 50, 0, Float64[], 5.0, 1.0
)

#defining the PerfectInfo model Properties
mutable struct ModelProps
    θ::Vector{Symbol} #objective reputation according to Stern Judging
    p_error::Float64
    p_mutation::Float64
    p_evolve::Float64 #percentage of population that can change kind at each step
    n_evolve::Int64 #evolution happens every n steps
    n_played_log::Dict{Int, Vector{Int}}
    comparison_n_played_log::Vector{Tuple{Int,Int}}
    coop_window::Int64
    coop_window_count::Int64
    coop_window_log::Vector{Float64}
    b::Float64 #benefit of received cooperation
    c::Float64 #cost of giving cooperation
end
#Filling the model properties (defining parameters)
properties = ModelProps(
    Vector{Symbol}(undef, N),
   0.02, 0.001, 0.001, 50, Dict(id => Int[] for id in 1:25), Tuple{Int,Int}[], 50, 0, Float64[], 5.0, 1.0
)
