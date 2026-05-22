#creating the agent type
@agent struct Agent(NoSpaceAgent)
    kind::Symbol #whether the agent is ALLC, ALLD, or COND
    C_given::Int64 #whether in present step the agent cooperate
    C_received::Int64 #how many donors in present cooperate with the agent
    payoff::Float64 #payoff of present step
    strategy::Symbol #strategy of present step
end

#number of agents
N = 100