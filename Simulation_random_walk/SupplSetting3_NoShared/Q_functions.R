Q_learning_Setting_3 <- function(gamma_start, save = F){
  
  
  set.seed(4321)
  ## Generate Simulation Data based on gamma ##
  # Specify a large sample size
  gamma <- gamma_start
  d21 <- 0.60; d22 <- 0.80
  d31 <- 0.50; d32 <- 0.40; d33 <- 0.60
  n <- 1000000
  
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
    dir.create("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared/calibration", showWarnings = FALSE, recursive = TRUE)
    saveRDS(data_original, "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared/calibration/data_original.rds")
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


##################################################################################
library(genlasso)
library(Matrix)
library(caret)
source("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared/Q_datagenerating.R")
source("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared/Q_learning.R")
source("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared/Q_SQlearning.R")
source("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared/Q_SharedQ.R")
source("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared/Q_L2SQ.R")

pick_lambda <- function(lambdas, cv_scores, metric) {
  valid <- which(!is.na(cv_scores))
  if (length(valid) == 0L) {
    warning("Cross-validation failed for all lambda values. Falling back to the first lambda.")
    return(lambdas[1])
  }

  if (metric %in% c("MSE", "MSE_Q")) {
    lambdas[valid[which.min(cv_scores[valid])]]
  } else {
    lambdas[valid[which.max(cv_scores[valid])]]
  }
}

Simu_III <- function(
  n,
  theta_true,
  nfolds = 5,
  metric = "MSE",
  lambdas = exp(seq(-2, 5, length.out = 100)),
  cv_max_tries = 10,
  max_iter_l1 = 5000,
  max_iter_l2 = 5000
){
  
  ## Results 1
  data_simu <- Generate_data(n)
  dir.create("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared/test_results", showWarnings = FALSE, recursive = TRUE)
  saveRDS(data_simu, "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared/test_results/temp.rds")
  print("results_1")
  results_1 <- Q_learning(data_simu)
  print("evaluation_1")
  evaluation_1 <- evaluate(results_1, theta_true = theta_true, data_original =data_simu)
  
  ## Results 2
  warmstart <- results_1$theta
  bad_warmstart <- is.na(warmstart) | is.nan(warmstart) | is.infinite(warmstart)
  if (any(bad_warmstart)) {
    warmstart[bad_warmstart] <- 0
    warning("Conventional warm start contained non-finite coefficients; replaced them with zero.")
  }
  cv_scores <- NULL
  
  ## True Case D
  p <- 25
  D <- matrix(0, nrow = 7, ncol = p)
  
  ## 1) decision main effects: A3, A2, A1
  # A3 (Q3) - A2 (Q2)
  D[1, c(10, 19)] <- c(1, -1)
  # A3 (Q3) - A1 (Q1)
  D[2, c(10, 24)] <- c(1, -1)
  # A2 (Q2) - A1 (Q1)
  D[3, c(19, 24)] <- c(1, -1)
  
  ## 2) decision × current observation: O3:A3, O2:A2, O1:A1
  # O3:A3 (Q3) - O2:A2 (Q2)
  D[4, c(11, 20)] <- c(1, -1)
  # O3:A3 (Q3) - O1:A1 (Q1)
  D[5, c(11, 25)] <- c(1, -1)
  # O2:A2 (Q2) - O1:A1 (Q1)
  D[6, c(20, 25)] <- c(1, -1)
  
  ## 3) decision × previous action: A2:A3 (Q3), A1:A2 (Q2)
  # A2:A3 (Q3) - A1:A2 (Q2)
  D[7, c(12, 21)] <- c(1, -1)
  
  print("results_2_CV")
  for(i in 1:length(lambdas)){
    max_tries <- cv_max_tries
    attempt <- 1
    succeeded <- FALSE
    
    while (attempt <= max_tries && !succeeded) {
      cv_results <- try(
        CV_SQlearning(
          data_simu,
          warmstart,
          lambda = lambdas[i],
          D = D,
          nfolds = nfolds,
          metric = metric,
          max_iter = max_iter_l1
        ),
        silent = TRUE
      )
      
      if (!inherits(cv_results, "try-error")) {
        cv_scores[i] <- mean(cv_results$fold_scores)
        succeeded <- TRUE
      } else {
        message("CV failed for lambda index ", i,
                " on attempt ", attempt, ". Retrying...")
        attempt <- attempt + 1
      }
    }
    
    if (!succeeded) {
      message("CV failed for lambda index ", i,
              " after ", max_tries, " attempts. Setting NA.")
      cv_scores[i] <- NA_real_
    }
  }
  print("results_2")
  
  lambda_final <- pick_lambda(lambdas, cv_scores, metric)
  results_2 <- SQlearning(data_simu, warmstart = warmstart, lambda = lambda_final, D, max_iter = max_iter_l1)
  results_2$theta
  
  print("evaluation_2")
  evaluation_2 <- evaluate(results_2, theta_true = theta_true, data_original =data_simu)
  
  
  ## Results 3
  ## True Case
  warm_shared <- c(
    warmstart[c(1:9, 13:18, 22, 23)],              # 17 unshared, in order
    mean(warmstart[c(10, 19, 24)]),                 # shared decision main
    mean(warmstart[c(11, 20, 25)]),                 # shared obs×decision
    mean(warmstart[c(12, 21)])                      # shared prev×decision
  )
  
  print("results_3")
  results_3 <- SharedQ(data_simu, warm_shared)
  
  print("evaluation_3")
  evaluation_3 <- evaluate(results_3, theta_true = theta_true, data_original =data_simu)
  
  
  ## Results 4
  warmstart <- results_1$theta
  cv_scores <- NULL
  
  ## True Case D
  p <- 25
  D <- matrix(0, nrow = 7, ncol = p)
  
  ## 1) decision main effects: A3, A2, A1
  # A3 (Q3) - A2 (Q2)
  D[1, c(10, 19)] <- c(1, -1)
  # A3 (Q3) - A1 (Q1)
  D[2, c(10, 24)] <- c(1, -1)
  # A2 (Q2) - A1 (Q1)
  D[3, c(19, 24)] <- c(1, -1)
  
  ## 2) decision × current observation: O3:A3, O2:A2, O1:A1
  # O3:A3 (Q3) - O2:A2 (Q2)
  D[4, c(11, 20)] <- c(1, -1)
  # O3:A3 (Q3) - O1:A1 (Q1)
  D[5, c(11, 25)] <- c(1, -1)
  # O2:A2 (Q2) - O1:A1 (Q1)
  D[6, c(20, 25)] <- c(1, -1)
  
  ## 3) decision × previous action: A2:A3 (Q3), A1:A2 (Q2)
  # A2:A3 (Q3) - A1:A2 (Q2)
  D[7, c(12, 21)] <- c(1, -1)
  
  print("results_4_CV")
  for(i in 1:length(lambdas)){
    max_tries <- cv_max_tries
    attempt <- 1
    succeeded <- FALSE
    
    while (attempt <= max_tries && !succeeded) {
      cv_results <- try(
        CV_SQlearning_L2(
          data_simu,
          warmstart,
          lambda = lambdas[i],
          D = D,
          gamma = 0,
          nfolds = nfolds,
          metric = metric,
          max_iter = max_iter_l2
        ),
        silent = TRUE
      )
      
      if (!inherits(cv_results, "try-error")) {
        cv_scores[i] <- mean(cv_results$fold_scores)
        succeeded <- TRUE
      } else {
        message("CV failed for lambda index ", i,
                " on attempt ", attempt, ". Retrying...")
        attempt <- attempt + 1
      }
    }
    
    if (!succeeded) {
      message("CV failed for lambda index ", i,
              " after ", max_tries, " attempts. Setting NA.")
      cv_scores[i] <- NA_real_
    }
  }
  print("results_4")
  
  lambda_final <- pick_lambda(lambdas, cv_scores, metric)
  results_4 <- SQlearning_L2(data_simu, warmstart = warmstart, lambda = lambda_final, D=D, gamma = 0, max_iter = max_iter_l2)
  results_4$theta
  
  print("evaluation_4")
  evaluation_4 <- evaluate(results_4, theta_true = theta_true, data_original =data_simu)
  
  ########################
  return(results = list(results_1 = results_1,
                        results_2 = results_2,
                        results_3 = results_3,
                        results_4 = results_4,
                        evaluation_1 = evaluation_1, 
                        evaluation_2 = evaluation_2, 
                        evaluation_3 = evaluation_3,
                        evaluation_4 = evaluation_4))
  
}


####################################################################################
evaluate <- function(results, theta_true, data_original){
  
  Y <- data_original$Y
  theta_true_Q3 <- theta_true[1:13]
  theta_true_Q2 <- theta_true[14:21]
  theta_true_Q1 <- theta_true[22:25]
  
  ## Q3
  A3_block <- cbind(A3 = data_original$A3,
                    `O3:A3` = data_original$O3 * data_original$A3,
                    `A2:A3` = data_original$A2 * data_original$A3,
                    `A1:A2:A3` = data_original$A1 * data_original$A2 * data_original$A3)
  b3 <- theta_true_Q3[c("A3","O3:A3","A2:A3","A1:A2:A3")]
  real_A3 <- as.numeric(as.matrix(A3_block) %*% b3)
  pseudo_A3 <- as.numeric(as.matrix(-A3_block) %*% b3)
  max_A3 <- pmax(real_A3, pseudo_A3)
  optimal_A3 <- ifelse(real_A3 >= pseudo_A3, data_original$A3, -data_original$A3)
  Y_optimal_Q3 <- ifelse(data_original$R2 == 0 & data_original$R1 == 0, Y - real_A3 + max_A3, Y)
  
  ## Q2
  A2_block <- cbind(A2 = data_original$A2,
                    `O2:A2` = data_original$O2 * data_original$A2,
                    `A1:A2` = data_original$A1 * data_original$A2)
  b2 <- theta_true_Q2[c("A2","O2:A2","A1:A2")]
  real_A2 <- as.numeric(as.matrix(A2_block) %*% b2)
  pseudo_A2 <- as.numeric(as.matrix(-A2_block) %*% b2)
  max_A2 <- pmax(real_A2, pseudo_A2)
  optimal_A2 <- ifelse(real_A2 >= pseudo_A2, data_original$A2, -data_original$A2)
  Y_optimal_Q2 <- ifelse(data_original$R1 == 0, Y_optimal_Q3 - real_A2 + max_A2, Y_optimal_Q3)
  
  ## Q1
  A1_block <- cbind(A1 = data_original$A1,
                    `O1:A1` = data_original$O1 * data_original$A1)
  b1 <- theta_true_Q1[c("A1","O1:A1")]
  real_A1 <- as.numeric(as.matrix(A1_block) %*% b1)
  pseudo_A1 <- as.numeric(as.matrix(-A1_block) %*% b1)
  optimal_A1 <- ifelse(real_A1 >= pseudo_A1, data_original$A1, -data_original$A1)
  
  ### Check Allocation
  true_allocation <- cbind(optimal_A1, optimal_A2, optimal_A3)
  result_allocation <- cbind(results$optimal_A1, results$optimal_A2, results$optimal_A3)
  row_equal <- apply(true_allocation == result_allocation, 1, all)
  
  M <- mean(row_equal)
  M_weighted <- (
    sum(result_allocation[data_original$R2 == 0 & data_original$R1 == 0, 3] == true_allocation[data_original$R2 == 0 & data_original$R1 == 0, 3]) +
      sum(result_allocation[data_original$R1 == 0, 2] == true_allocation[data_original$R1 == 0, 2]) +
      sum(result_allocation[, 1] == true_allocation[, 1])
  ) / (
    sum(data_original$R2 == 0 & data_original$R1 == 0) + sum(data_original$R1 == 0) + nrow(data_original)
  )
  
  if ("Q1_fit" %in% names(results)) {
    A1_bias      <- coef(results$Q1_fit)["A1"]        - theta_true[24]
    O1A1_bias    <- coef(results$Q1_fit)["O1:A1"]     - theta_true[25]
    A2_bias      <- coef(results$Q2_fit)["A2"]        - theta_true[19]
    O2A2_bias    <- coef(results$Q2_fit)["O2:A2"]     - theta_true[20]
    A1A2_bias    <- coef(results$Q2_fit)["A1:A2"]     - theta_true[21]
    A3_bias      <- coef(results$Q3_fit)["A3"]        - theta_true[10]
    O3A3_bias    <- coef(results$Q3_fit)["O3:A3"]     - theta_true[11]
    A2A3_bias    <- coef(results$Q3_fit)["A2:A3"]     - theta_true[12]
    A1A2A3_bias  <- coef(results$Q3_fit)["A1:A2:A3"]  - theta_true[13]
  } else {
    A1_bias      <- results$theta[24] - theta_true[24]
    O1A1_bias    <- results$theta[25] - theta_true[25]
    A2_bias      <- results$theta[19] - theta_true[19]
    O2A2_bias    <- results$theta[20] - theta_true[20]
    A1A2_bias    <- results$theta[21] - theta_true[21]
    A3_bias      <- results$theta[10] - theta_true[10]
    O3A3_bias    <- results$theta[11] - theta_true[11]
    A2A3_bias    <- results$theta[12] - theta_true[12]
    A1A2A3_bias  <- results$theta[13] - theta_true[13]
  }
  
  list(M = M, M_weighted = M_weighted,
       A1_bias = A1_bias, O1A1_bias = O1A1_bias,
       A2_bias = A2_bias, O2A2_bias = O2A2_bias, A1A2_bias = A1A2_bias,
       A3_bias = A3_bias, O3A3_bias = O3A3_bias, A2A3_bias = A2A3_bias, A1A2A3_bias = A1A2A3_bias)
}

evaluate_bias <- function(results, theta_true){
  
  if ("Q1_fit" %in% names(results)) {
    A1_bias      <- coef(results$Q1_fit)["A1"]        - theta_true[24]
    O1A1_bias    <- coef(results$Q1_fit)["O1:A1"]     - theta_true[25]
    A2_bias      <- coef(results$Q2_fit)["A2"]        - theta_true[19]
    O2A2_bias    <- coef(results$Q2_fit)["O2:A2"]     - theta_true[20]
    A1A2_bias    <- coef(results$Q2_fit)["A1:A2"]     - theta_true[21]
    A3_bias      <- coef(results$Q3_fit)["A3"]        - theta_true[10]
    O3A3_bias    <- coef(results$Q3_fit)["O3:A3"]     - theta_true[11]
    A2A3_bias    <- coef(results$Q3_fit)["A2:A3"]     - theta_true[12]
    A1A2A3_bias  <- coef(results$Q3_fit)["A1:A2:A3"]  - theta_true[13]
  } else {
    A1_bias      <- results$theta[24] - theta_true[24]
    O1A1_bias    <- results$theta[25] - theta_true[25]
    A2_bias      <- results$theta[19] - theta_true[19]
    O2A2_bias    <- results$theta[20] - theta_true[20]
    A1A2_bias    <- results$theta[21] - theta_true[21]
    A3_bias      <- results$theta[10] - theta_true[10]
    O3A3_bias    <- results$theta[11] - theta_true[11]
    A2A3_bias    <- results$theta[12] - theta_true[12]
    A1A2A3_bias  <- results$theta[13] - theta_true[13]
  }
  
  list(A1_bias = A1_bias, O1A1_bias = O1A1_bias,
       A2_bias = A2_bias, O2A2_bias = O2A2_bias, A1A2_bias = A1A2_bias,
       A3_bias = A3_bias, O3A3_bias = O3A3_bias, A2A3_bias = A2A3_bias, A1A2A3_bias = A1A2A3_bias)
  
  
}
