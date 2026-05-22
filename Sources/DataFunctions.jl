#defining the quantities of the simulation i want to track
#finale percentage of kinds
function pct_ALLC(model)
    kinds = [ag.kind for ag in allagents(model)]
    return count(==(:ALLC), kinds) / length(kinds)
end

function pct_ALLD(model)
    kinds = [ag.kind for ag in allagents(model)]
    return count(==(:ALLD), kinds) / length(kinds)
end

function pct_COND(model)
    kinds = [ag.kind for ag in allagents(model)]
    return count(==(:COND), kinds) / length(kinds)
end
#final percentage of cooperation
function pct_cooperation(model)
    total_given = sum(ag.C_given for ag in allagents(model))
    return total_given / nagents(model)
end
#payoff by kind
function mean_payoff_ALLC(model)
    agents = [ag for ag in allagents(model) if ag.kind == :ALLC]
    isempty(agents) && return 0.0
    return mean(ag.payoff for ag in agents)
end

function mean_payoff_ALLD(model)
    agents = [ag for ag in allagents(model) if ag.kind == :ALLD]
    isempty(agents) && return 0.0
    return mean(ag.payoff for ag in agents)
end

function mean_payoff_COND(model)
    agents = [ag for ag in allagents(model) if ag.kind == :COND]
    isempty(agents) && return 0.0
    return mean(ag.payoff for ag in agents)
end