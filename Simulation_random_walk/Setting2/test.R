setting2_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting2"
setting2_calibration_dir <- file.path(setting2_dir, "calibration")
setting2_test_results_dir <- file.path(setting2_dir, "test_results")
dir.create(setting2_calibration_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(setting2_test_results_dir, showWarnings = FALSE, recursive = TRUE)

source(file.path(setting2_dir, "Simulation_Setting2.R"))

test_mode <- Sys.getenv("SETTING2_TEST_MODE", unset = "quick")

message("Setting II test mode: ", test_mode)

pars_path <- file.path(setting2_calibration_dir, "test_alternative_pars.rds")
population_path <- file.path(setting2_calibration_dir, "data_original.rds")
population_backup_path <- tempfile("setting2_data_original_", fileext = ".rds")
had_population <- file.exists(population_path)
if (had_population) {
  file.copy(population_path, population_backup_path, overwrite = TRUE)
}
restore_population_file <- function() {
  if (had_population && file.exists(population_backup_path)) {
    file.copy(population_backup_path, population_path, overwrite = TRUE)
    unlink(population_backup_path)
  } else if (!had_population && file.exists(population_path)) {
    unlink(population_path)
  }
}

if (!file.exists(pars_path)) {
  message("Creating bounded test parameter search output: ", pars_path)
  run_setting2_parameter_search(
    n_starts = 1,
    output_path = pars_path,
    seed = 1,
    mc_n = 5000,
    maxeval = 50,
    local_maxeval = 20,
    print_level = 0
  )
}

pars <- readRDS(pars_path)
best_idx <- which.min(pars$values)
gamma_true <- pars$all_gamma[, best_idx]
names(gamma_true) <- c("Intercept", "A1", "G1", "A2", "A1A2", "G2", "A3", "A1A3", "A2A3")
theta_true <- pars$all_theta[, best_idx]

message("Building bounded Monte Carlo population dataset")
population_fit <- tryCatch(
  Q_learning_Setting_2(gamma_true, save = TRUE, mc_n = 5000, seed = 1),
  finally = restore_population_file()
)
stopifnot(length(population_fit$theta) == 14)

message("Running direct method checks on one sampled dataset")
set.seed(1)
data_simu <- prepare_setting2_data(Generate_data(20))

results_1 <- Q_learning(data_simu)
stopifnot(length(results_1$theta) == 14, !any(is.na(results_1$theta)))

warmstart <- results_1$theta
D_true <- build_true_D(length(warmstart))
D_mis <- build_mis_D(length(warmstart))

  cv_l1 <- CV_SQlearning(
  data_simu,
  warmstart = warmstart,
  lambda = 0.1,
  D = D_true,
  nfolds = 2,
  metric = "MSE_Q",
  max_iter = 200
)
stopifnot(length(cv_l1$fold_scores) == 2)

fit_l1 <- SQlearning(data_simu, warmstart = warmstart, lambda = 0.1, D = D_true, max_iter = 200)
stopifnot(length(fit_l1$theta) == 14)

warm_shared <- c(
  warmstart[c(1, 3, 4, 5, 8, 9, 13, 14)],
  mean(warmstart[c(2, 10)]),
  mean(warmstart[c(6, 11)]),
  mean(warmstart[c(7, 12)])
)
fit_shared <- SharedQ(data_simu, warm_shared)
stopifnot(length(fit_shared$theta) == 14)

warm_shared_mis <- c(
  warmstart[c(1, 3, 4, 5, 8, 9, 13)],
  mean(warmstart[c(2, 10, 14)]),
  mean(warmstart[c(6, 11)]),
  mean(warmstart[c(7, 12)])
)
fit_shared_mis <- SharedQ_mis(data_simu, warm_shared_mis)
stopifnot(length(fit_shared_mis$theta) == 14)

cv_l2 <- CV_SQlearning_L2(
  data_simu,
  warmstart = warmstart,
  lambda = 0.1,
  gamma = 0,
  D = D_true,
  nfolds = 2,
  metric = "MSE_Q",
  max_iter = 200
)
stopifnot(length(cv_l2$fold_scores) == 2)

fit_l2 <- SQlearning_L2(data_simu, warmstart = warmstart, lambda = 0.1, gamma = 0, D = D_true, max_iter = 200)
stopifnot(length(fit_l2$theta) == 14)

eval_1 <- evaluate(results_1, theta_true = theta_true, data_original = data_simu)
stopifnot(all(c("M", "M_weighted", "A3_bias", "A2_bias", "A1_bias", "A1A3_bias", "A1A2_bias") %in% names(eval_1)))

message("Quick method-level checks passed")

if (identical(test_mode, "full")) {
  message("Running one bounded replicate through Simu_II()")
  one_rep <- Simu_II(
    n = 20,
    gamma_true = gamma_true,
    theta_true = theta_true,
    nfolds = 2,
    metric = "MSE_Q",
  lambdas_l1 = c(0.1, 1),
  lambdas_l2 = c(0.1, 1),
  cv_max_tries = 1,
  max_iter_l1 = 200,
  max_iter_l2 = 200
)
  stopifnot(all(c("results_4_mis", "evaluation_4_mis") %in% names(one_rep)))
  saveRDS(one_rep, file.path(setting2_test_results_dir, "test_one_replicate.rds"))
  message("Full one-replicate test passed")
}

message("Setting II test script completed successfully")
