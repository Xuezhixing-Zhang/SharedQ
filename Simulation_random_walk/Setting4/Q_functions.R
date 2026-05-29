source("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting4/Q_learning.R")

build_setting4_calibration <- function(
  output_path = file.path(setting4_calibration_dir, "calibration_pqff_shared_parsimonious_synthetic.rds"),
  spec = "pqff_shared_parsimonious",
  source_data = NULL,
  mc_n = 100000,
  seed = 601,
  noise_sd = 0
) {
  if (is.null(source_data)) {
    allow_synthetic <- identical(Sys.getenv("SETTING4_ALLOW_SYNTHETIC", unset = "0"), "1")
    source_data <- prepare_setting4_source_data(allow_synthetic = allow_synthetic, seed = seed)
  }
  theta_target <- setting4_target_theta(spec)
  data_pop <- generate_setting4_data(mc_n, theta_target, source_data, noise_sd = noise_sd)
  fit <- fit_setting4_q(data_pop)
  artifact <- list(
    setting = "Setting4",
    spec = spec,
    source_mode = unique(source_data$source_mode)[1],
    theta_target = theta_target,
    theta = fit$theta,
    values = sum(abs(fit$theta - theta_target)),
    mc_n = mc_n,
    seed = seed,
    created_at = Sys.time(),
    note = if (identical(unique(source_data$source_mode)[1], "synthetic")) {
      "Synthetic fallback artifact for code/evaluation smoke runs; not an accepted PQ/FF production calibration."
    } else {
      "Empirical PQ/FF source-data projection artifact."
    }
  )
  saveRDS(artifact, output_path)
  artifact
}

Simu_IV <- function(
  n,
  theta_true,
  source_data,
  noise_sd = 1,
  lambda_l1 = 0.08,
  lambda_l2 = 0.20
) {
  data_simu <- generate_setting4_data(n, theta_true, source_data, noise_sd = noise_sd)
  arms <- setting4_fractional_factorial_arms()

  results_1 <- fit_setting4_q(data_simu, arms = arms)
  evaluation_1 <- evaluate_setting4(results_1, theta_true, data_simu, arms = arms)

  theta_l1 <- apply_setting4_fusion(results_1$theta, type = "l1", lambda = lambda_l1)
  results_2 <- setting4_result_from_theta(data_simu, theta_l1, method = "SQ learning (L1 penalty)", arms = arms)
  evaluation_2 <- evaluate_setting4(results_2, theta_true, data_simu, arms = arms)

  theta_shared <- apply_setting4_fusion(results_1$theta, type = "shared")
  results_3 <- setting4_result_from_theta(data_simu, theta_shared, method = "Q shared", arms = arms)
  evaluation_3 <- evaluate_setting4(results_3, theta_true, data_simu, arms = arms)

  theta_l2 <- apply_setting4_fusion(results_1$theta, type = "l2", lambda = lambda_l2)
  results_4 <- setting4_result_from_theta(data_simu, theta_l2, method = "SQ learning (L2 penalty)", arms = arms)
  evaluation_4 <- evaluate_setting4(results_4, theta_true, data_simu, arms = arms)

  list(
    results_1 = results_1,
    results_2 = results_2,
    results_3 = results_3,
    results_4 = results_4,
    evaluation_1 = evaluation_1,
    evaluation_2 = evaluation_2,
    evaluation_3 = evaluation_3,
    evaluation_4 = evaluation_4
  )
}
