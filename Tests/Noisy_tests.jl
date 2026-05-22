@testset "misperception!" begin
    model = make_noisy_info_model(3)
    agents = collect(allagents(model))
    agent = agents[1]
    donor = agents[2]
    recipient = agents[3]

    # misperception flips C to D — so C toward G recipient is seen as D toward G
    # D toward G → bad reputation
    @testset "C flipped to D toward G gives B reputation" begin
        model.θ[recipient.id] = :G
        donor.strategy = :C  # will be perceived as D
        misperception!(agent, donor, recipient, model)
        @test model.rep[agent.id, donor.id] == :B
    end

    # misperception flips D to C — so D toward B recipient is seen as C toward B
    # C toward B → bad reputation
    @testset "D flipped to C toward B gives B reputation" begin
        model.θ[recipient.id] = :B
        donor.strategy = :D  # will be perceived as C
        misperception!(agent, donor, recipient, model)
        @test model.rep[agent.id, donor.id] == :B
    end

    # misperception flips D to C — so D toward G recipient is seen as C toward G
    # C toward G → good reputation
    @testset "D flipped to C toward G gives G reputation" begin
        model.θ[recipient.id] = :G
        donor.strategy = :D  # will be perceived as C
        misperception!(agent, donor, recipient, model)
        @test model.rep[agent.id, donor.id] == :G
    end

    # misperception flips C to D — so C toward B recipient is seen as D toward B
    # D toward B → good reputation
    @testset "C flipped to D toward B gives G reputation" begin
        model.θ[recipient.id] = :B
        donor.strategy = :C  # will be perceived as D
        misperception!(agent, donor, recipient, model)
        @test model.rep[agent.id, donor.id] == :G
    end
end

@testset "noise!" begin
    model = make_noisy_info_model(3)
    agents = collect(allagents(model))
    agent = agents[1]
    donor = agents[2]
    recipient = agents[3]

    # noise inverts the outcome — C toward G should give G but noise gives B
    @testset "C toward G gives B under noise" begin
        model.θ[recipient.id] = :G
        donor.strategy = :C
        noise!(agent, donor, recipient, model)
        @test model.rep[agent.id, donor.id] == :B
    end

    # noise inverts — D toward B should give G but noise gives B
    @testset "D toward B gives B under noise" begin
        model.θ[recipient.id] = :B
        donor.strategy = :D
        noise!(agent, donor, recipient, model)
        @test model.rep[agent.id, donor.id] == :B
    end

    # noise inverts — D toward G should give B but noise gives G
    @testset "D toward G gives G under noise" begin
        model.θ[recipient.id] = :G
        donor.strategy = :D
        noise!(agent, donor, recipient, model)
        @test model.rep[agent.id, donor.id] == :G
    end

    # noise inverts — C toward B should give B but noise gives G
    @testset "C toward B gives G under noise" begin
        model.θ[recipient.id] = :B
        donor.strategy = :C
        noise!(agent, donor, recipient, model)
        @test model.rep[agent.id, donor.id] == :G
    end
end

@testset "noisy_update!" begin
    model = make_noisy_info_model(3)
    agents = collect(allagents(model))
    agent = agents[1]
    donor = agents[2]
    recipient = agents[3]

    # result should always be a valid reputation symbol
    @testset "always returns valid symbol" begin
        for _ in 1:100
            noisy_update!(agent, donor, recipient, model)
            @test model.rep[agent.id, donor.id] in [:G, :B]
        end
    end

    # with p_observe=1.0 the result should always match objective reputation
    @testset "observe always copies objective reputation when p_observe=1" begin
        model.p_misperception = 0.0
        model.p_noise = 0.0
        model.p_observe = 1.0
        model.θ[donor.id] = :G
        noisy_update!(agent, donor, recipient, model)
        @test model.rep[agent.id, donor.id] == :G

        model.θ[donor.id] = :B
        noisy_update!(agent, donor, recipient, model)
        @test model.rep[agent.id, donor.id] == :B
    end
end