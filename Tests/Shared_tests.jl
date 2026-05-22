
#testing Objective Reputation update
@testset "reputation update" begin
@testset "rep_update: cooperation towards G gives G reputation" begin 
    model =  make_test_model()
     agents = collect(allagents(model))
    donor = agents[1]
    recipient = agents[2]
 model.θ[recipient.id] = :G
    donor.strategy = :C
    rep_update!(donor, recipient, model)
    @test model.θ[donor.id] == :G
end

@testset "rep_update: cooperation towards B gives B reputation" begin 
    model =  make_test_model()
    agents = collect(allagents(model))
    donor = agents[1]
    recipient = agents[2]
 model.θ[recipient.id] = :B
    donor.strategy = :C
    rep_update!(donor, recipient, model)
    @test model.θ[donor.id] == :B
end
@testset "rep_update: defection towards B gives G reputation" begin 
    model =  make_test_model()
    agents = collect(allagents(model))
    donor = agents[1]
    recipient = agents[2]
 model.θ[recipient.id] = :B
    donor.strategy = :D
    rep_update!(donor, recipient, model)
    @test model.θ[donor.id] == :G
end

@testset "rep_update: defection towards G gives B reputation" begin 

    model =  make_test_model()
    agents = collect(allagents(model))
    donor = agents[1]
    recipient = agents[2]
 model.θ[recipient.id] = :G
    donor.strategy = :D
    rep_update!(donor, recipient, model)
    @test model.θ[donor.id] == :B
end
end

#testing strategy function only for ALLC ALLD (conditional differs in models)
@testset "strategy - shared branches" begin
    model = make_test_model()
    agents = collect(allagents(model))
    donor = agents[1]
    recipient = agents[2]

    # ALLD always defects regardless of recipient reputation
    @testset "ALLD always defects" begin
        donor.kind = :ALLD
        model.θ[recipient.id] = :G
        @test strategy(donor, recipient, model) == :D
        model.θ[recipient.id] = :B
        @test strategy(donor, recipient, model) == :D
    end

    # ALLC always cooperates regardless of recipient reputation
    @testset "ALLC always cooperates" begin
        donor.kind = :ALLC
        model.θ[recipient.id] = :G
        @test strategy(donor, recipient, model) == :C
        model.θ[recipient.id] = :B
        @test strategy(donor, recipient, model) == :C
    end
end

#testing interact

@testset "interact!" begin
    model = make_test_model()
    agents = collect(allagents(model))
    donor = agents[1]
    recipient = agents[2]

    # cooperation case: ALLC donor should increment C_given and C_received
    @testset "cooperation updates counts" begin
        donor.kind = :ALLC
        donor.C_given = 0
        recipient.C_received = 0
        interact!(donor, recipient, model)
        @test donor.C_given == 1
        @test recipient.C_received == 1
        @test donor.strategy == :C
    end

    # defection case: ALLD donor should not change counts
    @testset "defection does not update counts" begin
        donor.kind = :ALLD
        donor.C_given = 0
        recipient.C_received = 0
        interact!(donor, recipient, model)
        @test donor.C_given == 0
        @test recipient.C_received == 0
        @test donor.strategy == :D
    end

    # recipient counts should not be affected by their own action
    @testset "recipient C_given unchanged" begin
        donor.kind = :ALLC
        recipient.C_given = 0
        interact!(donor, recipient, model)
        @test recipient.C_given == 0
    end

    # donor counts should not be affected by receiving
    @testset "donor C_received unchanged" begin
        donor.kind = :ALLD
        donor.C_received = 0
        interact!(donor, recipient, model)
        @test donor.C_received == 0
    end
end

#testing payoff

@testset "payoff!" begin
    model = make_test_model()
    agent = first(allagents(model))

    # basic calculation: b*C_received - c*C_given = 2*3 - 1*2 = 4
    @testset "correct calculation" begin
        agent.C_received = 3
        agent.C_given = 2
        payoff!(agent, model)
        @test agent.payoff ≈ 4
    end

    # no interactions: payoff should be 0
    @testset "zero payoff with no interactions" begin
        agent.C_received = 0
        agent.C_given = 0
        payoff!(agent, model)
        @test agent.payoff == 0.0
    end

    # pure receiver: only received cooperation, never gave
    @testset "positive payoff as pure receiver" begin
        agent.C_received = 3
        agent.C_given = 0
        payoff!(agent, model)
        @test agent.payoff ≈ model.b * 3
    end

    # pure donor: only gave cooperation, never received
    @testset "negative payoff as pure donor" begin
        agent.C_received = 0
        agent.C_given = 3
        payoff!(agent, model)
        @test agent.payoff ≈ -model.c * 3
    end
end

#testing interact
@testset "agent_step!" begin
    model = make_test_model(5)  # need at least 2 agents
    agents = collect(allagents(model))
    agent = agents[1]

    # agent_step! should add exactly one interaction to the vector
    @testset "adds one interaction" begin
        interactions = Vector{Tuple{Int,Int}}()
        agent_step!(agent, model, interactions)
        @test length(interactions) == 1
    end

    # the interaction should involve the agent as donor
    @testset "agent is the donor" begin
        interactions = Vector{Tuple{Int,Int}}()
        agent_step!(agent, model, interactions)
        donor_id, _ = interactions[1]
        @test donor_id == agent.id
    end

    # agent should never interact with itself
    @testset "agent never partners with itself" begin
        interactions = Vector{Tuple{Int,Int}}()
        for _ in 1:100  # repeat to cover random cases
            empty!(interactions)
            agent_step!(agent, model, interactions)
            _, partner_id = interactions[1]
            @test partner_id != agent.id
        end
    end

    # partner id should be a valid agent in the model
    @testset "partner is a valid agent" begin
        interactions = Vector{Tuple{Int,Int}}()
        agent_step!(agent, model, interactions)
        _, partner_id = interactions[1]
        valid_ids = [ag.id for ag in allagents(model)]
        @test partner_id in valid_ids
    end

    # calling agent_step! should trigger interact! 
    # so C_given or strategy should be updated
    @testset "interact! is called" begin
        agent.kind = :ALLC
        agent.C_given = 0
        interactions = Vector{Tuple{Int,Int}}()
        agent_step!(agent, model, interactions)
        @test agent.C_given == 1  # ALLC always cooperates
        @test agent.strategy == :C
    end
end