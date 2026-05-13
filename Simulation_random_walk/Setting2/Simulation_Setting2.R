library(dplyr)
library(progress)

setting2_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting2"
setting2_calibration_dir <- file.path(setting2_dir, "calibration")
setting2_simulation_results_dir <- file.path(setting2_dir, "simulation_results")
dir.create(setting2_calibration_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(setting2_simulation_results_dir, showWarnings = FALSE, recursive = TRUE)

source(file.path(setting2_dir, "Q_functions.R"))

run_setting2_simulation <- function(
  ns = c(100, 300, 500, 1000),
  n_reps = 200,
  nfolds = 5,
  metric = "MSE_Q",
  seed = 12345,
  pars_path = file.path(setting2_calibration_dir, "alternative_pars.rds"),
  mc_n = 1000000,
  search_maxeval = 100000,
  search_local_maxeval = 20000,
  search_print_level = 1,
  lambdas_l1 = exp(seq(-2, 8, length.out = 100)),
  lambdas_l2 = exp(seq(-2, 10, length.out = 100)),
  cv_max_tries = 10
) {
  if (!file.exists(pars_path)) {
    run_setting2_parameter_search(
      output_path = pars_path,
      mc_n = mc_n,
      maxeval = search_maxeval,
      local_maxeval = search_local_maxeval,
      print_level = search_print_level
    )
  }

  pars <- readRDS(pars_path)
  best_idx <- which.min(pars$values)
  gamma_true <- pars$all_gamma[, best_idx]
  names(gamma_true) <- c("Intercept", "A1", "G1", "A2", "A1A2", "G2", "A3", "A1A3", "A2A3")
  theta_true <- pars$all_theta[, best_idx]

  Q_learning_Setting_2(gamma_true, save = TRUE, mc_n = mc_n)

  set.seed(seed)
  for (n in ns) {
    pb <- progress_bar$new(total = n_reps)
    results_n <- vector("list", n_reps)

    for (i in seq_len(n_reps)) {
      print(paste("Setting II, n =", n, "rep =", i))
      results_n[[i]] <- Simu_II(
        n,
        gamma_true,
        theta_true,
        nfolds = nfolds,
        metric = metric,
        lambdas_l1 = lambdas_l1,
        lambdas_l2 = lambdas_l2,
        cv_max_tries = cv_max_tries
      )
      saveRDS(results_n, file.path(setting2_simulation_results_dir, paste0("results_", n, ".rds")))
      pb$tick()
    }

    names(results_n) <- paste0("result_", seq_len(n_reps))
    saveRDS(results_n, file.path(setting2_simulation_results_dir, paste0("results_", n, ".rds")))
  }
}

run_setting2_smoke_test <- function(
  n = 30,
  n_reps = 1,
  nfolds = 2,
  metric = "MSE_Q",
  seed = 1,
  pars_path = file.path(setting2_calibration_dir, "test_alternative_pars.rds"),
  mc_n = 5000
) {
  run_setting2_simulation(
    ns = c(n),
    n_reps = n_reps,
    nfolds = nfolds,
    metric = metric,
    seed = seed,
    pars_path = pars_path,
    mc_n = mc_n,
    search_maxeval = 50,
    search_local_maxeval = 20,
    search_print_level = 0,
    lambdas_l1 = exp(seq(-2, 3, length.out = 8)),
    lambdas_l2 = exp(seq(-2, 4, length.out = 8)),
    cv_max_tries = 2
  )
}

if (sys.nframe() == 0) {
  run_setting2_simulation()
}
