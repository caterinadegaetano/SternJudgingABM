

#update rule for objective reputation
function rep_update!(donor::Agent, recipient::Agent, model)
    if model.θ[recipient.id]==:G  && donor.strategy==:C
    model.θ[donor.id]=:G
elseif model.θ[recipient.id]==:B && donor.strategy==:D
     model.θ[donor.id]=:G
else  model.θ[donor.id]=:B
end
end

function subj_rep_update!(agent::Agent, donor::Agent, recipient::Agent, model)
     if model.rep[agent.id, recipient.id]==:G  && donor.strategy==:C
         model.rep[agent.id, donor.id]=:G
     elseif model.rep[agent.id, recipient.id]==:B && donor.strategy==:D
         model.rep[agent.id, donor.id]=:G
     else  model.rep[agent.id, donor.id]=:B
     end
end

#payoff function
function payoff!(agent::Agent, model)
 agent.payoff=model.b*agent.C_received - model.c*agent.C_given
end

#average payoff function
function av_payoff!(agent::Agent)
agent.av_payoff+= (agent.payoff-agent.av_payoff)/agent.n_played
end
#evolution step function
function evolution_step!(ag::Agent, model)
all = collect(allagents(model))
others = [a for a in all if a.id != ag.id]
other_ag = rand(abmrng(model), others)
all_kinds = [:ALLC, :ALLD, :COND]
other_kinds = setdiff(all_kinds, [ag.kind])
r=rand(abmrng(model))
p_imitation = 1 / (1 + exp(-1*(other_ag.av_payoff - ag.av_payoff ))) 

 if r < model.p_mutation #random mutation
    ag.kind = rand(abmrng(model), other_kinds)
    ag.av_payoff = 0.0
    ag.n_played = 0
 elseif abmtime(model) % model.n_evolve == 0
    if ag.n_played >= 13 && other_ag.n_played >= 13 #impose that the Fermi rule applies only to av_payoff statistically significant
        push!(model.comparison_n_played_log, (ag.n_played, other_ag.n_played))
        if r < p_imitation + model.p_mutation #Fermi imitation rule 
        ag.kind = other_ag.kind 
        ag.av_payoff = 0.0
        ag.n_played = 0
        end
    end
 end

end