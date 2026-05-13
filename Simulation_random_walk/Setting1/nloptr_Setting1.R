library(dplyr)

setting1_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting1"
setting1_calibration_dir <- file.path(setting1_dir, "calibration")
dir.create(setting1_calibration_dir, showWarnings = FALSE, recursive = TRUE)

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

shared_sigma <- c(psi1 = 0.03, psi2 = 0.03, psi3 = 0.03)
shared_mu <- c(psi1 = 0.20, psi2 = -0.60, psi3 = 0.80)

build_theta_target <- function(
  shared_mu,
  shared_sigma,
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
  c(
    Q3_intercept = base_unshared["Q3_intercept"],
    Q3_A1 = shared_mu["psi1"] + shared_sigma["psi1"],
    Q3_A2 = base_unshared["Q3_A2"],
    Q3_A1A2 = base_unshared["Q3_A1A2"],
    Q3_G1 = base_unshared["Q3_G1"],
    Q3_A3 = shared_mu["psi2"] + shared_sigma["psi2"],
    Q3_A1A3 = shared_mu["psi3"] + shared_sigma["psi3"],
    Q3_A2A3 = base_unshared["Q3_A2A3"],
    Q2_intercept = base_unshared["Q2_intercept"],
    Q2_A1 = shared_mu["psi1"] - shared_sigma["psi1"],
    Q2_A2 = shared_mu["psi2"] - shared_sigma["psi2"],
    Q2_A1A2 = shared_mu["psi3"] - shared_sigma["psi3"],
    Q1_intercept = base_unshared["Q1_intercept"],
    Q1_A1 = base_unshared["Q1_A1"]
  )
}

theta_target <- build_theta_target(shared_mu = shared_mu, shared_sigma = shared_sigma)

setting1_shared_parameter_specs <- list(
  balanced_small = list(
    description = "Baseline near-shared specification with symmetric small deviations around the three shared means.",
    seed = 101,
    shared_mu = c(psi1 = 0.20, psi2 = -0.60, psi3 = 0.80),
    shared_sigma = c(psi1 = 0.03, psi2 = 0.03, psi3 = 0.03)
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

eval_g_ineq <- function(x, mc_n = 1000000, seed = 1234) {
  theta <- Q_learning_Setting_1(x, mc_n = mc_n, seed = seed)$theta
  c(
    theta[2] - 0.32,
    -theta[2] + 0.08,
    theta[10] - 0.32,
    -theta[10] + 0.08,
    theta[14] + 0.10,
    -theta[14] - 0.30,
    theta[4] - 0.55,
    -theta[4] + 0.25,
    theta[3] - 0.35,
    -theta[3] + 0.05,
    theta[6] + 0.45,
    -theta[6] - 0.75,
    theta[11] + 0.45,
    -theta[11] - 0.75,
    theta[7] - 1.00,
    -theta[7] + 0.60,
    theta[12] - 1.00,
    -theta[12] + 0.60
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
      eval_g_ineq = function(x) eval_g_ineq(x, mc_n = mc_n, seed = seed),
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
    seed = seed,
    mc_n = mc_n,
    n_starts = n_starts,
    maxeval = maxeval,
    local_maxeval = local_maxeval,
    xtol_rel = xtol_rel,
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
  n_starts = 1,
  print_level = 0
) {
  outputs <- vector("list", length(specs))
  spec_names <- names(specs)

  for (i in seq_along(specs)) {
    spec_name <- spec_names[i]
    spec <- specs[[i]]
    theta_target_spec <- build_theta_target(spec$shared_mu, spec$shared_sigma)
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
      n_starts = n_starts,
      shared_mu = spec$shared_mu,
      shared_sigma = spec$shared_sigma,
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
