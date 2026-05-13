######################## SQlearning #######################
fused_ridge <- function(y, X, D, lambda = 1e-2, gamma = 0) {
  p <- ncol(X)
  
  A <- crossprod(X) + gamma * diag(p) + lambda * crossprod(D)
  b <- crossprod(X, y)
  
  fit <- tryCatch(
    solve(A, b),
    error = function(e) {
      solve(A + 1e-8 * diag(p), b)
    }
  )
  
  drop(fit)
}

SQlearning_L2 <- function(data_original, 
                       warmstart, lambda, gamma, D, max_iter = 5000, tol = 1e-06){
  data_original <- prepare_setting2_data(data_original)
  
  ## Extract data for each stage
  data_stage1 <- data_original %>% dplyr::select(Y, A1)
  data_stage2 <- data_original %>% filter(G1 == 1) %>% dplyr::select(Y, A1, A2, A1A2)
  data_stage3 <- data_original %>% filter(G2 == 1) %>% dplyr::select(Y, A1, A2, A1A2, G1, A3, A1A3, A2A3)
  Y <- data_original$Y
  
  ## Create blocks for decision rules
  A3_block <- dplyr::select(data_original, A3, A1A3, A2A3)
  A2_block <- dplyr::select(data_original, A2, A1A2)
  A1_block <- dplyr::select(data_original, A1)
  
  theta <- warmstart
  theta_prev <- warmstart - 1
  iter <- 0
  while(sqrt(sum((theta- theta_prev)^2)) > tol 
        & iter < max_iter){
    
    iter <- iter + 1
    theta_prev <- theta
    
    A3_decision <- theta[6:8]
    A2_decision <- theta[11:12]
    A1_decision <- theta[14]
    
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
    X_combined <- as.matrix(X_combined)
    col_names <- c(paste0("Q3_",c("(Intercept)","A1","A2","A1A2","G1","A3","A1A3","A2A3")),
                   paste0("Q2_",c("(Intercept)","A1","A2","A1A2")),
                   paste0("Q1_",c("(Intercept)","A1")))
    colnames(X_combined) <- col_names
    
    ## Run fused lasso regression
    result <- fused_ridge(Y_combined, X_combined, D = D, lambda = lambda, gamma = gamma)
    theta <- result
  }
  col_names <- c(paste0("",c("(Intercept)","A1","A2","A1A2","G1","A3","A1A3","A2A3")),
                 paste0("",c("(Intercept)","A1","A2","A1A2")),
                 paste0("",c("(Intercept)","A1")))
  names(theta) <- col_names
  if(iter >= max_iter){warning("SQlearning_L2 reached max_iter before convergence.")}
  results <- list(theta = theta,
                  lambda = lambda,
                  iter = iter,
                  optimal_A1 = optimal_A1,
                  optimal_A2 = optimal_A2,
                  optimal_A3 = optimal_A3)
  return(results)
  
}

################### CV for optimal lambda searching#####################################
## We use optimal mean counterfactual outcome under optimal decision rule as a metric to evaluate current lambda selection

CV_SQlearning_L2 <- function(data_original,
                          warmstart, lambda, gamma, D, nfolds, metric = "outcome",
                          max_iter = 5000, tol = 1e-06){
  data_original <- prepare_setting2_data(data_original)
  fold_scores <- NULL
  folds <- createFolds(y = data_original$Y, k = nfolds)
  # return(folds)
  for(i in 1:nfolds){
    train_data <- data_original[-folds[[i]], ]
    test_data  <- data_original[folds[[i]], ]
    
    results <- SQlearning_L2(train_data, warmstart, lambda, gamma, D, max_iter = max_iter, tol = tol)
    # print(results)
    ## Evaluate all candidate combinations of treatments to determine the optimal one
    theta <- results$theta #A1, A2, A3 have the values 1 or -1, we need to find the binary combination of them which generates the largest outcome
    names(theta) <- c(paste0("Q3_",c("(Intercept)","A1","A2","A1A2","G1","A3","A1A3","A2A3")),
                      paste0("Q2_",c("(Intercept)","A1","A2","A1A2")),
                      paste0("Q1_",c("(Intercept)","A1")))
    
    ## Record the outcome of test data with optimal decisions
    
    if(metric == "outcome"){
      combos <- expand.grid(A1 = c(-1, 1),
                            A2 = c(-1, 1),
                            A3 = c(-1, 1),
                            KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
      ## Find the optimal decisions
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
      names(theta) <- c(paste0("Q3_",c("(Intercept)","A1","A2","A1A2","G1","A3","A1A3","A2A3")),
                        paste0("Q2_",c("(Intercept)","A1","A2","A1A2")),
                        paste0("Q1_",c("(Intercept)","A1")))
      
      fold_scores[i] <- CV_loss_Q(test_data, theta)
    }
    else{print("Wrong Metric")}
  }
  
  ## Return lambda and return mean outcomes as CV score
  return(list(fold_scores = fold_scores,
              lambda = lambda,
              D = D,
              metric = metric))
  
}
