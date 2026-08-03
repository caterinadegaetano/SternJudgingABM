function noisy_conditional(donor::Agent, recipient::Agent, model)
    if model.rep[donor.id, recipient.id] == :G
        return :C
    else
        return :D
    end
end

#strategy according to the kind of agents

function noisy_strategy(donor::Agent, recipient::Agent, model)
if rand(abmrng(model))> model.p_error
    if donor.kind == :ALLD
        return :D
    elseif donor.kind == :ALLC
        return :C
    else
        return noisy_conditional(donor, recipient, model)
    end
else #implementation error
    if donor.kind == :ALLC || donor.kind == :ALLD
        return :D
    elseif donor.kind == :COND
        if noisy_conditional(donor, recipient, model) == :C
            return :D
        else
            return :C
        end
    end
end
end

#the gift game
function noisy_interact!(donor::Agent, recipient::Agent, model)
   donor.strategy = noisy_strategy(donor, recipient, model)
    
    if donor.strategy == :C
        donor.C_given += 1
        recipient.C_received += 1
    end
end
