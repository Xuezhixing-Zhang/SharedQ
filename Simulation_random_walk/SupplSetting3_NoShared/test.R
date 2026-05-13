suppl_setting3_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared"
suppl_setting3_calibration_dir <- file.path(suppl_setting3_dir, "calibration")
suppl_setting3_test_results_dir <- file.path(suppl_setting3_dir, "test_results")
dir.create(suppl_setting3_calibration_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(suppl_setting3_test_results_dir, showWarnings = FALSE, recursive = TRUE)

source(file.path(suppl_setting3_dir, "Q_functions.R"))
source(file.path(suppl_setting3_dir, "nloptr_Setting3.R"))

message("Supplementary Setting III No Shared quick test")
test_mode <- Sys.getenv("SUPPL_SETTING3_TEST_MODE", unset = "quick")

pars_path <- file.path(suppl_setting3_calibration_dir, "test_alternative_pars.rds")
population_path <- file.path(suppl_setting3_calibration_dir, "data_original.rds")
population_backup_path <- tempfile("suppl_setting3_data_original_", fileext = ".rds")
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
  run_setting3_parameter_search(
    output_path = pars_path,
    mc_n = 2000,
    maxeval = 10,
    local_maxeval = 5,
    print_level = 0
  )
}

pars <- readRDS(pars_path)
best_idx <- which.min(pars$values)
gamma_true <- pars$all_gamma[, best_idx]
theta_true <- pars$all_theta[, best_idx]

population_fit <- tryCatch(
  Q_learning_Setting_3(gamma_true, save = TRUE, mc_n = 2000),
  finally = restore_population_file()
)
stopifnot(length(population_fit$theta) == 25)

set.seed(1)
data_simu <- Generate_data(30)
results_1 <- Q_learning(data_simu)
stopifnot(length(results_1$theta) == 25, !any(is.na(results_1$theta)))

eval_1 <- evaluate(results_1, theta_true = theta_true, data_original = data_simu)
stopifnot(all(c("M", "M_weighted", "A3_bias", "A2_bias", "A1_bias") %in% names(eval_1)))

if (identical(test_mode, "full")) {
  one_rep <- Simu_III(
    n = 30,
    theta_true = theta_true,
    nfolds = 2,
    metric = "MSE_Q",
    lambdas = c(0.1, 1),
    cv_max_tries = 1,
    max_iter_l1 = 200,
    max_iter_l2 = 200
  )
  stopifnot(all(c("results_4", "evaluation_4") %in% names(one_rep)))
  saveRDS(one_rep, file.path(suppl_setting3_test_results_dir, "test_one_replicate.rds"))
}

message("Supplementary Setting III No Shared quick test completed successfully")
