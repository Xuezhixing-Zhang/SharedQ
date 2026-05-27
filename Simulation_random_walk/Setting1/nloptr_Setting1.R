library(dplyr)

setting1_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting1"
setting1_calibration_dir <- file.path(setting1_dir, "calibration")
dir.create(setting1_calibration_dir, showWarnings = FALSE, recursive = TRUE)

if (!exists("safe_extract_coef", mode = "function")) {
  safe_extract_coef <- function(fit, coef_names) {
    coefs <- coef(fit)[coef_names]
    coefs[is.na(coefs)] <- 0
    coefs
  }
}

################## Setting I: 3-stage random-walk sharing #################
## Parameter order:
## Q3: intercept, A1, A2, A1A2, G1, A3, A1A3, A2A3
## Q2: intercept, A1, A2, A1A2
## Q1: intercept, A1
##
## Shared pairs follow the design note with small deviations:
## beta31 and beta21 are near-shared around mu1
## beta35 and beta22 are near-shared around mu2
## beta37 and beta23 are near-shared around mu3

shared_sigma <- c(psi1 = 0.03, psi2 = 0.00, psi3 = 0.01)
shared_mu <- c(psi1 = 0.12, psi2 = -0.35, psi3 = 0.61)

with_preserved_seed <- function(seed, expr) {
  if (is.null(seed) || is.na(seed)) return(force(expr))
  has_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (has_seed) get(".Random.seed", envir = .GlobalEnv) else NULL
  on.exit({
    if (has_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  set.seed(seed)
  force(expr)
}

draw_setting1_shared_values <- function(shared_mu, shared_sigma, shared_seed = NULL) {
  with_preserved_seed(shared_seed, {
    values <- list(
      psi1 = stats::rnorm(2, mean = unname(shared_mu["psi1"]), sd = unname(shared_sigma["psi1"])),
      psi2 = stats::rnorm(2, mean = unname(shared_mu["psi2"]), sd = unname(shared_sigma["psi2"])),
      psi3 = stats::rnorm(2, mean = unname(shared_mu["psi3"]), sd = unname(shared_sigma["psi3"]))
    )
    names(values$psi1) <- c("Q3_A1", "Q2_A1")
    names(values$psi2) <- c("Q3_A3", "Q2_A2")
    names(values$psi3) <- c("Q3_A1A3", "Q2_A1A2")
    values
  })
}

build_theta_target <- function(
  shared_mu,
  shared_sigma,
  shared_seed = NULL,
  base_unshared = c(
    Q3_intercept = 0.00,
    Q3_A2 = 0.20,
    Q3_A1A2 = 0.40,
    Q3_G1 = 0.80,
    Q3_A2A3 = 0.60,
    Q2_intercept = 0.00,
    Q1_intercept = 0.00,
    Q1_A1 = -0.20
  )
) {
  shared_values <- draw_setting1_shared_values(
    shared_mu = shared_mu,
    shared_sigma = shared_sigma,
    shared_seed = shared_seed
  )
  theta <- c(
    Q3_intercept = base_unshared["Q3_intercept"],
    Q3_A1 = unname(shared_values$psi1["Q3_A1"]),
    Q3_A2 = base_unshared["Q3_A2"],
    Q3_A1A2 = base_unshared["Q3_A1A2"],
    Q3_G1 = base_unshared["Q3_G1"],
    Q3_A3 = unname(shared_values$psi2["Q3_A3"]),
    Q3_A1A3 = unname(shared_values$psi3["Q3_A1A3"]),
    Q3_A2A3 = base_unshared["Q3_A2A3"],
    Q2_intercept = base_unshared["Q2_intercept"],
    Q2_A1 = unname(shared_values$psi1["Q2_A1"]),
    Q2_A2 = unname(shared_values$psi2["Q2_A2"]),
    Q2_A1A2 = unname(shared_values$psi3["Q2_A1A2"]),
    Q1_intercept = base_unshared["Q1_intercept"],
    Q1_A1 = base_unshared["Q1_A1"]
  )
  attr(theta, "shared_mu") <- shared_mu
  attr(theta, "shared_sigma") <- shared_sigma
  attr(theta, "shared_seed") <- shared_seed
  attr(theta, "shared_values") <- shared_values
  theta
}

theta_target <- build_theta_target(shared_mu = shared_mu, shared_sigma = shared_sigma, shared_seed = 101)

setting1_shared_parameter_specs <- list(
  balanced_small = list(
    description = "Baseline feasible near-shared specification tuned after constrained calibration probes.",
    seed = 101,
    shared_mu = c(psi1 = 0.12, psi2 = -0.35, psi3 = 0.61),
    shared_sigma = c(psi1 = 0.03, psi2 = 0.00, psi3 = 0.01)
  ),
  tighter_small = list(
    description = "Smaller deviations and slightly weaker shared means to test a closer-to-exact sharing scenario.",
    seed = 202,
    shared_mu = c(psi1 = 0.16, psi2 = -0.52, psi3 = 0.68),
    shared_sigma = c(psi1 = 0.015, psi2 = 0.02, psi3 = 0.02)
  ),
  wider_small = list(
    description = "Larger but still small deviations with stronger shared means to stress the random-walk sharing assumption.",
    seed = 303,
    shared_mu = c(psi1 = 0.24, psi2 = -0.68, psi3 = 0.92),
    shared_sigma = c(psi1 = 0.05, psi2 = 0.05, psi3 = 0.05)
  )
)

Q_learning_Setting_1 <- function(gamma_start, save = FALSE, mc_n = 1000000, seed = 1234) {
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
    saveRDS(data_original, file.path(setting1_calibration_dir, "data_original.rds"))
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

theta_Setting_1 <- function(gamma) {
  Q_learning_Setting_1(gamma)$theta
}

optim_Setting_1 <- function(gamma, theta_target, mc_n = 1000000, seed = 1234) {
  theta <- Q_learning_Setting_1(gamma, mc_n = mc_n, seed = seed)$theta
  sum((theta - theta_target)^2)
}

eval_f <- function(x, theta_target, mc_n = 1000000, seed = 1234) {
  obj <- as.numeric(optim_Setting_1(x, theta_target, mc_n = mc_n, seed = seed))
  grad <- rep(0, length(x))
  list(objective = obj, gradient = grad)
}

eval_g_eq <- function(x) {
  numeric(0)
}

candidate_target_tolerance <- 0.01
candidate_constraint_tolerance <- 1e-4

setting1_candidate_indices <- c(2, 10, 6, 11, 7, 12)
setting1_candidate_groups <- list(
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

setting1_candidate_constraint_count <- function() {
  2 * length(setting1_candidate_indices) +
    sum(vapply(setting1_candidate_groups, function(group) {
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
  theta <- Q_learning_Setting_1(x, mc_n = mc_n, seed = seed)$theta
  c(
    target_window_constraints(
      theta,
      theta_target_override,
      setting1_candidate_indices,
      target_tolerance
    ),
    target_difference_constraints(
      theta,
      theta_target_override,
      setting1_candidate_groups,
      target_tolerance
    )
  )
}

run_setting1_parameter_search <- function(
  n_starts = 1,
  output_path = file.path(setting1_calibration_dir, "alternative_pars.rds"),
  seed = 1234,
  theta_target_override = theta_target,
  shared_mu_override = shared_mu,
  shared_sigma_override = shared_sigma,
  mc_n = 1000000,
  maxeval = 100000,
  local_maxeval = 20000,
  xtol_rel = 1e-6,
  target_tolerance = candidate_target_tolerance,
  constraint_tolerance = candidate_constraint_tolerance,
  print_level = 1
) {
  if (!requireNamespace("nloptr", quietly = TRUE)) {
    stop("Package 'nloptr' is required for run_setting1_parameter_search() but is not installed.")
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
          setting1_candidate_constraint_count()
        ),
        print_level = print_level
      )
    )

    all_gamma <- cbind(all_gamma, res$solution)
    fit <- Q_learning_Setting_1(res$solution, mc_n = mc_n, seed = seed)
    values[i] <- sum(abs(fit$theta - theta_target_override))
    all_theta <- cbind(all_theta, fit$theta)
  }

  results <- list(
    theta_target = theta_target_override,
    shared_mu = shared_mu_override,
    shared_sigma = shared_sigma_override,
    shared_values = attr(theta_target_override, "shared_values"),
    shared_seed = attr(theta_target_override, "shared_seed"),
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

run_setting1_shared_parameter_specs <- function(
  specs = setting1_shared_parameter_specs,
  output_dir = setting1_calibration_dir,
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
    theta_target_spec <- build_theta_target(
      shared_mu = spec$shared_mu,
      shared_sigma = spec$shared_sigma,
      shared_seed = spec$seed
    )
    output_path <- file.path(output_dir, paste0("calibration_", spec_name, ".rds"))

    results <- run_setting1_parameter_search(
      n_starts = n_starts,
      output_path = output_path,
      seed = spec$seed,
      theta_target_override = theta_target_spec,
      shared_mu_override = spec$shared_mu,
      shared_sigma_override = spec$shared_sigma,
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
      shared_mu = spec$shared_mu,
      shared_sigma = spec$shared_sigma,
      shared_seed = spec$seed,
      shared_values = attr(theta_target_spec, "shared_values"),
      theta_target = theta_target_spec,
      best_value = min(results$values),
      best_index = which.min(results$values)
    )
  }

  names(outputs) <- spec_names
  summary_path <- file.path(output_dir, "shared_parameter_spec_runs.rds")
  saveRDS(outputs, summary_path)
  invisible(outputs)
}

if (sys.nframe() == 0) {
  run_setting1_parameter_search()
}
