library(dplyr)

setting2_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting2"
setting2_calibration_dir <- file.path(setting2_dir, "calibration")
dir.create(setting2_calibration_dir, showWarnings = FALSE, recursive = TRUE)

if (!exists("safe_extract_coef", mode = "function")) {
  safe_extract_coef <- function(fit, coef_names) {
    coefs <- coef(fit)[coef_names]
    coefs[is.na(coefs)] <- 0
    coefs
  }
}

################## Setting II: 3-stage no-sharing design #################
## Parameter order:
## Q3: intercept, A1, A2, A1A2, G1, A3, A1A3, A2A3
## Q2: intercept, A1, A2, A1A2
## Q1: intercept, A1
##
## The candidate sharing pairs used by the methods are intentionally separated:
## beta31 vs beta21, beta35 vs beta22, and beta37 vs beta23.

build_theta_target <- function(values) {
  c(
    Q3_intercept = values["Q3_intercept"],
    Q3_A1 = values["Q3_A1"],
    Q3_A2 = values["Q3_A2"],
    Q3_A1A2 = values["Q3_A1A2"],
    Q3_G1 = values["Q3_G1"],
    Q3_A3 = values["Q3_A3"],
    Q3_A1A3 = values["Q3_A1A3"],
    Q3_A2A3 = values["Q3_A2A3"],
    Q2_intercept = values["Q2_intercept"],
    Q2_A1 = values["Q2_A1"],
    Q2_A2 = values["Q2_A2"],
    Q2_A1A2 = values["Q2_A1A2"],
    Q1_intercept = values["Q1_intercept"],
    Q1_A1 = values["Q1_A1"]
  )
}

setting2_default_values <- c(
  Q3_intercept = 0.00,
  Q3_A1 = 0.55,
  Q3_A2 = 0.20,
  Q3_A1A2 = 0.40,
  Q3_G1 = 0.80,
  Q3_A3 = -0.70,
  Q3_A1A3 = 0.95,
  Q3_A2A3 = 0.55,
  Q2_intercept = 0.00,
  Q2_A1 = -0.15,
  Q2_A2 = 0.45,
  Q2_A1A2 = -0.35,
  Q1_intercept = 0.00,
  Q1_A1 = 0.20
)

theta_target <- build_theta_target(setting2_default_values)

setting2_parameter_specs <- list(
  separated_moderate = list(
    description = "Moderate separation for all candidate shared pairs; primary Setting II no-sharing scenario.",
    seed = 101,
    values = setting2_default_values
  ),
  separated_reversed = list(
    description = "Opposite signs across candidate shared pairs to stress misspecified shared models.",
    seed = 202,
    values = c(
      Q3_intercept = 0.00, Q3_A1 = -0.50, Q3_A2 = 0.25, Q3_A1A2 = 0.35,
      Q3_G1 = 0.80, Q3_A3 = 0.65, Q3_A1A3 = -0.85, Q3_A2A3 = 0.50,
      Q2_intercept = 0.00, Q2_A1 = 0.30, Q2_A2 = -0.45, Q2_A1A2 = 0.45,
      Q1_intercept = 0.00, Q1_A1 = -0.10
    )
  ),
  separated_large = list(
    description = "Larger separation with stronger stage-3 and stage-2 effects.",
    seed = 303,
    values = c(
      Q3_intercept = 0.00, Q3_A1 = 0.75, Q3_A2 = 0.15, Q3_A1A2 = 0.50,
      Q3_G1 = 0.80, Q3_A3 = -0.90, Q3_A1A3 = 1.15, Q3_A2A3 = 0.65,
      Q2_intercept = 0.00, Q2_A1 = -0.35, Q2_A2 = 0.65, Q2_A1A2 = -0.55,
      Q1_intercept = 0.00, Q1_A1 = 0.30
    )
  )
)

Q_learning_Setting_2 <- function(gamma_start, save = FALSE, mc_n = 1000000, seed = 1234) {
  set.seed(seed)

  gamma <- gamma_start
  n <- mc_n
  A1 <- ifelse(rbinom(n, 1, 1 / 2) == 1, 1, -1)

  R1 <- rbinom(n, 1, 0.59)
  R2 <- ifelse(A1 == 1, rbinom(n, 1, 0.23), rbinom(n, 1, 0.13))

  A2 <- ifelse(R1 == 1, -1, sample(c(1, -1), n, replace = TRUE))
  A3 <- ifelse(R2 == 1, -1, sample(c(1, -1), n, replace = TRUE))

  G1 <- 1 - R1
  G2 <- 1 - R2

  X_design <- data.frame(
    A1 = A1,
    G1 = G1,
    A2 = A2,
    A1A2 = A1 * A2,
    G2 = G2,
    A3 = A3,
    A1A3 = A1 * A3,
    A2A3 = A2 * A3
  )

  Y <- gamma[1] + c(gamma[2:9] %*% t(X_design))
  data_original <- data.frame(Y = Y, X_design)

  if (isTRUE(save)) {
    saveRDS(data_original, file.path(setting2_calibration_dir, "data_original.rds"))
  }

  data_Q3 <- subset(data_original, G2 == 1)
  Q3_fit <- lm(Y ~ A1 + A2 + A1A2 + G1 + A3 + A1A3 + A2A3, data = data_Q3)
  Y <- data_original$Y

  A3_block <- dplyr::select(data_original, A3, A1A3, A2A3)
  b3 <- safe_extract_coef(Q3_fit, c("A3", "A1A3", "A2A3"))
  real_A3 <- as.numeric(as.matrix(A3_block) %*% b3)
  pseudo_A3 <- as.numeric(as.matrix(-A3_block) %*% b3)
  max_A3 <- pmax(real_A3, pseudo_A3)

  optimal_A3 <- ifelse(real_A3 >= pseudo_A3, data_original$A3, -data_original$A3)
  optimal_A3 <- data_original$G2 * optimal_A3 + (1 - data_original$G2) * data_original$A3
  Y_optimal_Q3 <- data_original$G2 * (Y - real_A3 + max_A3) + (1 - data_original$G2) * Y

  data_Q2 <- data_original %>%
    dplyr::select(Y, A1, G1, A2, A1A2) %>%
    mutate(Y = Y_optimal_Q3) %>%
    filter(G1 == 1)
  Q2_fit <- lm(Y ~ A1 + A2 + A1A2, data = data_Q2)

  A2_block <- dplyr::select(data_original, A2, A1A2)
  b2 <- safe_extract_coef(Q2_fit, c("A2", "A1A2"))
  real_A2 <- as.numeric(as.matrix(A2_block) %*% b2)
  pseudo_A2 <- as.numeric(as.matrix(-A2_block) %*% b2)
  max_A2 <- pmax(real_A2, pseudo_A2)

  optimal_A2 <- ifelse(real_A2 >= pseudo_A2, data_original$A2, -data_original$A2)
  optimal_A2 <- data_original$G1 * optimal_A2 + (1 - data_original$G1) * data_original$A2
  Y_optimal_Q2 <- data_original$G1 * (Y_optimal_Q3 - real_A2 + max_A2) +
    (1 - data_original$G1) * Y_optimal_Q3

  data_Q1 <- data_original %>%
    dplyr::select(Y, A1) %>%
    mutate(Y = Y_optimal_Q2)
  Q1_fit <- lm(Y ~ A1, data = data_Q1)
  b1 <- safe_extract_coef(Q1_fit, c("A1"))
  optimal_A1 <- rep(sign(b1["A1"]), nrow(data_original))

  theta <- c(
    safe_extract_coef(Q3_fit, c("(Intercept)", "A1", "A2", "A1A2", "G1", "A3", "A1A3", "A2A3")),
    safe_extract_coef(Q2_fit, c("(Intercept)", "A1", "A2", "A1A2")),
    safe_extract_coef(Q1_fit, c("(Intercept)", "A1"))
  )

  list(
    theta = theta,
    Q3_coef = Q3_fit$coefficients,
    Q2_coef = Q2_fit$coefficients,
    Q1_coef = Q1_fit$coefficients,
    optimal_A3 = optimal_A3,
    optimal_A2 = optimal_A2,
    optimal_A1 = optimal_A1
  )
}

theta_Setting_2 <- function(gamma) {
  Q_learning_Setting_2(gamma)$theta
}

optim_Setting_2 <- function(gamma, theta_target, mc_n = 1000000, seed = 1234) {
  theta <- Q_learning_Setting_2(gamma, mc_n = mc_n, seed = seed)$theta
  sum((theta - theta_target)^2)
}

eval_f <- function(x, theta_target, mc_n = 1000000, seed = 1234) {
  obj <- as.numeric(optim_Setting_2(x, theta_target, mc_n = mc_n, seed = seed))
  grad <- rep(0, length(x))
  list(objective = obj, gradient = grad)
}

eval_g_eq <- function(x) {
  numeric(0)
}

candidate_target_tolerance <- 0.03
candidate_constraint_tolerance <- 1e-4

setting2_candidate_indices <- c(2, 10, 6, 11, 7, 12)
setting2_candidate_groups <- list(
  psi1 = c(Q3_A1 = 2, Q2_A1 = 10),
  psi2 = c(Q3_A3 = 6, Q2_A2 = 11),
  psi3 = c(Q3_A1A3 = 7, Q2_A1A2 = 12)
)

target_window_constraints <- function(theta, theta_target, indices, tolerance) {
  c(
    theta[indices] - (theta_target[indices] + tolerance),
    (theta_target[indices] - tolerance) - theta[indices]
  )
}

target_difference_constraints <- function(theta, theta_target, groups, tolerance) {
  constraints <- numeric(0)
  for (group in groups) {
    if (length(group) < 2) next
    pairs <- utils::combn(unname(group), 2)
    for (j in seq_len(ncol(pairs))) {
      pair <- pairs[, j]
      actual_diff <- theta[pair[1]] - theta[pair[2]]
      target_diff <- theta_target[pair[1]] - theta_target[pair[2]]
      constraints <- c(
        constraints,
        actual_diff - (target_diff + tolerance),
        (target_diff - tolerance) - actual_diff
      )
    }
  }
  constraints
}

setting2_candidate_constraint_count <- function() {
  2 * length(setting2_candidate_indices) +
    sum(vapply(setting2_candidate_groups, function(group) {
      if (length(group) < 2) 0 else 2 * choose(length(group), 2)
    }, numeric(1)))
}

eval_g_ineq <- function(
  x,
  theta_target_override = theta_target,
  target_tolerance = candidate_target_tolerance,
  mc_n = 1000000,
  seed = 1234
) {
  theta <- Q_learning_Setting_2(x, mc_n = mc_n, seed = seed)$theta
  c(
    target_window_constraints(
      theta,
      theta_target_override,
      setting2_candidate_indices,
      target_tolerance
    ),
    target_difference_constraints(
      theta,
      theta_target_override,
      setting2_candidate_groups,
      target_tolerance
    )
  )
}

run_setting2_parameter_search <- function(
  n_starts = 1,
  output_path = file.path(setting2_calibration_dir, "alternative_pars.rds"),
  seed = 1234,
  theta_target_override = theta_target,
  values_override = setting2_default_values,
  mc_n = 1000000,
  maxeval = 100000,
  local_maxeval = 20000,
  xtol_rel = 1e-6,
  target_tolerance = candidate_target_tolerance,
  constraint_tolerance = candidate_constraint_tolerance,
  print_level = 1
) {
  if (!requireNamespace("nloptr", quietly = TRUE)) {
    stop("Package 'nloptr' is required for run_setting2_parameter_search() but is not installed.")
  }

  all_theta <- NULL
  all_gamma <- NULL
  values <- numeric(n_starts)
  gamma_length <- 9
  lb <- rep(-Inf, gamma_length)
  ub <- rep(Inf, gamma_length)

  set.seed(seed)
  for (i in seq_len(n_starts)) {
    gamma_opt <- runif(gamma_length, -1, 1)
    res <- nloptr::nloptr(
      x0 = gamma_opt,
      eval_f = function(x) eval_f(x, theta_target = theta_target_override, mc_n = mc_n, seed = seed),
      eval_g_eq = eval_g_eq,
      eval_g_ineq = function(x) eval_g_ineq(
        x,
        theta_target_override = theta_target_override,
        target_tolerance = target_tolerance,
        mc_n = mc_n,
        seed = seed
      ),
      lb = lb,
      ub = ub,
      opts = list(
        algorithm = "NLOPT_LN_COBYLA",
        local_opts = list(
          algorithm = "NLOPT_LN_COBYLA",
          xtol_rel = xtol_rel,
          maxeval = local_maxeval
        ),
        xtol_rel = xtol_rel,
        maxeval = maxeval,
        tol_constraints_ineq = rep(
          constraint_tolerance,
          setting2_candidate_constraint_count()
        ),
        print_level = print_level
      )
    )

    all_gamma <- cbind(all_gamma, res$solution)
    fit <- Q_learning_Setting_2(res$solution, mc_n = mc_n, seed = seed)
    values[i] <- sum(abs(fit$theta - theta_target_override))
    all_theta <- cbind(all_theta, fit$theta)
  }

  results <- list(
    theta_target = theta_target_override,
    target_values = values_override,
    seed = seed,
    mc_n = mc_n,
    n_starts = n_starts,
    maxeval = maxeval,
    local_maxeval = local_maxeval,
    xtol_rel = xtol_rel,
    target_tolerance = target_tolerance,
    constraint_tolerance = constraint_tolerance,
    print_level = print_level,
    all_gamma = all_gamma,
    all_theta = all_theta,
    values = values
  )
  saveRDS(results, output_path)
  invisible(results)
}

run_setting2_parameter_specs <- function(
  specs = setting2_parameter_specs,
  output_dir = setting2_calibration_dir,
  mc_n = 5000,
  maxeval = 50,
  local_maxeval = 20,
  xtol_rel = 1e-6,
  target_tolerance = candidate_target_tolerance,
  constraint_tolerance = candidate_constraint_tolerance,
  n_starts = 1,
  print_level = 0
) {
  outputs <- vector("list", length(specs))
  spec_names <- names(specs)

  for (i in seq_along(specs)) {
    spec_name <- spec_names[i]
    spec <- specs[[i]]
    theta_target_spec <- build_theta_target(spec$values)
    output_path <- file.path(output_dir, paste0("calibration_", spec_name, ".rds"))

    results <- run_setting2_parameter_search(
      n_starts = n_starts,
      output_path = output_path,
      seed = spec$seed,
      theta_target_override = theta_target_spec,
      values_override = spec$values,
      mc_n = mc_n,
      maxeval = maxeval,
      local_maxeval = local_maxeval,
      xtol_rel = xtol_rel,
      target_tolerance = target_tolerance,
      constraint_tolerance = constraint_tolerance,
      print_level = print_level
    )

    outputs[[i]] <- list(
      spec_name = spec_name,
      description = spec$description,
      output_path = output_path,
      seed = spec$seed,
      mc_n = mc_n,
      maxeval = maxeval,
      local_maxeval = local_maxeval,
      xtol_rel = xtol_rel,
      target_tolerance = target_tolerance,
      constraint_tolerance = constraint_tolerance,
      n_starts = n_starts,
      target_values = spec$values,
      theta_target = theta_target_spec,
      best_value = min(results$values),
      best_index = which.min(results$values)
    )
  }

  names(outputs) <- spec_names
  summary_path <- file.path(output_dir, "parameter_spec_runs.rds")
  saveRDS(outputs, summary_path)
  invisible(outputs)
}

if (sys.nframe() == 0) {
  run_setting2_parameter_search()
}
