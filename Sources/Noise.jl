
function misperception!(agent::Agent, donor::Agent, recipient::Agent, model)
  actual_action = donor.strategy
  perceived_action = (actual_action == :C ? :D : :C) 
#Observe sees the opposite of what the donor does
#and then applies SternJudging norm to it
if model.θ[recipient.id] == :G && perceived_action == :C
         model.rep[agent.id, donor.id] = :G
    elseif model.θ[recipient.id] == :B && perceived_action == :D
         model.rep[agent.id, donor.id]= :G
    else
         model.rep[agent.id, donor.id] = :B
    end
end

function noise!(agent::Agent, donor::Agent, recipient::Agent, model)
    #wrong application of SternJudging
    if model.θ[recipient.id] == :G && donor.strategy == :C
         model.rep[agent.id, donor.id] = :B
    elseif model.θ[recipient.id] == :B && donor.strategy == :D
         model.rep[agent.id, donor.id]= :B
    else
        model.rep[agent.id, donor.id] = :G
    end
end

#noisy update rule for subjective reputation
function noisy_update!(agent::Agent, donor::Agent, recipient::Agent, model)
    if rand(abmrng(model))<model.p_misperception
        misperception!(agent, donor, recipient, model)
    end
    if rand(abmrng(model))<model.p_noise
        noise!(agent, donor, recipient, model)
    end
    if rand(abmrng(model))< model.p_observe
        model.rep[agent.id, donor.id]=model.θ[donor.id]
    end
end