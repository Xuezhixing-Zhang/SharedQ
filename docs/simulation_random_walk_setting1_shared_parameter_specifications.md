# Setting I Shared-Parameter Specifications

## Purpose

This file records the candidate shared-parameter specifications used for random-walk setting I, together with the reproducibility settings used for `nloptr` calibration. Each specification is saved as an `.rds` file in the same folder.

## Shared Patterns

The shared-effect pairs are:

- `psi1`: `Q3_A1` and `Q2_A1`
- `psi2`: `Q3_A3` and `Q2_A2`
- `psi3`: `Q3_A1A3` and `Q2_A1A2`

The mapping from `(mu, sigma)` to the target Q parameters is:

- stage 3 shared coefficient = `mu + sigma`
- stage 2 shared coefficient = `mu - sigma`

So the within-pair difference is `2 * sigma`.

## Calibration Settings

All current saved calibration runs use:

- `n_starts = 1`
- `mc_n = 5000`
- `maxeval = 50`
- `local_maxeval = 20`
- `xtol_rel = 1e-6`
- `print_level = 0`

These are bounded settings for reproducible calibration and debugging. They can be increased later for production-quality calibration.

## Specifications

### `balanced_small`

- Description: baseline near-shared specification with symmetric small deviations.
- Seed: `101`
- `shared_mu = (psi1 = 0.20, psi2 = -0.60, psi3 = 0.80)`
- `shared_sigma = (psi1 = 0.03, psi2 = 0.03, psi3 = 0.03)`
- Implied shared targets:
  - `Q3_A1 = 0.23`, `Q2_A1 = 0.17`
  - `Q3_A3 = -0.57`, `Q2_A2 = -0.63`
  - `Q3_A1A3 = 0.83`, `Q2_A1A2 = 0.77`
- Output file: `calibration_balanced_small.rds`

### `tighter_small`

- Description: closer-to-exact sharing with smaller deviations and slightly weaker means.
- Seed: `202`
- `shared_mu = (psi1 = 0.16, psi2 = -0.52, psi3 = 0.68)`
- `shared_sigma = (psi1 = 0.015, psi2 = 0.02, psi3 = 0.02)`
- Implied shared targets:
  - `Q3_A1 = 0.175`, `Q2_A1 = 0.145`
  - `Q3_A3 = -0.50`, `Q2_A2 = -0.54`
  - `Q3_A1A3 = 0.70`, `Q2_A1A2 = 0.66`
- Output file: `calibration_tighter_small.rds`

### `wider_small`

- Description: wider random-walk deviations with stronger means.
- Seed: `303`
- `shared_mu = (psi1 = 0.24, psi2 = -0.68, psi3 = 0.92)`
- `shared_sigma = (psi1 = 0.05, psi2 = 0.05, psi3 = 0.05)`
- Implied shared targets:
  - `Q3_A1 = 0.29`, `Q2_A1 = 0.19`
  - `Q3_A3 = -0.63`, `Q2_A2 = -0.73`
  - `Q3_A1A3 = 0.97`, `Q2_A1A2 = 0.87`
- Output file: `calibration_wider_small.rds`

## Saved Artifacts

- `calibration_balanced_small.rds`
- `calibration_tighter_small.rds`
- `calibration_wider_small.rds`
- `shared_parameter_spec_runs.rds`

## Reproducible Commands

- Run all saved specifications:
  `module load cmake/3.21.4 r/4.4.0 && Rscript Simulation_random_walk/Setting1/spec_calibration.R`

- Run a single custom specification manually by sourcing:
  `Simulation_random_walk/Setting1/nloptr_Setting1.R`
  and calling:
  `run_setting1_parameter_search(...)`
