library(genlasso)
library(Matrix)
library(caret)
library(dplyr)

setting2_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting2"

source(file.path(setting2_dir, "Q_Conventional.R"))
source(file.path(setting2_dir, "Q_SQlearning.R"))
source(file.path(setting2_dir, "Q_SharedQ.R"))
source(file.path(setting2_dir, "Q_L2SQ.R"))
source(file.path(setting2_dir, "Q_datagenerating.R"))
source(file.path(setting2_dir, "nloptr_Setting2.R"))

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

run_cv_grid <- function(
  data_simu,
  warmstart,
  lambdas,
  fit_cv,
  metric,
  nfolds,
  D,
  gamma = NULL,
  max_tries = 10,
  max_iter = 5000,
  tol = 1e-06
) {
  cv_scores <- rep(NA_real_, length(lambdas))

  for (i in seq_along(lambdas)) {
    attempt <- 1
    succeeded <- FALSE

    while (attempt <= max_tries && !succeeded) {
      cv_results <- try(
        if (is.null(gamma)) {
          fit_cv(data_simu, warmstart, lambda = lambdas[i], D = D, nfolds = nfolds, metric = metric,
                 max_iter = max_iter, tol = tol)
        } else {
          fit_cv(data_simu, warmstart, lambda = lambdas[i], gamma = gamma, D = D, nfolds = nfolds, metric = metric,
                 max_iter = max_iter, tol = tol)
        },
        silent = TRUE
      )

      if (!inherits(cv_results, "try-error")) {
        cv_scores[i] <- mean(cv_results$fold_scores, na.rm = TRUE)
        succeeded <- TRUE
      } else {
        message("CV failed for lambda index ", i, " on attempt ", attempt, ". Retrying...")
        attempt <- attempt + 1
      }
    }

    if (!succeeded) {
      message("CV failed for lambda index ", i, " after ", max_tries, " attempts. Setting NA.")
    }
  }

  pick_lambda(lambdas, cv_scores, metric)
}

build_true_D <- function(p) {
  D <- matrix(0, nrow = 3, ncol = p)
  D[1, c(2, 10)] <- c(1, -1)
  D[2, c(6, 11)] <- c(1, -1)
  D[3, c(7, 12)] <- c(1, -1)
  D
}

build_mis_D <- function(p) {
  D <- matrix(0, nrow = 5, ncol = p)
  D[1, c(2, 10)] <- c(1, -1)
  D[2, c(2, 14)] <- c(1, -1)
  D[3, c(10, 14)] <- c(1, -1)
  D[4, c(6, 11)] <- c(1, -1)
  D[5, c(7, 12)] <- c(1, -1)
  D
}

Simu_II <- function(
  n,
  gamma_true,
  theta_true,
  nfolds = 5,
  metric = "MSE",
  lambdas_l1 = exp(seq(-2, 8, length.out = 100)),
  lambdas_l2 = exp(seq(-2, 10, length.out = 100)),
  cv_max_tries = 10,
  max_iter_l1 = 5000,
  max_iter_l2 = 5000
) {
  data_simu <- Generate_data(n)
  data_simu <- prepare_setting2_data(data_simu)

  print("results_1")
  results_1 <- Q_learning(data_simu)
  print("evaluation_1")
  evaluation_1 <- evaluate(results_1, theta_true = theta_true, data_original = data_simu)

  warmstart <- results_1$theta

  print("results_2_CV")
  lambda_final <- run_cv_grid(
    data_simu = data_simu,
    warmstart = warmstart,
    lambdas = lambdas_l1,
    fit_cv = CV_SQlearning,
    metric = metric,
    nfolds = nfolds,
    D = build_true_D(length(warmstart)),
    max_tries = cv_max_tries,
    max_iter = max_iter_l1
  )
  print("results_2")
  results_2 <- SQlearning(data_simu, warmstart = warmstart, lambda = lambda_final,
                          D = build_true_D(length(warmstart)), max_iter = max_iter_l1)
  print("evaluation_2")
  evaluation_2 <- evaluate(results_2, theta_true = theta_true, data_original = data_simu)

  print("results_2_CV_mis")
  lambda_final <- run_cv_grid(
    data_simu = data_simu,
    warmstart = warmstart,
    lambdas = lambdas_l1,
    fit_cv = CV_SQlearning,
    metric = metric,
    nfolds = nfolds,
    D = build_mis_D(length(warmstart)),
    max_tries = cv_max_tries,
    max_iter = max_iter_l1
  )
  print("results_2_mis")
  results_2_mis <- SQlearning(data_simu, warmstart = warmstart, lambda = lambda_final,
                              D = build_mis_D(length(warmstart)), max_iter = max_iter_l1)
  print("evaluation_2_mis")
  evaluation_2_mis <- evaluate(results_2_mis, theta_true = theta_true, data_original = data_simu)

  warm_shared <- c(
    warmstart[c(1, 3, 4, 5, 8, 9, 13, 14)],
    mean(warmstart[c(2, 10)]),
    mean(warmstart[c(6, 11)]),
    mean(warmstart[c(7, 12)])
  )
  print("results_3")
  results_3 <- SharedQ(data_simu, warm_shared)
  print("evaluation_3")
  evaluation_3 <- evaluate(results_3, theta_true = theta_true, data_original = data_simu)

  warm_shared <- c(
    warmstart[c(1, 3, 4, 5, 8, 9, 13)],
    mean(warmstart[c(2, 10, 14)]),
    mean(warmstart[c(6, 11)]),
    mean(warmstart[c(7, 12)])
  )
  print("results_3_mis")
  results_3_mis <- SharedQ_mis(data_simu, warm_shared)
  print("evaluation_3_mis")
  evaluation_3_mis <- evaluate(results_3_mis, theta_true = theta_true, data_original = data_simu)

  print("results_4_CV")
  lambda_final <- run_cv_grid(
    data_simu = data_simu,
    warmstart = warmstart,
    lambdas = lambdas_l2,
    fit_cv = CV_SQlearning_L2,
    metric = metric,
    nfolds = nfolds,
    D = build_true_D(length(warmstart)),
    gamma = 0,
    max_tries = cv_max_tries,
    max_iter = max_iter_l2
  )
  print("results_4")
  results_4 <- SQlearning_L2(
    data_simu,
    warmstart = warmstart,
    lambda = lambda_final,
    D = build_true_D(length(warmstart)),
    gamma = 0,
    max_iter = max_iter_l2
  )
  print("evaluation_4")
  evaluation_4 <- evaluate(results_4, theta_true = theta_true, data_original = data_simu)

  print("results_4_CV_mis")
  lambda_final <- run_cv_grid(
    data_simu = data_simu,
    warmstart = warmstart,
    lambdas = lambdas_l2,
    fit_cv = CV_SQlearning_L2,
    metric = metric,
    nfolds = nfolds,
    D = build_mis_D(length(warmstart)),
    gamma = 0,
    max_tries = cv_max_tries,
    max_iter = max_iter_l2
  )
  print("results_4_mis")
  results_4_mis <- SQlearning_L2(
    data_simu,
    warmstart = warmstart,
    lambda = lambda_final,
    D = build_mis_D(length(warmstart)),
    gamma = 0,
    max_iter = max_iter_l2
  )
  print("evaluation_4_mis")
  evaluation_4_mis <- evaluate(results_4_mis, theta_true = theta_true, data_original = data_simu)

  list(
    results_1 = results_1,
    results_2 = results_2,
    results_2_mis = results_2_mis,
    results_3 = results_3,
    results_3_mis = results_3_mis,
    results_4 = results_4,
    results_4_mis = results_4_mis,
    evaluation_1 = evaluation_1,
    evaluation_2 = evaluation_2,
    evaluation_2_mis = evaluation_2_mis,
    evaluation_3 = evaluation_3,
    evaluation_3_mis = evaluation_3_mis,
    evaluation_4 = evaluation_4,
    evaluation_4_mis = evaluation_4_mis
  )
}

evaluate <- function(results, theta_true, data_original) {
  data_original <- prepare_setting2_data(data_original)
  Y <- data_original$Y
  theta_true_Q3 <- theta_true[1:8]
  theta_true_Q2 <- theta_true[9:12]
  theta_true_Q1 <- theta_true[13:14]

  A3_block <- dplyr::select(data_original, A3, A1A3, A2A3)
  b3 <- theta_true_Q3[c("A3", "A1A3", "A2A3")]
  real_A3 <- as.numeric(as.matrix(A3_block) %*% b3)
  pseudo_A3 <- as.numeric(as.matrix(-A3_block) %*% b3)
  max_A3 <- pmax(real_A3, pseudo_A3)

  optimal_A3 <- ifelse(real_A3 >= pseudo_A3, data_original$A3, -data_original$A3)
  optimal_A3 <- data_original$G2 * optimal_A3 + (1 - data_original$G2) * data_original$A3
  Y_optimal_Q3 <- data_original$G2 * (Y - real_A3 + max_A3) + (1 - data_original$G2) * Y

  A2_block <- dplyr::select(data_original, A2, A1A2)
  b2 <- theta_true_Q2[c("A2", "A1A2")]
  real_A2 <- as.numeric(as.matrix(A2_block) %*% b2)
  pseudo_A2 <- as.numeric(as.matrix(-A2_block) %*% b2)
  max_A2 <- pmax(real_A2, pseudo_A2)

  optimal_A2 <- ifelse(real_A2 >= pseudo_A2, data_original$A2, -data_original$A2)
  optimal_A2 <- data_original$G1 * optimal_A2 + (1 - data_original$G1) * data_original$A2
  Y_optimal_Q2 <- data_original$G1 * (Y_optimal_Q3 - real_A2 + max_A2) +
    (1 - data_original$G1) * Y_optimal_Q3

  optimal_A1 <- rep(sign(theta_true_Q1["A1"]), nrow(data_original))

  true_allocation <- cbind(optimal_A1, optimal_A2, optimal_A3)
  result_allocation <- cbind(results$optimal_A1, results$optimal_A2, results$optimal_A3)
  row_equal <- apply(true_allocation == result_allocation, 1, all)

  A1_bias <- results$theta[names(theta_true) == "A1"] - theta_true[names(theta_true) == "A1"]
  A3_bias <- results$theta[names(theta_true) == "A3"] - theta_true[names(theta_true) == "A3"]
  A2_bias <- results$theta[names(theta_true) == "A2"] - theta_true[names(theta_true) == "A2"]
  A1A3_bias <- results$theta[names(theta_true) == "A1A3"] - theta_true[names(theta_true) == "A1A3"]
  A1A2_bias <- results$theta[names(theta_true) == "A1A2"] - theta_true[names(theta_true) == "A1A2"]

  M <- mean(row_equal)
  M_weighted <- (
    sum(result_allocation[data_original$G2 == 1, 3] == true_allocation[data_original$G2 == 1, 3]) +
      sum(result_allocation[data_original$G1 == 1, 2] == true_allocation[data_original$G1 == 1, 2]) +
      sum(result_allocation[, 1] == true_allocation[, 1])
  ) / sum(c(data_original$G2 == 1, data_original$G1 == 1, nrow(data_original)))

  list(
    M = M,
    M_weighted = M_weighted,
    A3_bias = A3_bias,
    A2_bias = A2_bias,
    A1_bias = A1_bias,
    A1A3_bias = A1A3_bias,
    A1A2_bias = A1A2_bias
  )
}
