 
function perfect_conditional(donor::Agent, recipient::Agent, model)
    if model.θ[recipient.id] == :G
        return :C
    else
        return :D
    end
end

function perfect_strategy(donor::Agent, recipient::Agent, model)
S=Set([:C, :D])
if rand(abmrng(model))> model.p_error
    if donor.kind == :ALLD
        return :D
    elseif donor.kind == :ALLC
        return :C
    else
        return perfect_conditional(donor, recipient, model)
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
function perfect_interact!(donor::Agent, recipient::Agent, model)
    action = perfect_strategy(donor, recipient, model)
    donor.strategy=action
    if action == :C
        donor.C_given += 1
        recipient.C_received += 1
    end
end

#step function at the agent level
function perfect_agent_step!(agent, model, interactions::Vector)
    all = collect(allagents(model))
    partner = rand(abmrng(model), all)
    while partner.id == agent.id
        partner = rand(abmrng(model), all)
    end
    push!(interactions, (agent.id, partner.id))
    perfect_interact!(agent, partner, model)
end

include("SharedFunctions.jl")

function perfect_model_step!(model)
interactions = Vector{Tuple{Int,Int}}() 
for ag in allagents(model) #previous rounds cooperation doesn't count
        ag.C_given = 0
        ag.C_received = 0
        ag.strategy = :D
    end
for ag in allagents(model) 
        perfect_agent_step!(ag, model, interactions)
    end
#reputation update at the objective level
for (donor_id, ag_id) in interactions
   donor = model[donor_id]
    ag = model[ag_id]
    rep_update!(donor, ag, model) 
end

#payoff computation

 for ag in allagents(model)
        payoff!(ag, model)
    end
 
#the evolution dynamic

all = collect(allagents(model))
#only a percentage of agents evolve
evolving = rand(abmrng(model), all, max(1, round(Int, model.p_evolve * length(all))))
for ag in evolving
others = [a for a in all if a.id != ag.id]
other_ag = rand(abmrng(model), others)
all_kinds = [:ALLC, :ALLD, :COND]
other_kinds = setdiff(all_kinds, [ag.kind])

p_imitation = 1 / (1 + exp(-5*(other_ag.payoff - ag.payoff ))) 
if rand(abmrng(model)) < model.p_mutation #random mutation
    ag.kind = rand(abmrng(model), other_kinds)
else
    if rand(abmrng(model)) < p_imitation #Fermi imitation rule used by Hilbe et al(2018)
        ag.kind = other_ag.kind
    end
end
end
end

include("DataFunctions.jl")

function run_perfect_info(steps=100000)


#defining the model
model = StandardABM(Agent; properties=properties, scheduler=Schedulers.Randomly(),  model_step! = perfect_model_step!)
#populating the model
for i in 1:N
    kind = :COND 
    add_agent!(model; kind=kind, C_given=0, C_received=0, payoff=0, strategy=:C)
end
#filling reputation parameters
model.θ .= :G
#finally run the model!
_, data_model = run!(model, steps;
   mdata = [pct_ALLC, pct_ALLD, pct_COND, pct_cooperation,
             mean_payoff_ALLC, mean_payoff_ALLD, mean_payoff_COND]
)


#and access the data
final_ALLC = data_model.pct_ALLC[end] #
final_ALLD = data_model.pct_ALLD[end]
final_COND = data_model.pct_COND[end]
final_coop = data_model.pct_cooperation[end]

#and plot the dynamics

# cooperation over time
p1 = plot(data_model.pct_cooperation, title="Cooperation over time(PERFECT INFO)", ylabel="pct C", xlabel="t")

# kinds over time
p2 = plot(data_model.pct_ALLC, label="Unconditional Cooperators")
plot!(p2, data_model.pct_ALLD, label="Unconditional Defectors")
plot!(p2, data_model.pct_COND, label="Stern Judging", title="Population composition over time(PERFECT INFO)")

# payoff by kind at final step (helpful to assess parameters)
p3 = plot(data_model.mean_payoff_ALLC, label="ALLC payoff")
plot!(p3, data_model.mean_payoff_ALLD, label="ALLD payoff")
plot!(p3, data_model.mean_payoff_COND, label="COND payoff", 
      title="Mean payoff by strategy over time(PERFECT INFO)")
#save data
savefig(p1, "outputs/Cooperation(PERFECT INFO).png")
savefig(p2, "outputs/Population(PERFECTINFO).png")
savefig(p3, "outputs/Payoff(PERFECTINFO).png")
summary_data = DataFrame(
    final_ALLC = [final_ALLC],
    final_ALLD = [final_ALLD],
    final_COND = [final_COND],
    final_coop = [final_coop]
)
CSV.write("outputs/perfect_summary.csv", summary_data)
end