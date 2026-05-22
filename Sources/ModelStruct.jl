#defining the ambiguity model Properties
mutable struct AmbiguityModelProps
    θ::Vector{Symbol} #objective reputation according to Stern Judging
    rep::Matrix{Vector{Float64}} #matrix of priors about reputation of agent j according to agent i 
    p_error::Float64
    p_truth::Float64 #probability of updating truthfully a prior
    p_update::Float64 #proability of randomly updating a prior
    p_new::Float64 #probability of adding a new prior 
    max_priors::Int64 #max number of priors stored by each agent
    p_evolve::Float64 #percentage of population that can change kind at each step
    p_mutation::Float64 #probability of having a random mutation
    b::Float64 #benefit of received cooperation
    c::Float64 #cost of giving cooperation
end
#Filling the model properties (defining parameters)
Ambiguity_properties = AmbiguityModelProps(
    Vector{Symbol}(undef, N),
    Matrix{Vector{Float64}}(undef, N, N),
    0.02, 0.5, 0.2, 0.1, 5, 0.001, 0.001, 2.0, 1.0
)

#defining the NoisyInfo model Properties
mutable struct NoisyInfoModelProps
    θ::Vector{Symbol} #objective reputation according to Stern Judging
    rep::Matrix{Symbol} #matrix of subjective reputation of agent j according to agent i 
    p_error::Float64
    p_noise::Float64
    p_misperception::Float64
    p_observe::Float64
    p_mutation::Float64
    p_evolve::Float64 #percentage of population that can change kind at each step
    b::Float64 #benefit of received cooperation
    c::Float64 #cost of giving cooperation
end
#Filling the model properties (defining parameters)
Noisy_properties = NoisyInfoModelProps(
    Vector{Symbol}(undef, N),
    Matrix{Symbol}(undef, N, N),
   0.02, 0.05, 0.02, 0.5, 0.001, 0.001, 2.0, 1.0
)

#defining the PerfectInfo model Properties
mutable struct ModelProps
    θ::Vector{Symbol} #objective reputation according to Stern Judging
    p_error::Float64
    p_mutation::Float64
    p_evolve::Float64 #percentage of population that can change kind at each step
    b::Float64 #benefit of received cooperation
    c::Float64 #cost of giving cooperation
end
#Filling the model properties (defining parameters)
properties = ModelProps(
    Vector{Symbol}(undef, N),
   0.02, 0.001, 0.001, 2.0, 1.0
)
