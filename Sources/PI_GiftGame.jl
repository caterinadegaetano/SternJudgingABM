#defining the strategy of conditional players
function perfect_conditional(donor::Agent, recipient::Agent, model)
    if model.θ[recipient.id] == :G
        return :C
    else
        return :D
    end
end

#strategy choice with implementation error
function perfect_strategy(donor::Agent, recipient::Agent, model)
if rand(abmrng(model))> model.p_error
    if donor.kind == :ALLD
        return :D
    elseif donor.kind == :ALLC
        return :C
    else
        return perfect_conditional(donor, recipient, model)
    end
else #unilateral implementation error: when intended cooperation defect instead
    return :D
    end
end


#the gift game
function perfect_interact!(donor::Agent, recipient::Agent, model)
    action = perfect_strategy(donor, recipient, model)
    donor.strategy=action
    if action == :C
        donor.C_given += 1
        recipient.C_received += 1
    end
end