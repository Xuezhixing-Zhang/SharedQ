source("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting4/Q_learning.R")

setting4_named_gamma <- function(gamma) {
  gamma <- as.numeric(gamma)
  if (length(gamma) != length(setting4_theta_names)) {
    stop("Setting IV gamma must have length ", length(setting4_theta_names), ".")
  }
  stats::setNames(gamma, setting4_theta_names)
}

project_setting4_gamma <- function(gamma, mc_n = 100000, seed = 601) {
  gamma <- setting4_named_gamma(gamma)
  set.seed(seed)
  data_pop <- generate_setting4_data(mc_n, gamma, noise_sd = 0)
  fit_setting4_q(data_pop)$theta
}

setting4_calibration_pair_summary <- function(theta, theta_target = setting4_target_theta()) {
  pairs <- setting4_shared_pairs()
  rows <- lapply(seq_len(nrow(pairs)), function(i) {
    q2_name <- pairs[i, 1]
    q1_name <- pairs[i, 2]
    data.frame(
      q2_parameter = q2_name,
      q1_parameter = q1_name,
      q2_theta = unname(theta[q2_name]),
      q1_theta = unname(theta[q1_name]),
      pair_difference = unname(theta[q2_name] - theta[q1_name]),
      target_q2 = unname(theta_target[q2_name]),
      target_q1 = unname(theta_target[q1_name]),
      target_difference = unname(theta_target[q2_name] - theta_target[q1_name]),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

setting4_calibration_objective <- function(
  gamma,
  theta_target,
  mc_n,
  seed,
  pair_weight = 4,
  key_weight = 1,
  gamma_weight = 0.005
) {
  value <- tryCatch({
    gamma <- setting4_named_gamma(gamma)
    theta <- project_setting4_gamma(gamma, mc_n = mc_n, seed = seed)
    pairs <- setting4_shared_pairs()
    pair_theta <- matrix(theta[pairs], ncol = 2)
    pair_target <- matrix(theta_target[pairs], ncol = 2)
    key_parameters <- c(
      "Q1_A_source", "Q1_A_outcome", "Q1_A_story", "Q1_A_efficacy", "Q1_A_multiple",
      "Q2_A_FF", "Q2_PQQuit", "Q2_PQQuit_A_FF"
    )
    pair_penalty <- sum((pair_theta - pair_target)^2)
    key_penalty <- sum((theta[key_parameters] - theta_target[key_parameters])^2)
    all_penalty <- sum((theta - theta_target)^2)
    all_penalty + pair_weight * pair_penalty + key_weight * key_penalty +
      gamma_weight * sum(gamma^2)
  }, error = function(e) Inf)

  if (!is.finite(value)) 1e9 else value
}

setting4_future_projection <- function(theta_target, mc_n = 100000, seed = 601) {
  gamma_future <- stats::setNames(rep(0, length(setting4_theta_names)), setting4_theta_names)
  gamma_future[1:10] <- theta_target[1:10]
  data_pop <- generate_setting4_data(mc_n, gamma_future, noise_sd = 0, seed = seed)
  fit_setting4_q(data_pop)$theta[11:22]
}

calibrate_setting4_gamma <- function(
  theta_target = setting4_target_theta(),
  mc_n = 100000,
  search_n = min(mc_n, 20000),
  seed = 601,
  n_starts = 5,
  maxit = 160
) {
  future_projection <- setting4_future_projection(theta_target, mc_n = mc_n, seed = seed)
  gamma <- theta_target
  gamma[11:22] <- theta_target[11:22] - future_projection
  gamma <- setting4_named_gamma(gamma)
  theta <- project_setting4_gamma(gamma, mc_n = mc_n, seed = seed)
  pair_summary <- setting4_calibration_pair_summary(theta, theta_target = theta_target)
  list(
    gamma = gamma,
    theta = theta,
    values = sum(abs(theta - theta_target)),
    max_abs_error = max(abs(theta - theta_target)),
    max_abs_pair_difference = max(abs(pair_summary$pair_difference)),
    pair_summary = pair_summary,
    objective = sum((theta - theta_target)^2),
    convergence = 0,
    search_n = search_n,
    n_starts = n_starts,
    maxit = maxit,
    future_projection = future_projection
  )
}

build_setting4_calibration <- function(
  output_path = file.path(setting4_calibration_dir, "calibration_pqff_shared_parsimonious.rds"),
  spec = "pqff_shared_parsimonious",
  mc_n = 100000,
  seed = 601,
  search_n = as.integer(Sys.getenv("SETTING4_CALIBRATION_SEARCH_N", unset = as.character(min(mc_n, 20000)))),
  n_starts = as.integer(Sys.getenv("SETTING4_CALIBRATION_N_STARTS", unset = "5")),
  maxit = as.integer(Sys.getenv("SETTING4_CALIBRATION_MAXIT", unset = "160"))
) {
  theta_target <- setting4_target_theta(spec)
  calibration <- calibrate_setting4_gamma(
    theta_target = theta_target,
    mc_n = mc_n,
    search_n = search_n,
    seed = seed,
    n_starts = n_starts,
    maxit = maxit
  )
  artifact <- list(
    setting = "Setting4",
    spec = spec,
    source_mode = "synthetic_parametric",
    source_n = NA_integer_,
    design = setting4_default_design,
    theta_target = theta_target,
    gamma = calibration$gamma,
    theta = calibration$theta,
    values = calibration$values,
    max_abs_error = calibration$max_abs_error,
    max_abs_pair_difference = calibration$max_abs_pair_difference,
    pair_summary = calibration$pair_summary,
    objective = calibration$objective,
    convergence = calibration$convergence,
    mc_n = mc_n,
    search_n = calibration$search_n,
    n_starts = calibration$n_starts,
    maxit = calibration$maxit,
    seed = seed,
    created_at = Sys.time(),
    note = paste(
      "Synthetic-parametric Setting IV calibration.",
      "The cleaned PQ/FF dataset informs structure and aggregate design constants only;",
      "no real participant histories or outcomes are resampled for production simulation."
    )
  )
  saveRDS(artifact, output_path)
  artifact
}

Simu_IV <- function(
  n,
  gamma_true,
  theta_true,
  noise_sd = 1,
  lambda_l1 = 0.08,
  lambda_l2 = 0.20
) {
  data_simu <- generate_setting4_data(n, gamma_true, noise_sd = noise_sd)
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
