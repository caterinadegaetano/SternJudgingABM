

#update rule for objective reputation
function rep_update!(donor::Agent, recipient::Agent, model)
    if model.θ[recipient.id]==:G  && donor.strategy==:C
    model.θ[donor.id]=:G
elseif model.θ[recipient.id]==:B && donor.strategy==:D
     model.θ[donor.id]=:G
else  model.θ[donor.id]=:B
end
end

#payoff function
function payoff!(agent::Agent, model)
 agent.payoff=model.b*agent.C_received - model.c*agent.C_given
end

