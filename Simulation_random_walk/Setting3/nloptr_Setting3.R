library(dplyr)
library(nloptr)
setting3_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting3"
setting3_calibration_dir <- file.path(setting3_dir, "calibration")
dir.create(setting3_calibration_dir, showWarnings = FALSE, recursive = TRUE)
################## Setting III 3 stage #################
## Continuous-covariate random-walk sharing targets.

build_setting3_theta_target <- function(
  psi0_mu = -0.30,
  psi1_mu = 0.50,
  psi2_mu = 0.35,
  psi0_sigma = 0.08,
  psi1_sigma = 0.08,
  psi2_sigma = 0.06
) {
  c(
    # Q3
    0.10, 0.25, 0.50, 0.15, 0.60, 0.25, 0.20, 0.45, 0.40,
    psi0_mu + psi0_sigma,
    psi1_mu + psi1_sigma,
    psi2_mu + psi2_sigma,
    -0.28,
    # Q2
    0.20, 0.25, 0.35, 0.15, 0.70,
    psi0_mu,
    psi1_mu,
    psi2_mu - psi2_sigma,
    # Q1
    0.40, 0.50,
    psi0_mu - psi0_sigma,
    psi1_mu - psi1_sigma
  )
}

theta_target <- build_setting3_theta_target()
names(theta_target) <- c("Q3_intercept","Q3_O1","Q3_A1","Q3_O1A1","Q3_O2","Q3_A2","Q3_O2A2","Q3_A1A2","Q3_O3","Q3_A3_psi0","Q3_O3A3_psi1","Q3_A2A3_psi2","Q3_A1A2A3_psi3",
                         "Q2_intercept","Q2_O1","Q2_A1","Q2_O1A1","Q2_O2","Q2_A2_psi0","Q2_O2A2_psi1","Q2_A1A2_psi2",
                         "Q1_intercept","Q1_O1","Q1_A1_psi0","Q1_O1A1_psi1")

setting3_parameter_specs <- list(
  rw_sigma_moderate = list(
    description = "Moderate random-walk deviations; selected production scenario.",
    seed = 401,
    psi0_mu = -0.30,
    psi1_mu = 0.50,
    psi2_mu = 0.35,
    psi0_sigma = 0.08,
    psi1_sigma = 0.08,
    psi2_sigma = 0.06
  ),
  rw_sigma_tight = list(
    description = "Closer-to-exact sharing for sensitivity.",
    seed = 402,
    psi0_mu = -0.30,
    psi1_mu = 0.50,
    psi2_mu = 0.35,
    psi0_sigma = 0.04,
    psi1_sigma = 0.04,
    psi2_sigma = 0.03
  ),
  rw_sigma_wide = list(
    description = "Wider deviations while preserving the same signs and magnitudes.",
    seed = 403,
    psi0_mu = -0.30,
    psi1_mu = 0.50,
    psi2_mu = 0.35,
    psi0_sigma = 0.15,
    psi1_sigma = 0.15,
    psi2_sigma = 0.10
  )
)

## iterative Q learning ##
Q_learning_Setting_3 <- function(gamma_start, save = FALSE, mc_n = 1000000){
  
  
  set.seed(4321)
  ## Generate Simulation Data based on gamma ##
  # Specify a large sample size
  gamma <- gamma_start
  d21 <- 0.60; d22 <- 0.80
  d31 <- 0.50; d32 <- 0.40; d33 <- 0.60
  n <- mc_n
  
  data_x_path <- file.path(
    setting3_calibration_dir,
    paste0("data_X_", n, ".rds")
  )

  if(!file.exists(data_x_path)){
    ## --- Responders ---
    R1 <- rbinom(n, 1, 0.38)
    R2 <- ifelse(R1 == 1, 1, rbinom(n, 1, 0.19))
    
    ## --- Stage 1 ---
    A1 <- ifelse(rbinom(n, 1, 0.5) == 1, 1, -1)  # {-1,1}
    O1 <- rnorm(n, 0, 1)
    
    ## --- Stage 2: treatment and O2 ---
    A2 <- ifelse(R1 == 1, 0, sample(c(1, -1), n, replace = TRUE))
    O2 <- rnorm(n, d21 * O1 + d22 * A1, 1)
    
    ## --- Stage 3: treatment and O3 ---
    A3    <- ifelse(R2 == 1, 0, sample(c(1, -1), n, replace = TRUE))
    O3    <- rnorm(n, d31 * O2 + d32 * A1 + d33 * (A1 * A2), 1)
    
    data_X <- list(R1 = R1, R2= R2, A1 = A1, A2=A2, A3=A3, O1= O1, O2 = O2, O3=O3)
    saveRDS(data_X, data_x_path)
  }
  else{
    
    data_X <- readRDS(data_x_path)
    ## --- Responders ---
    R1 <- data_X$R1
    R2 <- data_X$R2
    
    ## --- Stage 1 ---
    A1 <- data_X$A1
    O1 <- data_X$O1
    
    ## --- Stage 2: treatment and O2 ---
    A2 <- data_X$A2
    O2 <- data_X$O2
    
    ## --- Stage 3: treatment and O3 ---
    A3    <- data_X$A3
    O3    <- data_X$O3
    
  }
  
  
  ## --- Y1, Y2, Y3 as specified ---
  ## Y1 = γ1 + γ2 O1 + γ3 A1 + γ4 O1*A1 + ε1
  Y1 <- gamma[1] + gamma[2]*O1 + gamma[3]*A1 + gamma[4]*(O1*A1)
  
  ## Y2 = Y1 + (3/2)[γ5 O1 + γ6 A2 + γ7 O2*A2 + γ8 A1*A2] + ε2
  Y2 <- Y1 + (3/2) * (gamma[5]*O1 + gamma[6]*A2 + gamma[7]*(O2*A2) + gamma[8]*(A1*A2))
  
  ## Y3 = Y2 + 3[γ9 O1 + γ10 A3 + γ11 O3*A3 + γ12 A2*A3 + γ13 A1*A2*A3] + ε3
  Y3 <- Y2 + 3 * (gamma[9]*O1 + gamma[10]*A3 + gamma[11]*(O3*A3) + gamma[12]*(A2*A3) + gamma[13]*(A1*A2*A3))
  
  ## --- Primary outcome ---
  ## Y_primary = R1*Y1 + (1-R1)R2 * (Y1+Y2)/2 + (1-R1)(1-R2) * (Y1+Y2+Y3)/3
  Y_primary <- R1*Y1 + (1 - R1)*R2 * ((Y1 + Y2)/2) + (1 - R1)*(1 - R2) * ((Y1 + Y2 + Y3)/3)
  
  ## --- Output dataset ---
  data_original <- data.frame(
    Y = Y_primary, Y1 = Y1, Y2 = Y2, Y3 = Y3,
    A1 = A1, A2 = A2, A3 = A3, R1 = R1, R2 = R2,
    O1 = O1, O2 = O2, O3 = O3
  )
  if(save == T){
    saveRDS(data_original, file.path(setting3_calibration_dir, "data_original.rds"))
  }
  ## Q3
  data_Q3 <- subset(data_original, R2 == 0 & R1 == 0)
  Q3_fit <- lm(Y ~ O1 + A1 + O1:A1 + O2 + A2 + O2:A2 + A1:A2 + O3 + A3 + O3:A3 + A2:A3 + A1:A2:A3, data=data_Q3)
  
  A3_block <- cbind(A3 = data_original$A3, 
                    `O3:A3` = data_original$O3*data_original$A3, 
                    `A2:A3` = data_original$A2*data_original$A3, 
                    `A1:A2:A3` = data_original$A1*data_original$A2*data_original$A3)
  b3 <- coef(Q3_fit)[c("A3","O3:A3","A2:A3","A1:A2:A3")]
  real_A3 <- as.numeric(as.matrix(A3_block) %*% b3)
  pseudo_A3 <- as.numeric(as.matrix(-A3_block) %*% b3)
  max_A3 <- pmax(real_A3, pseudo_A3)
  
  optimal_A3 <- ifelse(real_A3 >= pseudo_A3, data_original$A3, -data_original$A3)
  Y_optimal_Q3 <- ifelse(data_original$R2 == 0 & data_original$R1 == 0,
                         data_original$Y - real_A3 + max_A3,
                         data_original$Y)
  
  ## Q2
  data_Q2 <- data_original %>% 
    mutate(Y = Y_optimal_Q3) %>% 
    filter(R1 == 0) %>% 
    select(Y, O1, A1, O2, A2)
  
  Q2_fit <- lm(Y ~ O1 + A1 + O1:A1 + O2 + A2 + O2:A2 + A1:A2, data=data_Q2)
  
  A2_block <- cbind(A2 = data_original$A2, 
                    `O2:A2` = data_original$O2*data_original$A2, 
                    `A1:A2` = data_original$A1*data_original$A2)
  b2 <- coef(Q2_fit)[c("A2","O2:A2","A1:A2")]
  real_A2 <- as.numeric(as.matrix(A2_block) %*% b2)
  pseudo_A2 <- as.numeric(as.matrix(-A2_block) %*% b2)
  max_A2 <- pmax(real_A2, pseudo_A2)
  
  optimal_A2 <- ifelse(real_A2 >= pseudo_A2, data_original$A2, -data_original$A2)
  Y_optimal_Q2 <- ifelse(data_original$R1 == 0,
                         Y_optimal_Q3 - real_A2 + max_A2,
                         Y_optimal_Q3)
  
  ## Q1
  data_Q1 <- data_original %>% select(Y, O1, A1) %>% mutate(Y = Y_optimal_Q2)
  Q1_fit <- lm(Y ~ O1 + A1 + O1:A1, data=data_Q1)
  A1_block <- cbind(A1 = data_original$A1, 
                    `O1:A1` = data_original$O1*data_original$A1)
  b1 <- coef(Q1_fit)[c("A1","O1:A1")]
  real_A1 <- as.numeric(as.matrix(A1_block) %*% b1)
  pseudo_A1 <- as.numeric(as.matrix(-A1_block) %*% b1)
  max_A1 <- pmax(real_A1, pseudo_A1)
  optimal_A1 <- ifelse(real_A1 >= pseudo_A1, data_original$A1, -data_original$A1)
  # Y_optimal_Q1 <- Y_optimal_Q2 - real_A1 + max_A1
  
  theta <- c(
    coef(Q3_fit)[c("(Intercept)","O1","A1","O1:A1","O2","A2","O2:A2","A1:A2","O3","A3","O3:A3","A2:A3","A1:A2:A3")],
    coef(Q2_fit)[c("(Intercept)","O1","A1","O1:A1","O2","A2","O2:A2","A1:A2")],
    coef(Q1_fit)[c("(Intercept)","O1","A1","O1:A1")]
  )
  
  results <- list(theta = theta,
                  Q3_coef = Q3_fit$coefficients,
                  Q2_coef = Q2_fit$coefficients,
                  Q1_coef = Q1_fit$coefficients,
                  optimal_A3 = optimal_A3,
                  optimal_A2 = optimal_A2,
                  optimal_A1 = optimal_A1)
  return(results)
}

theta_Setting_3 <- function(gamma, mc_n = 1000000){
  
  results <- Q_learning_Setting_3(gamma, mc_n = mc_n)
  theta <- results[[1]]
  
  return(theta)
}


optim_Setting_3 <- function(gamma, theta_target, mc_n = 1000000){
  
  results <- Q_learning_Setting_3(gamma, mc_n = mc_n)
  theta <- results[[1]]
  obj <- sum((theta - theta_target)^2) 
  # obj <- 0
  return(obj)
}

eval_f <- function(x, theta_target, mc_n = 1000000) {
  obj <- as.numeric(optim_Setting_3(x, theta_target, mc_n = mc_n))
  grad <- rep(0, length(x))
  list(objective = obj, gradient = grad)
}

eval_g_eq <- function(x) {
  # theta <- theta_Setting_3(x)
  # c(theta[10] - theta[19],
  #   theta[10] - theta[24],
  #   theta[19] - theta[24],
  #   theta[11] - theta[20],
  #   theta[11] - theta[25],
  #   theta[20] - theta[25],
  #   theta[12] - theta[21])
  numeric(0)
}

candidate_target_tolerance <- 0.03
candidate_constraint_tolerance <- 1e-4

setting3_candidate_indices <- c(10, 19, 24, 11, 20, 25, 12, 21, 13)
setting3_candidate_groups <- list(
  psi0 = c(Q3_A3 = 10, Q2_A2 = 19, Q1_A1 = 24),
  psi1 = c(Q3_O3A3 = 11, Q2_O2A2 = 20, Q1_O1A1 = 25),
  psi2 = c(Q3_A2A3 = 12, Q2_A1A2 = 21),
  psi3 = c(Q3_A1A2A3 = 13)
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

setting3_candidate_constraint_count <- function() {
  2 * length(setting3_candidate_indices) +
    sum(vapply(setting3_candidate_groups, function(group) {
      if (length(group) < 2) 0 else 2 * choose(length(group), 2)
    }, numeric(1)))
}

eval_g_ineq <- function(
  x,
  theta_target_override = theta_target,
  target_tolerance = candidate_target_tolerance,
  mc_n = 1000000
) {
  theta <- theta_Setting_3(x, mc_n = mc_n)
  c(
    target_window_constraints(
      theta,
      theta_target_override,
      setting3_candidate_indices,
      target_tolerance
    ),
    target_difference_constraints(
      theta,
      theta_target_override,
      setting3_candidate_groups,
      target_tolerance
    )
  )
}


eval_jac_g_eq <- function(x) {
  m <- 7         
  n <- length(x)
  matrix(0, nrow = m, ncol = n)
}

eval_jac_g_ineq <- function(x){
  
  m <- setting3_candidate_constraint_count()
  n <- length(x)
  matrix(0, nrow = m, ncol = n)
  
}
## gamma of 10 parameters ##

run_setting3_parameter_search <- function(
  n_starts = 1,
  output_path = file.path(setting3_calibration_dir, "alternative_pars.rds"),
  seed = 4321,
  theta_target_override = theta_target,
  mc_n = 1000000,
  maxeval = 8000,
  local_maxeval = 8000,
  xtol_rel = 1e-4,
  ftol_rel = 1e-4,
  target_tolerance = candidate_target_tolerance,
  constraint_tolerance = candidate_constraint_tolerance,
  print_level = 1
) {
  all_theta <- NULL
  all_gamma <- NULL
  values <- numeric(n_starts)
  gamma_length <- 13
  lb <- rep(-Inf, gamma_length)
  ub <- rep(Inf, gamma_length)

  set.seed(seed)
  for (i in seq_len(n_starts)) {
    gamma_opt <- runif(gamma_length, -1, 1)
    res <- nloptr(
      x0 = gamma_opt,
      eval_f = function(x) eval_f(x, theta_target = theta_target_override, mc_n = mc_n),
      eval_g_ineq = function(x) eval_g_ineq(
        x,
        theta_target_override = theta_target_override,
        target_tolerance = target_tolerance,
        mc_n = mc_n
      ),
      lb = lb,
      ub = ub,
      opts = list(
        algorithm = "NLOPT_LN_COBYLA",
        local_opts = list(
          algorithm = "NLOPT_LN_COBYLA",
          xtol_rel = xtol_rel,
          ftol_rel = ftol_rel,
          maxeval = local_maxeval
        ),
        xtol_rel = xtol_rel,
        ftol_rel = ftol_rel,
        maxeval = maxeval,
        tol_constraints_ineq = rep(
          constraint_tolerance,
          setting3_candidate_constraint_count()
        ),
        print_level = print_level
      )
    )
    print(i)
    all_gamma <- cbind(all_gamma, res$solution)
    test <- Q_learning_Setting_3(res$solution, mc_n = mc_n)
    values[i] <- sum(abs(test$theta - theta_target_override))
    all_theta <- cbind(all_theta, test$theta)
  }

  results <- list(
    theta_target = theta_target_override,
    seed = seed,
    mc_n = mc_n,
    n_starts = n_starts,
    maxeval = maxeval,
    local_maxeval = local_maxeval,
    target_tolerance = target_tolerance,
    constraint_tolerance = constraint_tolerance,
    all_gamma = all_gamma,
    all_theta = all_theta,
    values = values
  )
  saveRDS(results, output_path)
  invisible(results)
}

run_setting3_parameter_specs <- function(
  specs = setting3_parameter_specs,
  output_dir = setting3_calibration_dir,
  mc_n = 5000,
  maxeval = 50,
  local_maxeval = 20,
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
    theta_target_spec <- build_setting3_theta_target(
      psi0_mu = spec$psi0_mu,
      psi1_mu = spec$psi1_mu,
      psi2_mu = spec$psi2_mu,
      psi0_sigma = spec$psi0_sigma,
      psi1_sigma = spec$psi1_sigma,
      psi2_sigma = spec$psi2_sigma
    )
    names(theta_target_spec) <- names(theta_target)
    output_path <- file.path(output_dir, paste0("calibration_", spec_name, ".rds"))

    results <- run_setting3_parameter_search(
      n_starts = n_starts,
      output_path = output_path,
      seed = spec$seed,
      theta_target_override = theta_target_spec,
      mc_n = mc_n,
      maxeval = maxeval,
      local_maxeval = local_maxeval,
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
      target_tolerance = target_tolerance,
      constraint_tolerance = constraint_tolerance,
      n_starts = n_starts,
      sigmas = c(
        psi0 = spec$psi0_sigma,
        psi1 = spec$psi1_sigma,
        psi2 = spec$psi2_sigma
      ),
      theta_target = theta_target_spec,
      best_value = min(results$values),
      best_index = which.min(results$values)
    )
  }

  names(outputs) <- spec_names
  saveRDS(outputs, file.path(output_dir, "parameter_spec_runs.rds"))
  invisible(outputs)
}

if (sys.nframe() == 0) {
  run_setting3_parameter_search()
}
