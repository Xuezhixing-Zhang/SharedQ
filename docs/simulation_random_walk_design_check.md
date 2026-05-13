# Data-Generating Mechanism Check

Checked on 2026-04-29 against the executable files in `Simulation_random_walk`.

## Setting I

- Design: binary-treatment real-data mimic with final primary outcome, fixed responder probabilities, responder follow-up treatment set to `-1`, and near-shared last-two-stage parameters.
- Code checked: `Setting1/nloptr_Setting1.R`.
- Status: matches the markdown design.
- Notes:
  - `R1 ~ Bernoulli(0.59)`.
  - `R2` depends on `A1` only in code, with probability `0.23` for `A1 = 1` and `0.13` for `A1 = -1`. This is equivalent to the markdown table because the table gives the same probability for both `A2` values within each `A1`.
  - `A2` and `A3` are randomized for non-responders and set to `-1` for responders.
  - `theta_target` uses small deviations around shared means for the intended near-sharing design.

## Setting II

- Design: same binary-treatment data mechanism as Setting I, but candidate shared parameters are intentionally separated.
- Code checked: `Setting2/nloptr_Setting2.R`.
- Status: matches the markdown design.
- Notes:
  - The treatment, responder, and primary-outcome structure is the same as Setting I.
  - Candidate shared pairs are deliberately separated in `setting2_parameter_specs`.
  - SharedQ/fused shared-pattern methods are therefore misspecified comparisons in this setting.

## Setting III

- Design: continuous-covariate 3-stage setting with random responder indicators and staged outcomes `Y1`, `Y2`, `Y3`.
- Code checked: `Setting3/nloptr_Setting3.R` and `Setting3/Q_functions.R`.
- Status: mostly matches the executable workflow, with two markdown/code discrepancies.
- Discrepancies:
  - The markdown says `delta22 = 0.5`; the code uses `d22 = 0.80`.
  - The markdown says responders are assigned next treatment `-1`; the code uses `0` for inactive post-response treatments (`A2 = 0` when `R1 = 1`, `A3 = 0` when `R2 = 1`).
- Notes:
  - The model and filtering logic are built around the executable `0` convention for inactive responder treatments.
  - The current Setting III calibration target is random-walk near-sharing, not exact sharing.

## Supplementary Setting III No Shared

- Design: same executable continuous-covariate data mechanism as Setting III, but no shared decision-effect target.
- Code checked: `SupplSetting3_NoShared/nloptr_Setting3.R`.
- Status: implemented as a supplementary no-shared variant.
- Notes:
  - Uses the same `Y1`, `Y2`, `Y3`, responder, covariate, and inactive-treatment conventions as executable Setting III.
  - Decision-effect analogues are separated across stages in `separated_moderate`, `separated_reversed`, and `separated_large`.
  - SharedQ and fused shared-pattern methods are intentionally misspecified comparisons here.
