## Evaluation
# results <- readRDS("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting1/simulation_results/results_500.rds")
results <- readRDS("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting1/simulation_results/results_100.rds")
results <- results[!sapply(results, is.null)]

# evaluate(results[[1]]$results_1, theta_true = theta_true, data_original =data_simu)
# S1: Conventional Q learning
# S2: SQ learning L1 penalty
# S3: Shared Q learning
# S4: SQ learning L2 penalty
## True shared relationships: 
### A1 for stage 2 and 3. 
### A3 at Stage 3 and A2 at Stage 2. 
### A1A2 and A1A3
lambdas <- NULL
TPs_S2 <- FPs_S2  <-NULL
TPs_S2_mis <- FPs_S2_mis <- NULL

Ms_S1 <- Ms_S2 <- Ms_S3 <- Ms_S2_mis <- Ms_S3_mis <- Ms_S4 <- Ms_S4_mis <- 
  Ms_weighted_S1 <- Ms_weighted_S2 <- Ms_weighted_S3 <- Ms_weighted_S2_mis <- Ms_weighted_S3_mis <- Ms_weighted_S4 <- Ms_weighted_S4_mis <- 
  A3_bias_S1 <- A3_bias_S2 <- A3_bias_S3 <- A3_bias_S2_mis <- A3_bias_S3_mis <- A3_bias_S4 <- A3_bias_S4_mis <- 
  A1A3_bias_S1 <- A1A3_bias_S2 <- A1A3_bias_S3 <- A1A3_bias_S2_mis <- A1A3_bias_S3_mis <- A1A3_bias_S4 <- A1A3_bias_S4_mis <- NULL

A2_bias_S1 <- A2_bias_S2 <- A2_bias_S3 <- A2_bias_S2_mis <- A2_bias_S3_mis <- A2_bias_S4 <- A2_bias_S4_mis <- 
  A1_bias_S1 <- A1_bias_S2 <- A1_bias_S3 <- A1_bias_S2_mis <- A1_bias_S3_mis <- A1_bias_S4 <- A1_bias_S4_mis <- NULL

for(i in 1:length(results)){
  
  # --- Scenario 1 ---
  Ms_S1[i] <- results[[i]]$evaluation_1$M
  Ms_weighted_S1[i] <- results[[i]]$evaluation_1$M_weighted
  A3_bias_S1[i] <- results[[i]]$evaluation_1$A3_bias
  A1A3_bias_S1[i] <- results[[i]]$evaluation_1$A1A3_bias
  A2_bias_S1 <- cbind(A2_bias_S1, results[[i]]$evaluation_1$A2_bias)
  A1_bias_S1 <- cbind(A1_bias_S1, results[[i]]$evaluation_1$A1_bias)
  
  # --- Scenario 2 ---
  TPs_S2[i] <- sum(round(results[[i]]$results_2$theta[c(2,6,7)],5) == 
                     round(results[[i]]$results_2$theta[c(10,11,12)],5))
  FPs_S2[i]  <- sum(round(results[[i]]$results_2$theta[c(14)],5) == 
                      round(results[[i]]$results_2$theta[c(2,10)],5))
  Ms_S2[i] <- results[[i]]$evaluation_2$M
  Ms_weighted_S2[i] <- results[[i]]$evaluation_2$M_weighted
  A3_bias_S2[i] <- results[[i]]$evaluation_2$A3_bias
  A1A3_bias_S2[i] <- results[[i]]$evaluation_2$A1A3_bias
  A2_bias_S2 <- cbind(A2_bias_S2, results[[i]]$evaluation_2$A2_bias)
  A1_bias_S2 <- cbind(A1_bias_S2, results[[i]]$evaluation_2$A1_bias)
  
  # --- Scenario 2 (misspecification) ---
  TPs_S2_mis[i] <- sum(round(results[[i]]$results_2_mis$theta[c(2,6,7)],6) ==
                         round(results[[i]]$results_2_mis$theta[c(10,11,12)],6))
  FPs_S2_mis[i] <- sum(round(results[[i]]$results_2_mis$theta[c(14)],6) ==
                         round(results[[i]]$results_2_mis$theta[c(2,10)],6))
  Ms_S2_mis[i] <- results[[i]]$evaluation_2_mis$M
  Ms_weighted_S2_mis[i] <- results[[i]]$evaluation_2_mis$M_weighted
  A3_bias_S2_mis[i] <- results[[i]]$evaluation_2_mis$A3_bias
  A1A3_bias_S2_mis[i] <- results[[i]]$evaluation_2_mis$A1A3_bias
  A2_bias_S2_mis <- cbind(A2_bias_S2_mis, results[[i]]$evaluation_2_mis$A2_bias)
  A1_bias_S2_mis <- cbind(A1_bias_S2_mis, results[[i]]$evaluation_2_mis$A1_bias)
  
  # --- Scenario 3 ---
  Ms_S3[i] <- results[[i]]$evaluation_3$M
  Ms_weighted_S3[i] <- results[[i]]$evaluation_3$M_weighted
  A3_bias_S3[i] <- results[[i]]$evaluation_3$A3_bias
  A1A3_bias_S3[i] <- results[[i]]$evaluation_3$A1A3_bias
  A2_bias_S3 <- cbind(A2_bias_S3, results[[i]]$evaluation_3$A2_bias)
  A1_bias_S3 <- cbind(A1_bias_S3, results[[i]]$evaluation_3$A1_bias)
  
  # --- Scenario 3 (misspecification) ---
  Ms_S3_mis[i] <- results[[i]]$evaluation_3_mis$M
  Ms_weighted_S3_mis[i] <- results[[i]]$evaluation_3_mis$M_weighted
  A3_bias_S3_mis[i] <- results[[i]]$evaluation_3_mis$A3_bias
  A1A3_bias_S3_mis[i] <- results[[i]]$evaluation_3_mis$A1A3_bias
  A2_bias_S3_mis <- cbind(A2_bias_S3_mis, results[[i]]$evaluation_3_mis$A2_bias)
  A1_bias_S3_mis <- cbind(A1_bias_S3_mis, results[[i]]$evaluation_3_mis$A1_bias)
  
  # --- Scenario 4 ---
  Ms_S4[i] <- results[[i]]$evaluation_4$M
  Ms_weighted_S4[i] <- results[[i]]$evaluation_4$M_weighted
  A3_bias_S4[i] <- results[[i]]$evaluation_4$A3_bias
  A1A3_bias_S4[i] <- results[[i]]$evaluation_4$A1A3_bias
  A2_bias_S4 <- cbind(A2_bias_S4, results[[i]]$evaluation_4$A2_bias)
  A1_bias_S4 <- cbind(A1_bias_S4, results[[i]]$evaluation_4$A1_bias)
  
  # --- Scenario 4 (misspecification) ---
  Ms_S4_mis[i] <- results[[i]]$evaluation_4_mis$M
  Ms_weighted_S4_mis[i] <- results[[i]]$evaluation_4_mis$M_weighted
  A3_bias_S4_mis[i] <- results[[i]]$evaluation_4_mis$A3_bias
  A1A3_bias_S4_mis[i] <- results[[i]]$evaluation_4_mis$A1A3_bias
  A2_bias_S4_mis <- cbind(A2_bias_S4_mis, results[[i]]$evaluation_4_mis$A2_bias)
  A1_bias_S4_mis <- cbind(A1_bias_S4_mis, results[[i]]$evaluation_4_mis$A1_bias)
}

# --- Function to format mean (SD) with 3 significant digits ---
fmt <- function(x) sprintf("%.3f (%.3f)", mean(x, na.rm = TRUE), sd(x, na.rm = TRUE))

# --- Summaries for scalar vectors ---
summary_results <- data.frame(
  Measure = c("Ms", "Ms_weighted", "A3_bias", "A1A3_bias"),
  S1      = c(fmt(Ms_S1), fmt(Ms_weighted_S1), fmt(A3_bias_S1), fmt(A1A3_bias_S1)),
  S2      = c(fmt(Ms_S2), fmt(Ms_weighted_S2), fmt(A3_bias_S2), fmt(A1A3_bias_S2)),
  S2_mis  = c(fmt(Ms_S2_mis), fmt(Ms_weighted_S2_mis), fmt(A3_bias_S2_mis), fmt(A1A3_bias_S2_mis)),
  S3      = c(fmt(Ms_S3), fmt(Ms_weighted_S3), fmt(A3_bias_S3), fmt(A1A3_bias_S3)),
  S3_mis  = c(fmt(Ms_S3_mis), fmt(Ms_weighted_S3_mis), fmt(A3_bias_S3_mis), fmt(A1A3_bias_S3_mis)),
  S4      = c(fmt(Ms_S4), fmt(Ms_weighted_S4), fmt(A3_bias_S4), fmt(A1A3_bias_S4)),
  S4_mis  = c(fmt(Ms_S4_mis), fmt(Ms_weighted_S4_mis), fmt(A3_bias_S4_mis), fmt(A1A3_bias_S4_mis)),
  stringsAsFactors = FALSE
)

# --- Summaries for matrix-type results (rowwise mean/SD) ---
fmt_row <- function(mat) sprintf("%.3f (%.3f)",
                                 rowMeans(mat, na.rm = TRUE),
                                 apply(mat, 1, sd, na.rm = TRUE))

A1_bias_summary <- data.frame(
  S1     = fmt_row(A1_bias_S1),
  S2     = fmt_row(A1_bias_S2),
  S2_mis = fmt_row(A1_bias_S2_mis),
  S3     = fmt_row(A1_bias_S3),
  S3_mis = fmt_row(A1_bias_S3_mis),
  S4     = fmt_row(A1_bias_S4),
  S4_mis = fmt_row(A1_bias_S4_mis)
)

A2_bias_summary <- data.frame(
  S1     = fmt_row(A2_bias_S1),
  S2     = fmt_row(A2_bias_S2),
  S2_mis = fmt_row(A2_bias_S2_mis),
  S3     = fmt_row(A2_bias_S3),
  S3_mis = fmt_row(A2_bias_S3_mis),
  S4     = fmt_row(A2_bias_S4),
  S4_mis = fmt_row(A2_bias_S4_mis)
)

print(summary_results, row.names = FALSE)

print(head(A1_bias_summary)) 
print(head(A2_bias_summary))

# TP / FP summaries
mean(TPs_S2); sd(TPs_S2)
mean(FPs_S2); sd(FPs_S2)

mean(TPs_S2_mis); sd(TPs_S2_mis)
mean(FPs_S2_mis); sd(FPs_S2_mis)
