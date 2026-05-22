
# minimal model for testing shared functions
# using perfect info version since it has fewest parameters
@agent struct Agent(NoSpaceAgent)
    kind::Symbol #whether the agent is ALLC, ALLD, or COND
    C_given::Int64 #whether in present step the agent cooperate
    C_received::Int64 #how many donors in present cooperate with the agent
    payoff::Float64 #payoff of present step
    strategy::Symbol #strategy of present step
end

mutable struct ModelProps
    θ::Vector{Symbol}
    p_evolve::Float64
    b::Float64
    c::Float64
end

mutable struct NoisyInfoModelProps
    θ::Vector{Symbol} #objective reputation according to Stern Judging
    rep::Matrix{Symbol} #matrix of subjective reputation of agent j according to agent i 
    p_noise::Float64
    p_misperception::Float64
    p_observe::Float64
    p_evolve::Float64 #percentage of population that can change kind at each step
    b::Float64 #benefit of received cooperation
    c::Float64 #cost of giving cooperation
end

mutable struct AmbiguityModelProps
    θ::Vector{Symbol} #objective reputation according to Stern Judging
    rep::Matrix{Vector{Float64}} #matrix of priors about reputation of agent j according to agent i 
    p_truth::Float64 #probability of updating truthfully a prior
    p_update::Float64 #proability of randomly updating a prior
    p_new::Float64 #probability of adding a new prior 
    max_priors::Int64 #max number of priors stored by each agent
    p_evolve::Float64 #percentage of population that can change kind at each step
    p_mutation::Float64 #probability of having a random mutation
    b::Float64 #benefit of received cooperation
    c::Float64 #cost of giving cooperation
end

function model_step!(model) end

function conditional(donor::Agent, recipient::Agent, model)
    return :C
end

#model for testing Perfect Info functions
function make_test_model(N=2)
    props = ModelProps(
        Vector{Symbol}(undef, N),
        0.001, 2.0, 1.0
    )
    model = StandardABM(Agent;
        properties=props,
        scheduler=Schedulers.Randomly(),
        model_step! = model_step!
    )
    for _ in 1:N
        add_agent!(model; kind=:COND, C_given=0, C_received=0, 
                   payoff=0.0, strategy=:D)
    end
    model.θ .= :G
    return model
end
#model for testing noisy info functions
function make_noisy_info_model(N=2)
    props = NoisyInfoModelProps(
        Vector{Symbol}(undef, N),
        Matrix{Symbol}(undef, N, N),
        0.05, 0.02, 0.5, 0.001, 2.0, 1.0     
    )
    model = StandardABM(Agent;
        properties=props,
        scheduler=Schedulers.Randomly(),
        model_step! = model_step!
    )
    for _ in 1:N
        add_agent!(model; kind=:COND, C_given=0, C_received=0,
                   payoff=0.0, strategy=:D)
    end
    model.θ .= :G
    model.rep .= :G
    return model
end
#model for testing ambiguity model
function make_ambiguity_model(N=2)
    props = AmbiguityModelProps(
        fill(:G, 2),
        [ [1.0] for _ in 1:N, _ in 1:N ],
        0.5, 0.2, 0.1, 5,
        0.001, 0.01,
        2.0, 1.0
    )
      model = StandardABM(Agent;
        properties=props,
        scheduler=Schedulers.Randomly(),
        model_step! = model_step!
    )
    for _ in 1:N
        add_agent!(model; kind=:COND, C_given=0, C_received=0,
                   payoff=0.0, strategy=:D)
    end
    model.θ .= :G
    model.rep .= [1.0]
    return model
end