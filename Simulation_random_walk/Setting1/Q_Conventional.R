################## Q learning ##############

## This file contains the conventional Q learning method design for Setting I. 
prepare_setting1_data <- function(data_original) {
  if (!"A1A2" %in% names(data_original)) {
    data_original$A1A2 <- data_original$A1 * data_original$A2
  }
  if (!"A1A3" %in% names(data_original)) {
    data_original$A1A3 <- data_original$A1 * data_original$A3
  }
  if (!"A2A3" %in% names(data_original)) {
    data_original$A2A3 <- data_original$A2 * data_original$A3
  }
  data_original
}

safe_extract_coef <- function(fit, coef_names) {
  coefs <- coef(fit)[coef_names]
  coefs[is.na(coefs)] <- 0
  coefs
}

Q_learning <- function(data_original){
  data_original <- prepare_setting1_data(data_original)
  
  ## Q3
  data_Q3 <- subset(data_original, G2 == 1)
  Q3_fit <- lm(Y ~ A1+A2+A1A2+G1+A3+A1A3+A2A3, data = data_Q3)
  Y <- data_original$Y
  
  A3_block <- dplyr::select(data_original, A3, A1A3, A2A3)
  b3 <- safe_extract_coef(Q3_fit, c("A3","A1A3","A2A3"))
  real_A3 <- as.numeric(as.matrix(A3_block) %*% b3)
  pseudo_A3 <- as.numeric(as.matrix(-A3_block) %*% b3)
  max_A3 <- pmax(real_A3, pseudo_A3)
  
  optimal_A3 <- ifelse(real_A3 >= pseudo_A3, data_original$A3, -data_original$A3)
  optimal_A3 <- data_original$G2*optimal_A3 + 
    (1-data_original$G2)*data_original$A3 # Optimal A3 for responders are the A3 they received
  Y_optimal_Q3 <- data_original$G2*(Y - real_A3 + max_A3) + 
    (1-data_original$G2)*Y
  
  ## Q2
  data_Q2 <- data_original %>% 
    dplyr::select(Y, A1, G1, A2, A1A2) %>% 
    mutate(Y = Y_optimal_Q3) %>% 
    filter(G1 == 1)
  Q2_fit <- lm(Y ~ A1+A2+A1A2,data=data_Q2)
  
  A2_block <- dplyr::select(data_original, A2, A1A2)
  b2 <- safe_extract_coef(Q2_fit, c("A2","A1A2"))
  real_A2 <- as.numeric(as.matrix(A2_block) %*% b2)
  pseudo_A2 <- as.numeric(as.matrix(-A2_block) %*% b2)
  max_A2 <- pmax(real_A2, pseudo_A2)
  
  optimal_A2 <- ifelse(real_A2 >= pseudo_A2, data_original$A2, -data_original$A2)
  optimal_A2 <- data_original$G1*optimal_A2 + 
    (1-data_original$G1)*data_original$A2
  Y_optimal_Q2 <- data_original$G1*(Y_optimal_Q3 - real_A2 + max_A2) +
    (1-data_original$G1)*Y_optimal_Q3
  
  ## Q1
  data_Q1 <- data_original %>% 
    dplyr::select(Y, A1) %>% 
    mutate(Y = Y_optimal_Q2)
  Q1_fit <- lm(Y ~ A1,data=data_Q1)
  b1 <- safe_extract_coef(Q1_fit, c("A1"))
  optimal_A1 <- rep(sign(b1["A1"]), dim(data_original)[1])
  
  theta <- c(
    safe_extract_coef(Q3_fit, c("(Intercept)","A1","A2","A1A2","G1","A3","A1A3","A2A3")),
    safe_extract_coef(Q2_fit, c("(Intercept)","A1","A2","A1A2")),
    safe_extract_coef(Q1_fit, c("(Intercept)","A1"))
  )
  
  results <- list(theta = theta,
                  Q3_fit = Q3_fit,
                  Q2_fit = Q2_fit,
                  Q1_fit = Q1_fit,
                  optimal_A3 = optimal_A3,
                  optimal_A2 = optimal_A2,
                  optimal_A1 = optimal_A1,
                  data_Q3 = data_Q3,
                  data_Q2 = data_Q2,
                  data_Q1 = data_Q1)
  
  return(results)
}

# data_original <- test
# 
# Y <- data_original$Y
# ## Q3
# data_Q3 <- subset(data_original, G2 == 1)
# Q3_fit <- lm(Y ~ A1+A2+A1A2+G1+A3+A1A3+A2A3+A1A2A3,data=data_Q3)
# alias(Q3_fit)
# 
# 
# A3_block <- dplyr::select(data_original, A3, A1A3, A2A3, A1A2A3)
# b3 <- coef(Q3_fit)[c("A3","A1A3","A2A3","A1A2A3")]
# real_A3 <- as.numeric(as.matrix(A3_block) %*% b3)
# pseudo_A3 <- as.numeric(as.matrix(-A3_block) %*% b3)
# max_A3 <- pmax(real_A3, pseudo_A3)
# 
# optimal_A3 <- ifelse(real_A3 >= pseudo_A3, data_original$A3, -data_original$A3)
# optimal_A3 <- data_original$G2*optimal_A3 + 
#   (1-data_original$G2)*data_original$A3 # Optimal A3 for responders are the A3 they received
# Y_optimal_Q3 <- data_original$G2*(Y - real_A3 + max_A3) + 
#   (1-data_original$G2)*Y
# 
# ## Q2
# data_Q2 <- data_original %>% 
#   dplyr::select(Y, A1, G1, A2, A1A2) %>% 
#   mutate(Y = Y_optimal_Q3) %>% 
#   filter(G1 == 1)
# Q2_fit <- lm(Y ~ A1+A2+A1A2,data=data_Q2)
# 
# A2_block <- dplyr::select(data_original, A2, A1A2)
# b2 <- coef(Q2_fit)[c("A2","A1A2")]
# real_A2 <- as.numeric(as.matrix(A2_block) %*% b2)
# pseudo_A2 <- as.numeric(as.matrix(-A2_block) %*% b2)
# max_A2 <- pmax(real_A2, pseudo_A2)
# 
# optimal_A2 <- ifelse(real_A2 >= pseudo_A2, data_original$A2, -data_original$A2)
# optimal_A2 <- data_original$G1*optimal_A2 + 
#   (1-data_original$G1)*data_original$A2
# Y_optimal_Q2 <- data_original$G1*(Y_optimal_Q3 - real_A2 + max_A2) +
#   (1-data_original$G1)*Y_optimal_Q3
# 
# ## Q1
# data_Q1 <- data_original %>% 
#   dplyr::select(Y, A1) %>% 
#   mutate(Y = Y_optimal_Q2)
# Q1_fit <- lm(Y ~ A1,data=data_Q1)
# optimal_A1 <- rep(sign(coef(Q1_fit)["A1"]), dim(data_original)[1])
# 
# theta <- c(
#   coef(Q3_fit)[c("(Intercept)","A1","A2","A1A2","G1","A3","A1A3","A2A3","A1A2A3")],
#   coef(Q2_fit)[c("(Intercept)","A1","A2","A1A2")],
#   coef(Q1_fit)[c("(Intercept)","A1")]
# )
