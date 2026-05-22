using Test
using Agents
using Statistics
#general model
include("Set_up.jl")

#testing shared functions
include("../Sources/SharedFunctions.jl")
include("Shared_tests.jl")

#testing PerfectInfo specific functions (just conditional)
function conditional(donor::Agent, recipient::Agent, model)
if model.θ[recipient.id]==:G 
    :C
elseif model.θ[recipient.id]==:B 
    :D
end
end
@testset "conditional (perfect info)" begin
    model = make_test_model()
    agents = collect(allagents(model))
    donor = agents[1]
    recipient = agents[2]

    # good recipient cooperate
    @testset "cooperates with good recipient" begin
        model.θ[recipient.id] = :G
        @test conditional(donor, recipient, model) == :C
    end

    # bad recipient defect
    @testset "defects against bad recipient" begin
        model.θ[recipient.id] = :B
        @test conditional(donor, recipient, model) == :D
    end
end

#testing strategy in the conditional branch
@testset "strategy - COND branch (perfect info)" begin
    model = make_test_model()
    agents = collect(allagents(model))
    donor = agents[1]
    recipient = agents[2]
    donor.kind = :COND

    @testset "cooperates with good recipient" begin
        model.θ[recipient.id] = :G
        @test strategy(donor, recipient, model) == :C
    end

    @testset "defects against bad recipient" begin
        model.θ[recipient.id] = :B
        @test strategy(donor, recipient, model) == :D
    end
end


#testing NoisyInfo specific functions
#conditional
function conditional(donor::Agent, recipient::Agent, model)
    i = donor.id
    j = recipient.id

if  model.rep[i, j]==:G 
    :C
elseif  model.rep[i, j]==:B 
    :D
end
end

# test conditional
@testset "conditional (noisy info)" begin
    model = make_noisy_info_model()  # needs its own setup
    agents = collect(allagents(model))
    donor = agents[1]
    recipient = agents[2]

    # good subjective reputation → cooperate
    @testset "cooperates with good subjective reputation" begin
        model.rep[donor.id, recipient.id] = :G
        @test conditional(donor, recipient, model) == :C
    end

    # bad subjective reputation → defect
    @testset "defects with bad subjective reputation" begin
        model.rep[donor.id, recipient.id] = :B
        @test conditional(donor, recipient, model) == :D
    end

    # key difference from perfect info: two agents can have
    # different subjective reputations of the same recipient
    @testset "subjective reputation is agent-specific" begin
        model.rep[donor.id, recipient.id] = :G
        model.rep[recipient.id, donor.id] = :B  # recipient sees donor differently
        @test conditional(donor, recipient, model) == :C
        @test conditional(recipient, donor, model) == :D
    end
end
include("../Sources/Noise.jl")
include("Noisy_tests.jl")

#testing ambiguity specific functions
include("../Sources/Maxmin_utility.jl")
include("../Sources/Priors.jl")
include("Ambiguity_tests.jl")