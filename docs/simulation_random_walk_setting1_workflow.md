# Setting I Workflow

## Files and Roles

- `docs/simulation_random_walk_setting1_setting_i_design.md`: describes the scientific design for setting I, including the near-shared parameter structure for the last two stages.
- `docs/the_algorithm.md`: gives the iterative joint Q-learning idea behind the penalized estimators.
- `nloptr_Setting1.R`: calibrates the primary-outcome data-generating coefficients `gamma` so that the population-projected Q parameters match the target setting I pattern.
- `Q_datagenerating.R`: samples a simulation dataset from the large Monte Carlo population dataset and adds outcome noise.
- `Q_Conventional.R`: fits standard backward-induction Q-learning.
- `Q_SQlearning.R`: fits the fused lasso version of shared Q-learning.
- `Q_L2SQ.R`: fits the fused ridge version of shared Q-learning.
- `Q_SharedQ.R`: fits the strict shared-effect model.
- `Q_functions.R`: wrapper for one complete simulation replicate, including model fitting, CV tuning, and evaluation.
- `Simulation_Setting1.R`: top-level batch runner for repeated simulations across sample sizes.
- `Evaluation.R`: summarizes saved simulation results after the run.
- `submission.pbs`: cluster submission script for running `Simulation_Setting1.R`.

## Current Execution Flow

1. Run `nloptr_Setting1.R`.
   It searches for a `gamma_true` vector so that the induced population Q-model coefficients are close to the target setting I pattern. It saves the result as `alternative_pars.rds`.

2. Build the population dataset.
   `Q_learning_Setting_1(gamma_true, save = TRUE)` generates a large Monte Carlo population dataset under the chosen `gamma_true` and saves it as `data_original.rds`.

3. Start simulation replications with `Simulation_Setting1.R`.
   The script reads `alternative_pars.rds`, extracts the best `gamma_true` and `theta_true`, ensures `data_original.rds` exists, and then loops over the requested sample sizes and replicates.

4. Inside each replicate, `Simu_I()` in `Q_functions.R` runs the full pipeline.
   It samples `n` rows from `data_original.rds`, adds Gaussian noise to `Y`, fits conventional Q-learning, then fits the three comparison methods:
   `SQlearning` with the true sharing pattern,
   `SQlearning` with a misspecified sharing pattern,
   `SharedQ` with the true sharing pattern,
   `SharedQ_mis` with the misspecified sharing pattern,
   `SQlearning_L2` with the true sharing pattern,
   `SQlearning_L2` with the misspecified sharing pattern.

5. Penalized methods use cross-validation.
   For each candidate `lambda`, the code fits the model on training folds, scores it with the chosen metric, and keeps the best `lambda`.

6. `evaluate()` compares each fitted method against the target decision rule and target coefficients.
   The saved metrics include agreement in optimal treatment assignment and coefficient bias for the shared-effect terms.

7. `Simulation_Setting1.R` saves incremental result files.
   The output files are `results_100.rds`, `results_300.rds`, `results_500.rds`, and `results_1000.rds`.

## Main Code Dependencies

- `Simulation_Setting1.R` depends on `Q_functions.R` and `nloptr_Setting1.R`.
- `Q_functions.R` depends on `Q_Conventional.R`, `Q_SQlearning.R`, `Q_L2SQ.R`, `Q_SharedQ.R`, and `Q_datagenerating.R`.
- `Q_datagenerating.R` depends on the Monte Carlo dataset saved by `Q_learning_Setting_1(..., save = TRUE)`.

## Key Setting I Design Choice

This random-walk version no longer treats the shared parameters as exactly equal. The target pattern is now:

- `Q3_A1` and `Q2_A1` are close, but not identical.
- `Q3_A3` and `Q2_A2` are close, but not identical.
- `Q3_A1A3` and `Q2_A1A2` are close, but not identical.

The optimizer therefore targets a small deviation around shared means instead of enforcing exact equality.
