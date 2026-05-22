#testing utility
@testset "utility function" begin
    @test utility(:C, :G) == 2
    @test utility(:D, :B) == 1
    @test utility(:D, :G) == -1
    @test utility(:C, :B) == 0
end

#testing Maxmin_utility
@testset "maxmin_utility" begin
    
    # minimal model 
    model = make_ambiguity_model(2)
    agents = collect(allagents(model))
    agent = agents[1]
    donor = agents[2]
    donor = add_agent!(model; kind=:COND, C_given=0, C_received=0, payoff=0.0, strategy=:D)
    recipient = add_agent!(model; kind=:COND, C_given=0, C_received=0, payoff=0.0, strategy=:D)
    model.θ .= :G

    # with p=1.0 (certain good): minimum = 1.0*2 + 0.0*0 = 2 for C
    @testset "certain good reputation" begin
        model.rep[donor.id, recipient.id] = [1.0]
        @test maxmin_utility(:C, donor, recipient, model) == 2.0
        @test maxmin_utility(:D, donor, recipient, model) == -1.0
    end

    # with p=0.0 (certain bad): minimum = 0.0*2 + 1.0*0 = 0 for C
    @testset "certain bad reputation" begin
        model.rep[donor.id, recipient.id] = [0.0]
        @test maxmin_utility(:C, donor, recipient, model) == 0.0
        @test maxmin_utility(:D, donor, recipient, model) == 1.0
    end

    # with multiple priors [0.2, 0.8]: minimum is at p=0.2
    # min for C: 0.2*2 + 0.8*0 = 0.4
    # min for D: 0.2*(-1) + 0.8*1 = 0.6
    @testset "ambiguous reputation - multiple priors" begin
        model.rep[donor.id, recipient.id] = [0.2, 0.8]
        @test maxmin_utility(:C, donor, recipient, model) ≈ 0.4
        @test maxmin_utility(:D, donor, recipient, model) ≈ 0.6
    end

    # with multiple priors, maxmin should pick the minimum not the average
    # [0.1, 0.9]: min for C is at p=0.1 → 0.1*2 + 0.9*0 = 0.2
    # average would give 0.5*2 = 1.0 — if test passes it confirms maxmin not expected utility
    @testset "maxmin picks minimum" begin
        model.rep[donor.id, recipient.id] = [0.1, 0.9]
        @test maxmin_utility(:C, donor, recipient, model) ≈ 0.2
        @test maxmin_utility(:C, donor, recipient, model) != 1.0  # would be expected utility
    end

    # single prior p=0.5
    # C: 0.5*2 + 0.5*0 = 1.0
    # D: 0.5*(-1) + 0.5*1 = 0.0
    @testset "single prior p=0.5" begin
        model.rep[donor.id, recipient.id] = [0.5]
        @test maxmin_utility(:C, donor, recipient, model) ≈ 1.0
        @test maxmin_utility(:D, donor, recipient, model) ≈ 0.0
    end
end

#testing Conditional 
@testset "Conditional" begin
@testset "conditional: certain good reputation prefers C" begin
    # model for check
    props = AmbiguityModelProps(fill(:G, 2), [[1.0] for _ in 1:2, _ in 1:2],
                      0.5, 0.2, 0.1, 5, 0.001, 0.01, 2.0, 1.0)
    model = StandardABM(Agent; properties=props, scheduler=Schedulers.Randomly(),
                        model_step!=model_step!)
    a1 = add_agent!(model; kind=:COND, C_given=0, C_received=0, payoff=0.0, strategy=:D)
    a2 = add_agent!(model; kind=:COND, C_given=0, C_received=0, payoff=0.0, strategy=:D)
    model.rep[a1.id, a2.id] = [1.0]  # certain good reputation
    # with p=1 (certain good), maxmin utility of C should be 2
    @test maxmin_utility(:C, a1, a2, model) == 2.0
    # and should prefer C over D
    @test conditional(a1, a2, model) == :C
end

@testset "conditional: certain bad reputation prefers D" begin
    props = AmbiguityModelProps(fill(:G, 2), [[1.0] for _ in 1:2, _ in 1:2],
                       0.5, 0.2, 0.1, 5, 0.001, 0.01, 2.0, 1.0)
    model = StandardABM(Agent; properties=props, scheduler=Schedulers.Randomly(),
                        model_step!=model_step!)
    a1 = add_agent!(model; kind=:COND, C_given=0, C_received=0, payoff=0.0, strategy=:D)
    a2 = add_agent!(model; kind=:COND, C_given=0, C_received=0, payoff=0.0, strategy=:D)
    model.rep[a1.id, a2.id] = [0.0]  # certain bad reputation
    # with p=0 (certain bad), should prefer D
    @test conditional(a1, a2, model) == :D
end
end

@testset "true_update" begin
    
    N_test = 2
    props = AmbiguityModelProps(Vector{Symbol}(undef, N_test), 0.1, 1.5, 1.0)
    model = StandardABM(Agent; properties=props,
                        scheduler=Schedulers.Randomly(),
                        model_step! = model_step!)
    donor = add_agent!(model; kind=:COND, C_given=0, C_received=0, payoff=0.0, strategy=:D)

    # if donor has good reputation, true_update should return 1.0 regardless of prior
    @testset "good reputation" begin
        model.θ[donor.id] = :G
        @test true_update(0.5, donor, model) == 1.0
        @test true_update(0.0, donor, model) == 1.0  # prior doesn't matter
        @test true_update(1.0, donor, model) == 1.0
    end

    # if donor has bad reputation, true_update should return 0.0 regardless of prior
    @testset "bad reputation" begin
        model.θ[donor.id] = :B
        @test true_update(0.5, donor, model) == 0.0
        @test true_update(0.0, donor, model) == 0.0
        @test true_update(1.0, donor, model) == 0.0
    end
end

@testset "add_prior!" begin

    N_test = 2
    model = make_test_model()
    agent = add_agent!(model; kind=:COND, C_given=0, C_received=0, payoff=0.0, strategy=:D)

    # good reputation should return 0.7
    @testset "good reputation" begin
        model.θ[agent.id] = :G
        @test add_prior!(agent, model) == 0.7
    end

    # bad reputation should return 0.3
    @testset "bad reputation" begin
        model.θ[agent.id] = :B
        @test add_prior!(agent, model) == 0.3
    end
end

@testset "mutate_prior" begin
    
    # result should always be within [0.01, 0.99]
    @testset "stays within bounds" begin
        for p in [0.01, 0.1, 0.5, 0.9, 0.99]
            for _ in 1:100  # test many times since it is random
                result = mutate_prior(p)
                @test result >= 0.01
                @test result <= 0.99
            end
        end
    end

    # result should be close to original value (within mutation range 0.1)
    @testset "stays close to original" begin
        for _ in 1:100
            p = rand() * 0.8 + 0.1  # avoid edges, sample from [0.1, 0.9]
            result = mutate_prior(p)
            @test abs(result - p) <= 0.1 + 1e-10  # mutation is at most 0.2*0.5=0.1
        end
    end

    # edge case: very low prior should not go below 0.01
    @testset "lower bound" begin
        for _ in 1:100
            @test mutate_prior(0.01) >= 0.01
        end
    end

    # edge case: very high prior should not go above 0.99
    @testset "upper bound" begin
        for _ in 1:100
            @test mutate_prior(0.99) <= 0.99
        end
    end
end

@testset "update_priors!" begin

    model = make_ambiguity_model()
    observer = add_agent!(model; kind=:COND, C_given=0, C_received=0, payoff=0.0, strategy=:D)
    donor = add_agent!(model; kind=:COND, C_given=0, C_received=0, payoff=0.0, strategy=:D)
    model.θ .= :G

    # result should always stay within [0.01, 0.99]
    @testset "priors always valid" begin
        for _ in 1:100
            model.rep[observer.id, donor.id] = [rand() * 0.8 + 0.1]
            update_priors!(observer, donor, model)
            @test all(p -> 0.01 <= p <= 0.99, model.rep[observer.id, donor.id])
        end
    end

    # number of priors should never exceed max_priors
    @testset "never exceeds max_priors" begin
        model.rep[observer.id, donor.id] = [0.5]
        for _ in 1:200
            update_priors!(observer, donor, model)
            @test length(model.rep[observer.id, donor.id]) <= model.max_priors
        end
    end

    # truthful update: if p_truth=1.0, priors should always become 1.0 or 0.0
    @testset "truthful update when p_truth=1" begin
        model.p_truth = 1.0
        model.θ[donor.id] = :G
        model.rep[observer.id, donor.id] = [0.3, 0.5, 0.7]
        update_priors!(observer, donor, model)
        @test all(p -> p == 1.0, model.rep[observer.id, donor.id])
        
        model.θ[donor.id] = :B
        model.rep[observer.id, donor.id] = [0.3, 0.5, 0.7]
        update_priors!(observer, donor, model)
        @test all(p -> p == 0.0, model.rep[observer.id, donor.id])
    end
end