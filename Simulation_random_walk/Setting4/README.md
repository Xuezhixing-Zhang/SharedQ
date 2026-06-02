# Setting IV: Project Quit / Forever Free Shared Design

This folder is the implementation workspace for the Setting IV design described in `RANDOM_WALK_SETTING_DESIGN_SUMMARY.md`.

## Scope

- Main scenario: `pqff_shared_parsimonious`
- Simulation type: synthetic-parametric
- Dataset role: structure and aggregate design constants only
- Stage 1 treatment: five Project Quit fractional-factorial components
- Stage 2 treatment: Forever Free arm, default allocation `P(A_FF = +1) = 312 / 469`
- Primary reward: continuous cumulative abstinence signal plus additive noise

## Shared-Parameter Rule

The shared true coefficients follow the project-wide random shared rule:

```text
theta_j^(d) = mu_j + delta_j^(d),  delta_j^(d) ~ N(0, sigma_shared^2)
```

Do not implement Setting IV shared targets as deterministic `mu + sigma` or `mu - sigma` offsets.

## Implementation Status

The folder has executable synthetic-parametric data-generation, Q-learning, helper, and simulation wrappers:

- `Q_datagenerating.R`
- `Q_learning.R`
- `Q_functions.R`
- `Simulation_Setting4.R`

The cleaned PQ/FF file in `source_data/` is not a production simulation input. It is retained locally to document and verify the study structure: required variables, complete-consenter count, 16 fractional-factorial Project Quit arms, and the observed Forever Free allocation ratio.

Run Setting IV with:

```bash
module load r/4.4.0
Rscript Simulation_random_walk/Setting4/Simulation_Setting4.R
```

Use environment variables such as `SETTING4_NS`, `SETTING4_N_REPS`, `SETTING4_RECALIBRATE`, `SETTING4_CALIBRATION_MC_N`, `SETTING4_CALIBRATION_SEARCH_N`, `SETTING4_CALIBRATION_N_STARTS`, and `SETTING4_CALIBRATION_MAXIT` to control runtime.

Accepted calibration artifacts must have `source_mode = "synthetic_parametric"`. Real-source or source-data-resampling artifacts are invalid for Setting IV method claims.
