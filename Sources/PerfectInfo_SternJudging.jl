 
include("PI_GiftGame.jl")

include("SharedFunctions.jl")


#step function at the model level
function perfect_model_step!(model)
for ag in allagents(model) #previous rounds cooperation doesn't count
        ag.C_given = 0
        ag.C_received = 0
        ag.strategy = :D
    end

# random donor
donor=rand(abmrng(model), allagents(model))

#random recipient forced to be different from the donor
all = collect(allagents(model))
recipient = rand(abmrng(model), all)
    while recipient.id == donor.id
        recipient = rand(abmrng(model), all)
    end

#one round of gift game per step
  perfect_interact!(donor, recipient, model)

#tracking cooperation
if donor.strategy == :C
    model.coop_window_count += 1
end

if abmtime(model) % model.coop_window == 0
    push!(model.coop_window_log, model.coop_window_count / model.coop_window)
    model.coop_window_count = 0
end


#objective reputation update
    rep_update!(donor, recipient, model)

#payoff computation of donor and recipient of the gift game

payoff!(donor, model)
payoff!(recipient, model)

#update of the times an agent has played
donor.n_played+=1
recipient.n_played+=1

#update of the average payoff of the playing agents
av_payoff!(donor)
av_payoff!(recipient)


#the evolution dynamic

all = collect(allagents(model))
#evolution happens every n steps
  
#only a percentage of agents evolve
  evolving = rand(abmrng(model), all, max(1, round(Int, model.p_evolve * length(all))))
    for ag in evolving
       evolution_step!(ag, model)
    end
  
end

include("DataFunctions.jl")

#the running funtion for the perfect info model
function run_perfect_info(steps=1.0e7)

#defining the model
model = StandardABM(Agent; properties=properties, scheduler=Schedulers.Randomly(),  model_step! = perfect_model_step!)
#populating the model with conditional agents
for i in 1:N
    add_agent!(model; kind= :COND, C_given=0, C_received=0, n_played=0, payoff=0.0, av_payoff=0.0, strategy=:C)
end
#filling reputation parameters: everyone starts with a good reputation
model.θ .= :G
#finally run the model!
_, data_model = run!(model, steps;
   mdata = [pct_ALLC, pct_ALLD, pct_COND, pct_cooperation,
             mean_payoff_ALLC, mean_payoff_ALLD, mean_payoff_COND]
)


#and access the data
final_ALLC = mean(data_model.pct_ALLC[end-999:end])
final_ALLD = mean(data_model.pct_ALLD[end-999:end])
final_COND = mean(data_model.pct_COND[end-999:end])
final_coop = mean(data_model.pct_cooperation[end-999:end])

#and plot the dynamics

# cooperation over time
p1 = plot(model.coop_window_log,
    title = "Cooperation rate over time (windowed, PERFECT INFO)",
    xlabel = "block (each = $(properties.coop_window) steps)",
    ylabel = "cooperation rate")

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
    av_final_ALLC = [final_ALLC],
    av_final_ALLD = [final_ALLD],
    av_final_COND = [final_COND],
    av_final_coop = [final_coop]
)
CSV.write("outputs/perfect_summary.csv", summary_data)
end