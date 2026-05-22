# SternJudgingABM

An Agent-Based Model in Julia implementing the **Stern Judging** norm of indirect reciprocity under different information conditions.

## Overview

This project studies the evolution of cooperation in populations of agents playing a repeated gift game. Agents can adopt different behavioral strategies and update reputations according to the Stern Judging social norm.

The model compares three environments:

* **Perfect Information** — agents observe reputations accurately.
* **Noisy Information** — observations and reputation updates may contain errors.
* **Ambiguity Aversion** — agents hold multiple priors about reputations and use a maxmin utility rule.

The model also includes an **action error**, meaning agents may fail to execute their intended action.

## Agent Types

Agents can evolve between three strategies:

* `ALLC` — unconditional cooperators
* `ALLD` — unconditional defectors
* `COND` — conditional cooperators following Stern Judging

Evolution follows a Fermi imitation rule with mutation.

## Main Features

* Reputation-based cooperation
* Objective and subjective reputation systems
* Noisy observation and misperception
* Ambiguity-averse decision making
* Action implementation errors
* Evolutionary dynamics
* Data collection and visualization of:

  * cooperation rates
  * population composition
  * average payoffs

## Project Structure

* `AgentStruct.jl` — agent definition
* `ModelStruct.jl` — model properties and parameters
* `SharedFunctions.jl` — payoff, and reputation logic
* `Noise.jl` — noisy information dynamics
* `Priors.jl` — ambiguity and prior updating
* `Maxmin_utility.jl` — ambiguity-averse utility functions
* `PerfectInfo_SternJudging.jl` — perfect information model
* `NoisyInfo_SternJudging.jl` — noisy information model
* `Ambiguity_SternJudging.jl` — ambiguity model
* `SternJudgingABM.jl` — main module
* `Run.jl` — script to execute simulations

## Requirements

The project uses:

* Julia
* Agents.jl
* Plots.jl
* StatsPlots.jl
* DataFrames.jl
* Statistics

Install dependencies with:


using Pkg
Pkg.add(["Agents", "Plots", "StatsPlots", "DataFrames"])


## Running the Model

Run all simulations with:


include("Sources/SternJudgingABM.jl")
using .SternJudgingABM

run_all()


Or run individual models:


run_perfect_info()
run_noisy_info()
run_ambiguity()


## Purpose

This project explores how ambiguity-aversion affect the emergence and stability of cooperation under indirect reciprocity and imperfect information.
