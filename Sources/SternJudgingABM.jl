module SternJudgingABM

using Agents
using Plots
using StatsPlots
using CSV
using Statistics
using DataFrames

#Agent and Model structs
include("AgentStruct.jl")
include("ModelStruct.jl")
#Functions for the model
include("SharedFunctions.jl")
include("DataFunctions.jl")
include("Maxmin_utility.jl")
include("Noise.jl")
include("Priors.jl")
#Model with perfect information
include("PerfectInfo_SternJudging.jl")
#Model with noisy information
include("NoisyInfo_SternJudging.jl")
#Model with ambiguity averse agents
include("Ambiguity_SternJudging.jl")

function run_all(steps=100000)
    println("Running Perfect Info model")
    data_perfect = run_perfect_info(steps)
    
    println("Running Noisy Info model")
    data_noisy = run_noisy_info(steps)
    
    println("Running Ambiguity model")
    data_ambiguity = run_ambiguity(steps)
    
    return data_perfect, data_noisy, data_ambiguity
end

export run_all, run_perfect_info, run_noisy_info, run_ambiguity

end
