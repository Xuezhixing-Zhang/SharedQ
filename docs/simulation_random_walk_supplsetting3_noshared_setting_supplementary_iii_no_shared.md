# Supplementary Setting III: Continuous Covariates Without Shared Parameters

This supplementary setting keeps the executable data-generating mechanism from `Simulation_random_walk/Setting3` and changes only the population Q-parameter target.

## Data-Generating Mechanism

- Three-stage continuous-covariate design.
- `O1 ~ N(0, 1)`.
- `O2 = 0.60 * O1 + 0.80 * A1 + error`.
- `O3 = 0.50 * O2 + 0.40 * A2 + 0.60 * A1 * A2 + error`.
- `R1 ~ Bernoulli(0.38)`.
- `R2 = 1` for stage-1 responders; otherwise `R2 ~ Bernoulli(0.19)`.
- `A1` is randomized in `{-1, 1}`.
- `A2` and `A3` are randomized in `{-1, 1}` only while active; inactive responder treatments are encoded as `0`.

## Q-Parameter Target

The Q-model is the same 25-coefficient model used by Setting III. The candidate shared-effect analogues are deliberately separated:

- `Q3_A3`, `Q2_A2`, `Q1_A1`.
- `Q3_O3:A3`, `Q2_O2:A2`, `Q1_O1:A1`.
- `Q3_A2:A3`, `Q2_A1:A2`.

`nloptr_Setting3.R` defines three target groups:

- `separated_moderate`
- `separated_reversed`
- `separated_large`

The fused and strict shared methods are retained as intentionally misspecified comparisons.
