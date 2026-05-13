################## Shared Q ##############
SharedQ <- function(data_original, warmstart){
  
  ## stage 1
  data_stage1 <- data.frame(
    Y = data_original$Y,
    O1 = data_original$O1,
    A1 = data_original$A1,
    `O1:A1` = data_original$O1 * data_original$A1,
    check.names = FALSE
  )
  
  ## stage 2
  tmp2 <- data_original %>% dplyr::filter(R1 == 0) %>%
    dplyr::select(Y, O1, A1, O2, A2)
  data_stage2 <- data.frame(
    Y = tmp2$Y,
    O1 = tmp2$O1,
    A1 = tmp2$A1,
    `O1:A1` = tmp2$O1 * tmp2$A1,
    O2 = tmp2$O2,
    A2 = tmp2$A2,
    `O2:A2` = tmp2$O2 * tmp2$A2,
    `A1:A2` = tmp2$A1 * tmp2$A2,
    check.names = FALSE
  )
  
  ## stage 3
  tmp3 <- data_original %>% dplyr::filter(R2 == 0 & R1 == 0) %>%
    dplyr::select(Y, O1, A1, O2, A2, O3, A3)
  data_stage3 <- data.frame(
    Y = tmp3$Y,
    O1 = tmp3$O1,
    A1 = tmp3$A1,
    `O1:A1` = tmp3$O1 * tmp3$A1,
    O2 = tmp3$O2,
    A2 = tmp3$A2,
    `O2:A2` = tmp3$O2 * tmp3$A2,
    `A1:A2` = tmp3$A1 * tmp3$A2,
    O3 = tmp3$O3,
    A3 = tmp3$A3,
    `O3:A3` = tmp3$O3 * tmp3$A3,
    `A2:A3` = tmp3$A2 * tmp3$A3,
    `A1:A2:A3` = tmp3$A1 * tmp3$A2 * tmp3$A3,
    check.names = FALSE
  )
  
  Y <- data_original$Y
  
  ## Construct Shared X
  X_shared <- data.frame(
    Psi1 = c(data_stage3$A3,
             data_stage2$A2,
             data_stage1$A1),
    Psi2 = c(data_stage3$`O3:A3`,
             data_stage2$`O2:A2`,
             data_stage1$`O1:A1`),
    Psi3 = c(data_stage3$`A2:A3`,
             data_stage2$`A1:A2`,
             rep(0, nrow(data_stage1)))
  )
  
  data_stage1 <- data_stage1 %>% dplyr::select(Y, O1)
  data_stage2 <- data_stage2 %>% dplyr::select(Y, O1, A1, `O1:A1`, O2)
  data_stage3 <- data_stage3 %>% dplyr::select(Y, O1, A1, `O1:A1`, O2, A2, `O2:A2`, `A1:A2`, O3, `A1:A2:A3`)
  
  ## decision blocks
  A3_block <- cbind(
    A3 = data_original$A3,
    `O3:A3` = data_original$O3 * data_original$A3,
    `A2:A3` = data_original$A2 * data_original$A3,
    `A1:A2:A3` = data_original$A1 * data_original$A2 * data_original$A3
  )
  A2_block <- cbind(
    A2 = data_original$A2,
    `O2:A2` = data_original$O2 * data_original$A2,
    `A1:A2` = data_original$A1 * data_original$A2
  )
  A1_block <- cbind(
    A1 = data_original$A1,
    `O1:A1` = data_original$O1 * data_original$A1
  )
  
  ## Q shared
  theta <- warmstart
  theta_prev <- theta - 1
  iter <- 0
  
  while (sqrt(sum((theta - theta_prev)^2)) > 1e-06 & iter <= 50000) {
    iter <- iter + 1
    theta_prev <- theta
    
    A3_decision <- c(theta[18], theta[19], theta[20], theta[10])  # Psi1, Psi2, Psi3, Q3_A1:A2:A3
    A2_decision <- c(theta[18], theta[19], theta[20])             # Psi1, Psi2, Psi3
    A1_decision <- c(theta[18], theta[19])                        # Psi1, Psi2
    
    ## Q3
    real_A3 <- as.numeric(A3_block %*% A3_decision)
    pseudo_A3 <- as.numeric((-A3_block) %*% A3_decision)
    max_A3 <- pmax(real_A3, pseudo_A3)
    optimal_A3 <- ifelse(real_A3 >= pseudo_A3, data_original$A3, -data_original$A3)
    Y_optimal_Q3 <- ifelse(data_original$R2 == 0 & data_original$R1 == 0,
                           Y - real_A3 + max_A3,
                           Y)
    
    ## Q2
    real_A2 <- as.numeric(A2_block %*% A2_decision)
    pseudo_A2 <- as.numeric((-A2_block) %*% A2_decision)
    max_A2 <- pmax(real_A2, pseudo_A2)
    optimal_A2 <- ifelse(real_A2 >= pseudo_A2, data_original$A2, -data_original$A2)
    Y_optimal_Q2 <- ifelse(data_original$R1 == 0,
                           Y_optimal_Q3 - real_A2 + max_A2,
                           Y_optimal_Q3)
    
    ## Q1
    real_A1 <- as.numeric(A1_block %*% A1_decision)
    pseudo_A1 <- as.numeric((-A1_block) %*% A1_decision)
    optimal_A1 <- ifelse(real_A1 >= pseudo_A1, data_original$A1, -data_original$A1)
    
    ## combine
    Y_combined <- c(
      Y[data_original$R2 == 0 & data_original$R1 == 0],
      Y_optimal_Q3[data_original$R1 == 0],
      Y_optimal_Q2
    )
    
    X_combined <- Matrix::bdiag(
      as.matrix(cbind(1, data_stage3[,-1])),
      as.matrix(cbind(1, data_stage2[,-1])),
      as.matrix(cbind(1, data_stage1[,-1]))
    )
    X_combined <- as.matrix(cbind(as.matrix(X_combined), X_shared))
    colnames(X_combined) <- c(
      "Intercept_Q3","O1_Q3","A1_Q3","O1A1_Q3","O2_Q3","A2_Q3","O2A2_Q3","A1A2_Q3","O3_Q3","A1A2A3_Q3",
      "Intercept_Q2","O1_Q2","A1_Q2","O1A1_Q2","O2_Q2",
      "Intercept_Q1","O1_Q1",
      "Psi1","Psi2","Psi3"
    )
    
    fit <- lm(Y_combined ~ X_combined - 1)
    theta <- coef(fit)
    
  }
  names(theta) <- colnames(X_combined)
  
  theta <- theta[c(
    "Intercept_Q3","O1_Q3","A1_Q3","O1A1_Q3","O2_Q3","A2_Q3","O2A2_Q3","A1A2_Q3","O3_Q3",
    "Psi1","Psi2","Psi3","A1A2A3_Q3",
    "Intercept_Q2","O1_Q2","A1_Q2","O1A1_Q2","O2_Q2",
    "Psi1","Psi2","Psi3",
    "Intercept_Q1","O1_Q1",
    "Psi1","Psi2"
  )]
  
  list(theta = theta,
       optimal_A1 = optimal_A1,
       optimal_A2 = optimal_A2,
       optimal_A3 = optimal_A3,
       iter = iter) 
}
