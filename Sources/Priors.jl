#update rules for reputation priors
function true_update(p::Float64, donor::Agent, model)
    return model.θ[donor.id] == :G ? 1.0 : 0.0
end


function add_prior!(agent::Agent, model)
    return model.θ[agent.id] == :G ? 0.7 : 0.3
end

 
function mutate_prior(p::Float64)
    q = p+ 0.2*(rand() - 0.5)
   return clamp(q, 0.01, 0.99)
    
end


function update_priors!(agent::Agent, donor::Agent, model)
    i = agent.id
    j = donor.id
    r = rand(abmrng(model))

    # Truthful update
    if r < model.p_truth
        model.rep[i, j] = [true_update(p, donor, model) for p in model.rep[i, j]]
        return
    end

    # Adding a new prior
    if r < model.p_truth + model.p_update
        if length(model.rep[i, j]) < model.max_priors
            push!(model.rep[i, j], add_prior!(agent, model))
        else #if max of priors reached, change an existing one
            idx = rand(1:length(model.rep[i, j]))
            model.rep[i, j][idx] = add_prior!(agent, model)
        end
        return
    end

    # Changing an existing prior
    idx = rand(1:length(model.rep[i, j]))
    model.rep[i, j][idx] = mutate_prior(model.rep[i, j][idx])
end