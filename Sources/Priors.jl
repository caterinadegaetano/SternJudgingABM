#update rules for reputation priors
function true_update!(p::Float64, agent::Agent, donor::Agent, recipient::Agent, model)
    if mean(model.rep[agent.id, recipient.id]) ≥ 0.5 && donor.strategy==:C
         p=0.9
     elseif mean(model.rep[agent.id, recipient.id]) < 0.5 && donor.strategy==:D
         p=0.9
     else  p= 0.1
     end
end


function add_prior!(agent::Agent, model)
return prior=0.5
end

 
function misperception_update!(p::Float64, agent::Agent, donor::Agent, recipient::Agent, model)
#Observer sees the opposite of what the donor does
    actual_action = donor.strategy
    perceived_action = (actual_action == :C ? :D : :C) 

#and then applies SternJudging norm to it
    if mean(model.rep[agent.id, recipient.id]) ≥ 0.5 && perceived_action==:C
         p=0.9
     elseif mean(model.rep[agent.id, recipient.id]) < 0.5 && perceived_action==:D
         p=0.9
     else  p= 0.1
    end
end


function update_priors!(agent::Agent, donor::Agent, recipient::Agent, model)
    i = agent.id
    j = donor.id
    r = rand(abmrng(model))
    p_random=rand(1:length(model.rep[i,j]))
    p=model.rep[i, j][p_random]
    # Truthful update
    if r < model.p_observe

      model.rep[i, j][p_random]  = true_update!(p, agent, donor, recipient, model)
    
    
    #Noisy update
    elseif r < model.p_observe + model.p_misperception
        
      model.rep[i, j][p_random] = misperception_update!(p, agent, donor, recipient, model)


    # Adding a new prior when there is no new observation
    else 

        if length(model.rep[i, j]) < model.max_priors
            push!(model.rep[i, j], add_prior!(agent, model))
        else #if max of priors reached, change an existing one
            model.rep[i, j][p_random] = add_prior!(agent, model)
        end
    
    end

end