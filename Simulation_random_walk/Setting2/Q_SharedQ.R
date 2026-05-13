################## Shared Q ##############
# This file contains the shared Q function design for Setting II.
SharedQ <- function(data_original, warmstart){
  data_original <- prepare_setting2_data(data_original)
  
  ## Extract data for each stage
  data_stage1 <- data_original %>% dplyr::select(Y, A1)
  data_stage2 <- data_original %>% filter(G1 == 1) %>% dplyr::select(Y, A1, A2, A1A2)
  data_stage3 <- data_original %>% filter(G2 == 1) %>% dplyr::select(Y, A1, A2, A1A2, G1, A3, A1A3, A2A3)
  Y <- data_original$Y
  
  ## Construct Shared X
  # X_shared <- data.frame(Psi1 = c(data_stage3$A1, data_stage2$A1, data_stage1$A1), #A1 across 3 stages
  #                        Psi2 = c(data_stage3$A3, data_stage2$A2, rep(0,length(data_stage1$A1))), #A2 and A3 for last 2 stages
  #                        Psi3 = c(data_stage3$A1A3, data_stage2$A1A2, rep(0,length(data_stage1$A1))) #A1A2 and A1A3 for last 2 stages
  #                        )
  X_shared <- data.frame(Psi1 = c(data_stage3$A1, data_stage2$A1, rep(0,length(data_stage1$A1))), #A1 for stage 2 and 3
                         Psi2 = c(data_stage3$A3, data_stage2$A2, rep(0,length(data_stage1$A1))), #A2 and A3 for last 2 stages
                         Psi3 = c(data_stage3$A1A3, data_stage2$A1A2,rep(0,length(data_stage1$A1)))) #A1A2 and A1A3 for last 2 stages
  data_stage1 <- data_stage1
  data_stage2 <- data_stage2 %>% dplyr::select(-A1, -A2, -A1A2)
  data_stage3 <- data_stage3 %>% dplyr::select(-A1, -A3, -A1A3)
  
  ## Create blocks for decision rules
  A3_block <- dplyr::select(data_original, A3, A1A3, A2A3)
  A2_block <- dplyr::select(data_original, A2, A1A2)
  A1_block <- dplyr::select(data_original, A1)
  
  ## Warmstart
  theta <- warmstart
  theta_prev <- theta - 1
  iter <- 0
  while(sqrt(sum((theta- theta_prev)^2)) > 1e-06 
        & iter <= 50000){
    
    iter <- iter + 1
    theta_prev <- theta
    A3_decision <- theta[c(10, 11, 5)]
    A2_decision <- theta[c(10, 11)]
    A1_decision <- theta[8]
    
    ## Update pseudo-outcomes
    ### Q3
    real_A3 <- as.numeric(as.matrix(A3_block) %*% A3_decision)
    pseudo_A3 <- as.numeric(as.matrix(-A3_block) %*% A3_decision)
    max_A3 <- pmax(real_A3, pseudo_A3)
    optimal_A3 <- ifelse(real_A3 >= pseudo_A3, data_original$A3, -data_original$A3)
    optimal_A3 <- data_original$G2*optimal_A3 + 
      (1-data_original$G2)*data_original$A3
    Y_optimal_Q3 <- data_original$G2*(Y - real_A3 + max_A3) + 
      (1-data_original$G2)*Y
    
    ### Q2
    real_A2 <- as.numeric(as.matrix(A2_block) %*% A2_decision)
    pseudo_A2 <- as.numeric(as.matrix(-A2_block) %*% A2_decision)
    max_A2 <- pmax(real_A2, pseudo_A2)
    optimal_A2 <- ifelse(real_A2 >= pseudo_A2, data_original$A2, -data_original$A2)
    optimal_A2 <- data_original$G1*optimal_A2 + 
      (1-data_original$G1)*data_original$A2
    Y_optimal_Q2 <- data_original$G1*(Y_optimal_Q3 - real_A2 + max_A2) +
      (1-data_original$G1)*Y_optimal_Q3
    
    ### Q1
    optimal_A1 <- rep(sign(A1_decision), dim(data_original)[1])
    
    ## Combine Y and X
    Y_combined <- c(Y[data_original$G2 == 1], #For stage 3 regression
                    Y_optimal_Q3[data_original$G1 == 1], #For stage 2 regression
                    Y_optimal_Q2 #For stage 1 regression
    )
    
    X_combined <- bdiag(as.matrix(cbind(1, data_stage3[,-1])),
                        as.matrix(cbind(1, data_stage2[,-1])),
                        as.matrix(cbind(1, data_stage1[,-1])))
    X_combined <- as.matrix(cbind(as.matrix(X_combined),X_shared))
    colnames(X_combined) <- c("Intercet_Q3", "A2","A1A2","G1","A2A3",
                              "Intercept_Q2",
                              "Intercept_Q1",
                              "A1",
                              "Psi1","Psi2","Psi3")
    ## Run fused lasso regression
    result <- lm(Y_combined ~ X_combined - 1)
    theta_psi <- coef(result)
  }
  
  col_names <- c("Intercet_Q3", "A2","A1A2","G1","A2A3",
                 "Intercept_Q2",
                 "Intercept_Q1",
                 "A1",
                 "Psi1","Psi2","Psi3")
  names(theta_psi) <- col_names
  
  theta <- theta_psi[c("Intercet_Q3", "Psi1","A2","A1A2","G1","Psi2", "Psi3","A2A3","Intercept_Q2","Psi1","Psi2","Psi3","Intercept_Q1","A1")]
  names(theta) <- c(paste0("",c("(Intercept)","A1","A2","A1A2","G1","A3","A1A3","A2A3")),
             paste0("",c("(Intercept)","A1","A2","A1A2")),
             paste0("",c("(Intercept)","A1")))
  
  results <- list(theta_psi = theta_psi,
                  theta =theta,
                  optimal_A1 = optimal_A1,
                  optimal_A2 = optimal_A2,
                  optimal_A3 = optimal_A3,
                  iter = iter)
  return(results)
  
}


SharedQ_mis <- function(data_original, warmstart){
  data_original <- prepare_setting2_data(data_original)
  
  ## Extract data for each stage
  data_stage1 <- data_original %>% dplyr::select(Y, A1)
  data_stage2 <- data_original %>% filter(G1 == 1) %>% dplyr::select(Y, A1, A2, A1A2)
  data_stage3 <- data_original %>% filter(G2 == 1) %>% dplyr::select(Y, A1, A2, A1A2, G1, A3, A1A3, A2A3)
  Y <- data_original$Y
  
  ## Construct Shared X
  X_shared <- data.frame(Psi1 = c(data_stage3$A1, data_stage2$A1, data_stage1$A1), #A1 across 3 stages
                         Psi2 = c(data_stage3$A3, data_stage2$A2, rep(0,length(data_stage1$A1))), #A2 and A3 for last 2 stages
                         Psi3 = c(data_stage3$A1A3, data_stage2$A1A2, rep(0,length(data_stage1$A1))) #A1A2 and A1A3 for last 2 stages
                         )

  data_stage1 <- data_stage1 %>% dplyr::select(-A1)
  data_stage2 <- data_stage2 %>% dplyr::select(-A1, -A2, -A1A2)
  data_stage3 <- data_stage3 %>% dplyr::select(-A1, -A3, -A1A3)
  
  ## Create blocks for decision rules
  A3_block <- dplyr::select(data_original, A3, A1A3, A2A3)
  A2_block <- dplyr::select(data_original, A2, A1A2)
  A1_block <- dplyr::select(data_original, A1)
  
  ## Warmstart
  theta <- warmstart
  theta_prev <- theta - 1
  iter <- 0
  while(sqrt(sum((theta- theta_prev)^2)) > 1e-06 
        & iter <= 50000){
    
    iter <- iter + 1
    theta_prev <- theta
    A3_decision <- theta[c(9, 10, 5)]
    A2_decision <- theta[c(9, 10)]
    A1_decision <- theta[8]
    
    ## Update pseudo-outcomes
    ### Q3
    real_A3 <- as.numeric(as.matrix(A3_block) %*% A3_decision)
    pseudo_A3 <- as.numeric(as.matrix(-A3_block) %*% A3_decision)
    max_A3 <- pmax(real_A3, pseudo_A3)
    optimal_A3 <- ifelse(real_A3 >= pseudo_A3, data_original$A3, -data_original$A3)
    optimal_A3 <- data_original$G2*optimal_A3 + 
      (1-data_original$G2)*data_original$A3
    Y_optimal_Q3 <- data_original$G2*(Y - real_A3 + max_A3) + 
      (1-data_original$G2)*Y
    
    ### Q2
    real_A2 <- as.numeric(as.matrix(A2_block) %*% A2_decision)
    pseudo_A2 <- as.numeric(as.matrix(-A2_block) %*% A2_decision)
    max_A2 <- pmax(real_A2, pseudo_A2)
    optimal_A2 <- ifelse(real_A2 >= pseudo_A2, data_original$A2, -data_original$A2)
    optimal_A2 <- data_original$G1*optimal_A2 + 
      (1-data_original$G1)*data_original$A2
    Y_optimal_Q2 <- data_original$G1*(Y_optimal_Q3 - real_A2 + max_A2) +
      (1-data_original$G1)*Y_optimal_Q3
    
    ### Q1
    optimal_A1 <- rep(sign(A1_decision), dim(data_original)[1])
    
    ## Combine Y and X
    Y_combined <- c(Y[data_original$G2 == 1], #For stage 3 regression
                    Y_optimal_Q3[data_original$G1 == 1], #For stage 2 regression
                    Y_optimal_Q2 #For stage 1 regression
    )
    
    X_combined <- bdiag(as.matrix(cbind(1, data_stage3[,-1])),
                        as.matrix(cbind(1, data_stage2[,-1])),
                        as.matrix(cbind(1, data_stage1[,-1])))
    X_combined <- as.matrix(cbind(as.matrix(X_combined),X_shared))
    colnames(X_combined) <- c("Intercet_Q3", "A2","A1A2","G1","A2A3",
                              "Intercept_Q2",
                              "Intercept_Q1",
                              "Psi1","Psi2","Psi3")
    ## Run fused lasso regression
    result <- lm(Y_combined ~ X_combined - 1)
    theta_psi <- coef(result)
  }
  
  col_names <- c("Intercet_Q3", "A2","A1A2","G1","A2A3",
                 "Intercept_Q2",
                 "Intercept_Q1",
                 "Psi1","Psi2","Psi3")
  names(theta_psi) <- col_names
  
  theta <- theta_psi[c("Intercet_Q3", "Psi1","A2","A1A2","G1","Psi2", "Psi3","A2A3","Intercept_Q2","Psi1","Psi2","Psi3","Intercept_Q1","Psi1")]
  names(theta) <- c(paste0("",c("(Intercept)","A1","A2","A1A2","G1","A3","A1A3","A2A3")),
                    paste0("",c("(Intercept)","A1","A2","A1A2")),
                    paste0("",c("(Intercept)","A1")))
  
  results <- list(theta_psi = theta_psi,
                  theta =theta,
                  optimal_A1 = optimal_A1,
                  optimal_A2 = optimal_A2,
                  optimal_A3 = optimal_A3,
                  iter = iter)
  return(results)
  
}

