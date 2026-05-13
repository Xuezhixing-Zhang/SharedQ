setting3_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting3"
setting3_calibration_dir <- file.path(setting3_dir, "calibration")
dir.create(setting3_calibration_dir, showWarnings = FALSE, recursive = TRUE)

source(file.path(setting3_dir, "Q_functions.R"))
source(file.path(setting3_dir, "nloptr_Setting3.R"))

message("Setting III quick test")

pars_path <- file.path(setting3_calibration_dir, "test_alternative_pars.rds")
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

population_fit <- Q_learning_Setting_3(gamma_true, save = TRUE, mc_n = 2000)
stopifnot(length(population_fit$theta) == 25)

set.seed(1)
data_simu <- Generate_data(30)
results_1 <- Q_learning(data_simu)
stopifnot(length(results_1$theta) == 25, !any(is.na(results_1$theta)))

eval_1 <- evaluate(results_1, theta_true = theta_true, data_original = data_simu)
stopifnot(all(c("M", "M_weighted", "A3_bias", "A2_bias", "A1_bias") %in% names(eval_1)))

message("Setting III quick test completed successfully")
