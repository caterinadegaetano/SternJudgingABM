#utility function
function utility(strategy, θ)
if θ==:G  && strategy==:C
    2
elseif θ==:B && strategy==:D
    1
elseif θ==:G && strategy==:D
    -1
else 0
end
end

#utility function with ambiguity  
function maxmin_utility(a::Symbol, donor::Agent, recipient::Agent, model)
i=donor.id
j=recipient.id
p= model.rep[i, j]
     return minimum(
        p_k * utility(a, :G) + (1 - p_k) * utility(a, :B)
        for p_k in p
    )
end

function ambiguity_conditional(donor::Agent, recipient::Agent, model)
    actions = [:C, :D]

    utilities = [
        maxmin_utility(a, donor, recipient, model)
        for a in actions
    ]

    return actions[argmax(utilities)]
end

#stratgey according to the kind of agents

function ambiguity_strategy(donor::Agent, recipient::Agent, model)
    S=Set([:C,:D])
 if rand(abmrng(model))> model.p_error
    if donor.kind == :ALLD
        return :D
    elseif donor.kind == :ALLC
        return :C
    else
        return ambiguity_conditional(donor, recipient, model)
    end
else
    if donor.kind == :ALLD
        return :C
    elseif donor.kind == :ALLC
        return :D
    else
        return rand(S)
    end
end
end

#the gift game
function ambiguity_interact!(donor::Agent, recipient::Agent, model)
    action = ambiguity_strategy(donor, recipient, model)
    donor.strategy=action
    if action == :C
        donor.C_given += 1
        recipient.C_received += 1
    end
end