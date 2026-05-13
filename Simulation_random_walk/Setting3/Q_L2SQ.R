######################## SQlearning (setting 3) #######################
fused_ridge <- function(y, X, D, lambda = 1e-2, gamma = 0) {
  p <- ncol(X)
  
  A <- crossprod(X) + gamma * diag(p) + lambda * crossprod(D)
  b <- crossprod(X, y)
  
  drop(solve(A, b))
}
SQlearning_L2 <- function(data_original, 
                          warmstart, lambda, gamma, D){
  notes <- NULL
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
  
  ## SQ learning
  theta <- warmstart
  theta_prev <- warmstart - 1
  iter <- 0
  while (sqrt(sum((theta - theta_prev)^2)) > 1e-06 &
         iter <= 50000) {
    
    iter <- iter + 1
    theta_prev <- theta
    # print(iter)
    ## indices:
    ## Q3: 13 coefs
    ## Q2: next 8
    ## Q1: last 4
    A3_decision <- theta[10:13]
    A2_decision <- theta[19:21]
    A1_decision <- theta[24:25]
    
    ## Q3
    real_A3 <- as.numeric(as.matrix(A3_block) %*% A3_decision)
    pseudo_A3 <- as.numeric(as.matrix(-A3_block) %*% A3_decision)
    max_A3 <- pmax(real_A3, pseudo_A3)
    optimal_A3 <- ifelse(real_A3 >= pseudo_A3, data_original$A3, -data_original$A3)
    Y_optimal_Q3 <- ifelse(data_original$R2 == 0 & data_original$R1 == 0,
                           Y - real_A3 + max_A3,
                           Y)
    
    ## Q2
    real_A2 <- as.numeric(as.matrix(A2_block) %*% A2_decision)
    pseudo_A2 <- as.numeric(as.matrix(-A2_block) %*% A2_decision)
    max_A2 <- pmax(real_A2, pseudo_A2)
    optimal_A2 <- ifelse(real_A2 >= pseudo_A2, data_original$A2, -data_original$A2)
    Y_optimal_Q2 <- ifelse(data_original$R1 == 0,
                           Y_optimal_Q3 - real_A2 + max_A2,
                           Y_optimal_Q3)
    
    ## Q1
    real_A1 <- as.numeric(as.matrix(A1_block) %*% A1_decision)
    pseudo_A1 <- as.numeric(as.matrix(-A1_block) %*% A1_decision)
    optimal_A1 <- ifelse(real_A1 >= pseudo_A1, data_original$A1, -data_original$A1)
    
    ## combine
    Y_combined <- c(
      Y[data_original$R2 == 0 & data_original$R1 == 0],
      Y_optimal_Q3[data_original$R1 == 0],
      Y_optimal_Q2
    )
    
    X_combined <- bdiag(
      as.matrix(cbind(1, data_stage3[,-1])),
      as.matrix(cbind(1, data_stage2[,-1])),
      as.matrix(cbind(1, data_stage1[,-1]))
    )
    X_combined <- as.matrix(X_combined)
    col_names <- c(
      paste0("Q3_", c("(Intercept)","O1","A1","O1:A1","O2","A2","O2:A2","A1:A2","O3","A3","O3:A3","A2:A3","A1:A2:A3")),
      paste0("Q2_", c("(Intercept)","O1","A1","O1:A1","O2","A2","O2:A2","A1:A2")),
      paste0("Q1_", c("(Intercept)","O1","A1","O1:A1"))
    )
    colnames(X_combined) <- col_names
    
    result <- fused_ridge(Y_combined, X_combined, D = D, lambda = lambda, gamma = gamma)
    theta <- result
  }
  
  col_names <- c(
    paste0("", c("(Intercept)","O1","A1","O1:A1","O2","A2","O2:A2","A1:A2","O3","A3","O3:A3","A2:A3","A1:A2:A3")),
    paste0("", c("(Intercept)","O1","A1","O1:A1","O2","A2","O2:A2","A1:A2")),
    paste0("", c("(Intercept)","O1","A1","O1:A1"))
  )
  names(theta) <- col_names
  if (iter >= 50000) { 
    warning("Convergence Issue Exists!!!") 
    notes <- paste0("Convergence Issue Exists!!!")
  }
  
  results <- list(theta = theta,
                  lambda = lambda,
                  result = result,
                  iter = iter,
                  optimal_A1 = optimal_A1,
                  optimal_A2 = optimal_A2,
                  optimal_A3 = optimal_A3,
                  notes = notes)
  return(results)
}

#############################################################################
CV_SQlearning_L2 <- function(data_original,
                             warmstart, lambda, gamma, D, nfolds, metric = "outcome"){
  fold_scores <- NULL
  folds <- createFolds(y = data_original$Y, k = nfolds)
  for(i in 1:nfolds){
    train_data <- data_original[-folds[[i]], ]
    test_data  <- data_original[folds[[i]], ]
    
    results <- SQlearning_L2(train_data, warmstart, lambda,gamma, D)
    theta <- results$theta
    names(theta) <- c(
      paste0("Q3_", c("(Intercept)","O1","A1","O1:A1","O2","A2","O2:A2","A1:A2","O3","A3","O3:A3","A2:A3","A1:A2:A3")),
      paste0("Q2_", c("(Intercept)","O1","A1","O1:A1","O2","A2","O2:A2","A1:A2")),
      paste0("Q1_", c("(Intercept)","O1","A1","O1:A1"))
    )
    
    if(metric == "outcome"){
      combos <- expand.grid(A1 = c(-1, 1),
                            A2 = c(-1, 1),
                            A3 = c(-1, 1),
                            KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
      outcomes <- NULL
      for (r in 1:nrow(combos)) {
        outcomes[r] <- CV_predict(data = train_data, theta = theta,
                                  A1 = combos[r,1],
                                  A2 = combos[r,2],
                                  A3 = combos[r,3])
      }
      optimal_decision <- combos[which.max(outcomes),]
      fold_scores[i] <- CV_predict(data = test_data, theta = theta,
                                   A1 = optimal_decision[1],
                                   A2 = optimal_decision[2],
                                   A3 = optimal_decision[3])
    }
    else if(metric == "MSE"){
      fold_scores[i] <- CV_predict_loss(test_data, theta)
    }
    else if(metric == "MSE_Q"){
      
      fold_scores[i] <- CV_loss_Q(test_data, theta)
      # print(fold_scores[i])
    }
    else{print("Wrong Metric")}
  }
  
  return(list(fold_scores = fold_scores,
              lambda = lambda,
              D = D,
              metric = metric))
}
