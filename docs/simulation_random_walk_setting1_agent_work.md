### The codework needed to be completed

- Check and understand what existing code files are used for. After that, try to fix potential bugs, errors, typos and to optimize existing codes. Current files include:

  - `Q_Conventional.R`: The conventional Q learning method, which will be used to compare.
  - `Q_L2SQ.R`: The proposed method with L2 ridge penalty. For algorithm, see `docs/the_algorithm.md`.
  - `Q_SharedQ.R`: The Shared Q method proposed by Bibhas, enforce all candidate shared parameters to have the same effect.
  - `Q_SQlearning.R`: The proposed method with L1 lasso penalty. For algorithm, see `docs/the_algorithm.md`, the only difference is the ridge penalty was replaced with lasso.
  - `Evaluation.R`: The functions used to evaluate the model performance after simulation. Four scenarios are considered, corresponding to four methods listed above. For shared parameter patterns, we also consider mis-specified scenarios.
  - `Q_functions.R`: The final wrapper function for the simulation. Do check the dependency between it and other functions, and try to check if all other functions are correctly specified.
  - `Simulation_Setting1.R`: The codes for running simulations.
  - `nloptr_Setting1.R`: The data generating framework for near-shared random-walk effect sizes. Define shared parameter values using the consolidated strategy in `RANDOM_WALK_SETTING_DESIGN_SUMMARY.md`. For the whole data generating framework, calibrate the primary outcome model until the projected Q-parameters have the desired pattern, where we choose primary outcome and transition parameters, then compute the population-projected Q-parameters by large Monte Carlo.
  - `Q_datagenerating.R`: Sample a small subset from the population dataset.
  - `submission.pbs`: The submission file to submit simulations to nodes.

  Note that many paths or model specification can also be wrong, this is because these codes are copied from previous versions, remember to fix them.

- After all that, adjust the `submission.pbs` for running simulations.
