
function misperception!(agent::Agent, donor::Agent, recipient::Agent, model)
#Observer sees the opposite of what the donor does
  actual_action = donor.strategy
  perceived_action = (actual_action == :C ? :D : :C) 

#and then applies SternJudging norm to it
if model.rep[agent.id, recipient.id] == :G && perceived_action == :C
         model.rep[agent.id, donor.id] = :G
    elseif model.rep[agent.id,recipient.id] == :B && perceived_action == :D
         model.rep[agent.id, donor.id]= :G
    else
         model.rep[agent.id, donor.id] = :B
    end
end

function noise!(agent::Agent, donor::Agent, recipient::Agent, model)
    #wrong application of SternJudging
    if model.rep[agent.id, recipient.id] == :G && donor.strategy == :C
         model.rep[agent.id, donor.id] = :B
    elseif model.rep[agent.id, recipient.id] == :B && donor.strategy == :D
         model.rep[agent.id, donor.id]= :B
    else
        model.rep[agent.id, donor.id] = :G
    end
end

#noisy update rule for subjective reputation
function noisy_update!(agent::Agent, donor::Agent, recipient::Agent, model)
    r=rand(abmrng(model))
    if r <model.p_misperception
        misperception!(agent, donor, recipient, model)
    
    elseif r <model.p_misperception + model.p_observe
        subj_rep_update!(agent, donor, recipient, model)
    end
end