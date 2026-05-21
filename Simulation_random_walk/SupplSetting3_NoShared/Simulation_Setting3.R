library(dplyr)
library(progress)

suppl_setting3_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared"
suppl_setting3_calibration_dir <- file.path(suppl_setting3_dir, "calibration")
suppl_setting3_simulation_results_dir <- file.path(suppl_setting3_dir, "simulation_results")
dir.create(suppl_setting3_calibration_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(suppl_setting3_simulation_results_dir, showWarnings = FALSE, recursive = TRUE)

source(file.path(suppl_setting3_dir, "Q_functions.R"))
source(file.path(suppl_setting3_dir, "nloptr_Setting3.R"))

run_setting3_simulation <- function(
  ns = c(100, 300, 500, 1000),
  n_reps = 200,
  nfolds = 5,
  metric = "MSE_Q",
  seed = 12345,
  pars_path = file.path(suppl_setting3_calibration_dir, "calibration_separated_moderate.rds"),
  mc_n = 1000000,
  search_maxeval = 8000,
  search_local_maxeval = 8000,
  search_print_level = 1,
  lambdas = exp(seq(-2, 5, length.out = 100)),
  cv_max_tries = 10,
  max_iter_l1 = 5000,
  max_iter_l2 = 5000
) {
  if (!file.exists(pars_path)) {
    run_setting3_parameter_search(
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
  theta_true <- pars$all_theta[, best_idx]

  Q_learning_Setting_3(gamma_true, save = TRUE, mc_n = mc_n)

  set.seed(seed)
  for (n in ns) {
    pb <- progress_bar$new(total = n_reps)
    results_n <- vector("list", n_reps)

    for (i in seq_len(n_reps)) {
      print(paste("Supplementary Setting III No Shared, n =", n, "rep =", i))
      results_n[[i]] <- Simu_III(
        n,
        theta_true,
        nfolds = nfolds,
        metric = metric,
        lambdas = lambdas,
        cv_max_tries = cv_max_tries,
        max_iter_l1 = max_iter_l1,
        max_iter_l2 = max_iter_l2
      )
      saveRDS(results_n, file.path(suppl_setting3_simulation_results_dir, paste0("results_", n, ".rds")))
      pb$tick()
    }

    names(results_n) <- paste0("result_", seq_len(n_reps))
    saveRDS(results_n, file.path(suppl_setting3_simulation_results_dir, paste0("results_", n, ".rds")))
  }
}

run_setting3_smoke_test <- function(
  n = 30,
  n_reps = 1,
  nfolds = 2,
  metric = "MSE_Q",
  seed = 1,
  pars_path = file.path(suppl_setting3_calibration_dir, "test_alternative_pars.rds"),
  mc_n = 2000
) {
  run_setting3_simulation(
    ns = c(n),
    n_reps = n_reps,
    nfolds = nfolds,
    metric = metric,
    seed = seed,
    pars_path = pars_path,
    mc_n = mc_n,
    search_maxeval = 10,
    search_local_maxeval = 5,
    search_print_level = 0,
    lambdas = c(0.1, 1),
    cv_max_tries = 1,
    max_iter_l1 = 200,
    max_iter_l2 = 200
  )
}

if (sys.nframe() == 0) {
  run_setting3_simulation()
}
