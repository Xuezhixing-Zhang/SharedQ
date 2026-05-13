## ------------------------------------------------------------
## Load results
## ------------------------------------------------------------
source("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared/Q_functions.R")
pars <- readRDS("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared/calibration/alternative_pars.rds")
gamma_true <- pars$all_gamma[,which.min(pars$values)]
theta_true <- pars$all_theta[,which.min(pars$values)]
theta_true
results <- readRDS("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared/simulation_results/results_300.rds")

# warm_shared <- c(
#   theta_true[c(1:9, 13:18, 22, 23)],              # 17 unshared, in order
#   mean(theta_true[c(10, 19, 24)]),                 # shared decision main
#   mean(theta_true[c(11, 20, 25)]),                 # shared obs×decision
#   mean(theta_true[c(12, 21)])                      # shared prev×decision
# )
# warm_shared <- c(
#   theta_true[c(1, 2, 5, 9, 10, 11, 12, 13,   # Q3 unshared
#               14, 15, 18,                    # Q2 unshared
#               22, 23)],                      # Q1 unshared
#   mean(theta_true[c(3, 16, 24)]),             # A1 Q3,Q2,Q1
#   mean(theta_true[c(4, 17, 25)]),             # O1:A1 Q3,Q2,Q1
#   mean(theta_true[c(6, 19)]),                 # A2 Q3,Q2
#   mean(theta_true[c(7, 20)]),                 # O2:A2 Q3,Q2
#   mean(theta_true[c(8, 21)])                  # A1:A2 Q3,Q2
# )
## ------------------------------------------------------------
## Pre-allocate objects (your originals, with name fixes)
## ------------------------------------------------------------
lambdas <- NULL
FPs_S2  <- NULL

Ms_S1 <- Ms_S2 <- Ms_S3 <- Ms_S2_mis <- Ms_S3_mis <- 
  Ms_weighted_S1 <- Ms_weighted_S2 <- Ms_weighted_S3 <- Ms_weighted_S2_mis <- Ms_weighted_S3_mis <- 
  A3_bias_S1 <- A3_bias_S2 <- A3_bias_S3 <- A3_bias_S2_mis <- A3_bias_S3_mis <- 
  O3A3_bias_S1 <- O3A3_bias_S2 <- O3A3_bias_S3 <- O3A3_bias_S2_mis <- O3A3_bias_S3_mis <- NULL

A2_bias_S1 <- A2_bias_S2 <- A2_bias_S3 <- A2_bias_S2_mis <- A2_bias_S3_mis <- 
  A1_bias_S1 <- A1_bias_S2 <- A1_bias_S3 <- A1_bias_S2_mis <- A1_bias_S3_mis <- NULL

n_sim <- length(results)

## ------------------------------------------------------------
## NEW: storage for bias of truly shared parameters
## columns are the same for all, but S1 will only fill the S1 slots
## ------------------------------------------------------------
shared_bias_S1     <- matrix(NA_real_, nrow = n_sim, ncol = 8)
shared_bias_S2     <- matrix(NA_real_, nrow = n_sim, ncol = 8)
shared_bias_S3     <- matrix(NA_real_, nrow = n_sim, ncol = 8)

colnames(shared_bias_S1) <- colnames(shared_bias_S2) <- 
  colnames(shared_bias_S3) <- c(
    "A3(S1)", "A2(S2)", "A1(S3)",
    "O3A3(S1)", "O2A2(S2)", "O1A1(S3)",
    "A2A3(S1)", "A1A2(S2)"
  )

## ------------------------------------------------------------
## Main loop
## ------------------------------------------------------------
for(i in 1:length(results)){
  
  ## --- Scenario 1 ---
  Ms_S1[i]            <- results[[i]]$evaluation_1$M
  Ms_weighted_S1[i]   <- results[[i]]$evaluation_1$M_weighted
  # A3_bias_S1[i]       <- results[[i]]$evaluation_1$A3_bias
  # your original code used A1A3_bias here, but we aligned to O3A3_bias
  # O3A3_bias_S1[i]     <- results[[i]]$evaluation_1$O3A3_bias
  # A2_bias_S1          <- cbind(A2_bias_S1, results[[i]]$evaluation_1$A2_bias)
  # A1_bias_S1          <- cbind(A1_bias_S1, results[[i]]$evaluation_1$A1_bias)
  
  ## NEW: S1 contribution to shared-parameter bias
  ## fill only the S1 pieces: A3(S1), O3A3(S1), A2A3(S1)
  shared_bias_S1[i, ] <- c(
    results[[i]]$evaluation_1$A3_bias,  # A3(S1)
    results[[i]]$evaluation_1$A2_bias,                           # A2(S2) not in S1
    results[[i]]$evaluation_1$A1_bias,                           # A1(S3) not in S1
    results[[i]]$evaluation_1$O3A3_bias,# O3A3(S1)
    results[[i]]$evaluation_1$O2A2_bias,                           # O2A2(S2)
    results[[i]]$evaluation_1$O1A1_bias,                           # O1A1(S3)
    results[[i]]$evaluation_1$A2A3_bias,# A2A3(S1)
    results[[i]]$evaluation_1$A1A2_bias                          # A1A2(S2)
  )
  
  ## --- Scenario 2 ---
  FPs_S2[i] <- sum(round(results[[i]]$results_2$theta[c(10,10,19,11,11,20,12)],5) == 
                     round(results[[i]]$results_2$theta[c(19,24,24,20,25,25,21)],5))
  
  
  Ms_S2[i]            <- results[[i]]$evaluation_2$M
  Ms_weighted_S2[i]   <- results[[i]]$evaluation_2$M_weighted
  # A3_bias_S2[i]       <- results[[i]]$evaluation_2$A3_bias
  # O3A3_bias_S2[i]     <- results[[i]]$evaluation_2$O3A3_bias
  # A2_bias_S2          <- cbind(A2_bias_S2, results[[i]]$evaluation_2$A2_bias)
  # A1_bias_S2          <- cbind(A1_bias_S2, results[[i]]$evaluation_2$A1_bias)
  
  ev2 <- evaluate_bias(results[[i]]$results_2, theta_true)
  shared_bias_S2[i, ] <- c(
    ev2$A3_bias,
    ev2$A2_bias,
    ev2$A1_bias,
    ev2$O3A3_bias,
    ev2$O2A2_bias,
    ev2$O1A1_bias,
    ev2$A2A3_bias,
    ev2$A1A2_bias
  )
  
  
  ## --- Scenario 3 ---
  Ms_S3[i]            <- results[[i]]$evaluation_3$M
  Ms_weighted_S3[i]   <- results[[i]]$evaluation_3$M_weighted
  
  ev3 <- evaluate_bias(results[[i]]$results_3, theta_true)
  shared_bias_S3[i, ] <- c(
    ev3$A3_bias,
    ev3$A2_bias,
    ev3$A1_bias,
    ev3$O3A3_bias,
    ev3$O2A2_bias,
    ev3$O1A1_bias,
    ev3$A2A3_bias,
    ev3$A1A2_bias
  )
  
}

## ------------------------------------------------------------
## Helper formatters
## ------------------------------------------------------------
fmt <- function(x) sprintf("%.3f (%.3f)", mean(x, na.rm = TRUE), sd(x, na.rm = TRUE))

fmt_row <- function(mat) sprintf("%.3f (%.3f)",
                                 rowMeans(mat, na.rm = TRUE),
                                 apply(mat, 1, sd, na.rm = TRUE))

fmt_col <- function(mat) sprintf("%.3f (%.3f)",
                                 colMeans(mat, na.rm = TRUE),
                                 apply(mat, 2, sd, na.rm = TRUE))

## ------------------------------------------------------------
## Scalar-style summary (with correct names)
## ------------------------------------------------------------
summary_results <- data.frame(
  Measure = c("Ms", "Ms_weighted"),
  S1      = c(fmt(Ms_S1), fmt(Ms_weighted_S1)),
  S2      = c(fmt(Ms_S2), fmt(Ms_weighted_S2)),
  S3      = c(fmt(Ms_S3), fmt(Ms_weighted_S3)),
  stringsAsFactors = FALSE
)

## ------------------------------------------------------------
## Matrix-type summaries (A1, A2 bias by level)
## ------------------------------------------------------------
# A1_bias_summary <- data.frame(
#   S1     = fmt_row(A1_bias_S1),
#   S2     = fmt_row(A1_bias_S2),
#   S2_mis = fmt_row(A1_bias_S2_mis),
#   S3     = fmt_row(A1_bias_S3),
#   S3_mis = fmt_row(A1_bias_S3_mis)
# )

# A2_bias_summary <- data.frame(
#   S1     = fmt_row(A2_bias_S1),
#   S2     = fmt_row(A2_bias_S2),
#   S2_mis = fmt_row(A2_bias_S2_mis),
#   S3     = fmt_row(A2_bias_S3),
#   S3_mis = fmt_row(A2_bias_S3_mis)
# )

## ------------------------------------------------------------
## NEW: summarize bias for truly shared parameters (now including S1)
## ------------------------------------------------------------
shared_bias_summary <- data.frame(
  Param  = colnames(shared_bias_S1),
  S1     = fmt_col(shared_bias_S1),
  S2     = fmt_col(shared_bias_S2),
  S3     = fmt_col(shared_bias_S3),
  stringsAsFactors = FALSE
)

## ------------------------------------------------------------
## TP / FP summaries
## ------------------------------------------------------------
FPs_S2_mean      <- mean(FPs_S2);     FPs_S2_sd      <- sd(FPs_S2)

## ------------------------------------------------------------
## Print
## ------------------------------------------------------------
print(summary_results, row.names = FALSE)
# print(head(A1_bias_summary))
# print(head(A2_bias_summary))
print(shared_bias_summary, row.names = FALSE)

cat("FPs S2: mean =", FPs_S2_mean, "sd =", FPs_S2_sd, "\n")
