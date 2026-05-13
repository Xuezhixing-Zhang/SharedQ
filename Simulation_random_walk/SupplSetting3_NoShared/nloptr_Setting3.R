library(dplyr)
library(nloptr)
suppl_setting3_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared"
suppl_setting3_calibration_dir <- file.path(suppl_setting3_dir, "calibration")
dir.create(suppl_setting3_calibration_dir, showWarnings = FALSE, recursive = TRUE)
################## Supplementary Setting III No Shared 3 stage #################
## Continuous-covariate Setting III data mechanism with separated decision effects.

build_setting3_theta_target <- function(
  q3_a3 = -0.75,
  q2_a2 = 0.35,
  q1_a1 = 0.90,
  q3_o3a3 = 0.70,
  q2_o2a2 = -0.35,
  q1_o1a1 = 0.15,
  q3_a2a3 = -0.60,
  q2_a1a2 = 0.55,
  q3_a1a2a3 = 0.45
) {
  c(
    # Q3
    0.10, 0.25, 0.50, 0.15, 0.60, 0.25, 0.20, 0.45, 0.40,
    q3_a3,
    q3_o3a3,
    q3_a2a3,
    q3_a1a2a3,
    # Q2
    0.20, 0.25, 0.35, 0.15, 0.70,
    q2_a2,
    q2_o2a2,
    q2_a1a2,
    # Q1
    0.40, 0.50,
    q1_a1,
    q1_o1a1
  )
}

theta_target <- build_setting3_theta_target()
names(theta_target) <- c("Q3_intercept","Q3_O1","Q3_A1","Q3_O1A1","Q3_O2","Q3_A2","Q3_O2A2","Q3_A1A2","Q3_O3","Q3_A3_psi0","Q3_O3A3_psi1","Q3_A2A3_psi2","Q3_A1A2A3_psi3",
                         "Q2_intercept","Q2_O1","Q2_A1","Q2_O1A1","Q2_O2","Q2_A2_psi0","Q2_O2A2_psi1","Q2_A1A2_psi2",
                         "Q1_intercept","Q1_O1","Q1_A1_psi0","Q1_O1A1_psi1")

setting3_parameter_specs <- list(
  separated_moderate = list(
    description = "No-sharing target with moderate separation across decision-effect analogues.",
    seed = 501,
    q3_a3 = -0.75,
    q2_a2 = 0.35,
    q1_a1 = 0.90,
    q3_o3a3 = 0.70,
    q2_o2a2 = -0.35,
    q1_o1a1 = 0.15,
    q3_a2a3 = -0.60,
    q2_a1a2 = 0.55,
    q3_a1a2a3 = 0.45
  ),
  separated_reversed = list(
    description = "No-sharing target with reversed signs among stage analogues.",
    seed = 502,
    q3_a3 = 0.80,
    q2_a2 = -0.45,
    q1_a1 = 0.20,
    q3_o3a3 = -0.65,
    q2_o2a2 = 0.40,
    q1_o1a1 = -0.10,
    q3_a2a3 = 0.55,
    q2_a1a2 = -0.50,
    q3_a1a2a3 = 0.35
  ),
  separated_large = list(
    description = "No-sharing target with larger cross-stage separation.",
    seed = 503,
    q3_a3 = -1.00,
    q2_a2 = 0.55,
    q1_a1 = 1.20,
    q3_o3a3 = 0.90,
    q2_o2a2 = -0.55,
    q1_o1a1 = 0.05,
    q3_a2a3 = -0.85,
    q2_a1a2 = 0.75,
    q3_a1a2a3 = 0.60
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
    suppl_setting3_calibration_dir,
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
    saveRDS(data_original, file.path(suppl_setting3_calibration_dir, "data_original.rds"))
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


eval_g_ineq <- function(x, mc_n = 1000000) {
  numeric(0)
}


eval_jac_g_eq <- function(x) {
  m <- 7         
  n <- length(x)
  matrix(0, nrow = m, ncol = n)
}

eval_jac_g_ineq <- function(x){
  
  m <- 8
  n <- length(x)
  matrix(0, nrow = m, ncol = n)
  
}
## gamma of 10 parameters ##

run_setting3_parameter_search <- function(
  n_starts = 1,
  output_path = file.path(suppl_setting3_calibration_dir, "alternative_pars.rds"),
  seed = 4321,
  theta_target_override = theta_target,
  mc_n = 1000000,
  maxeval = 8000,
  local_maxeval = 8000,
  xtol_rel = 1e-4,
  ftol_rel = 1e-4,
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
      eval_g_ineq = function(x) eval_g_ineq(x, mc_n = mc_n),
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
        tol_constraints_ineq = numeric(0),
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
    all_gamma = all_gamma,
    all_theta = all_theta,
    values = values
  )
  saveRDS(results, output_path)
  invisible(results)
}

run_setting3_parameter_specs <- function(
  specs = setting3_parameter_specs,
  output_dir = suppl_setting3_calibration_dir,
  mc_n = 5000,
  maxeval = 50,
  local_maxeval = 20,
  n_starts = 1,
  print_level = 0
) {
  outputs <- vector("list", length(specs))
  spec_names <- names(specs)

  for (i in seq_along(specs)) {
    spec_name <- spec_names[i]
    spec <- specs[[i]]
    theta_target_spec <- build_setting3_theta_target(
      q3_a3 = spec$q3_a3,
      q2_a2 = spec$q2_a2,
      q1_a1 = spec$q1_a1,
      q3_o3a3 = spec$q3_o3a3,
      q2_o2a2 = spec$q2_o2a2,
      q1_o1a1 = spec$q1_o1a1,
      q3_a2a3 = spec$q3_a2a3,
      q2_a1a2 = spec$q2_a1a2,
      q3_a1a2a3 = spec$q3_a1a2a3
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
      n_starts = n_starts,
      separated_effects = c(
        q3_a3 = spec$q3_a3,
        q2_a2 = spec$q2_a2,
        q1_a1 = spec$q1_a1,
        q3_o3a3 = spec$q3_o3a3,
        q2_o2a2 = spec$q2_o2a2,
        q1_o1a1 = spec$q1_o1a1,
        q3_a2a3 = spec$q3_a2a3,
        q2_a1a2 = spec$q2_a1a2,
        q3_a1a2a3 = spec$q3_a1a2a3
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
