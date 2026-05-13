######################## SQlearning #######################
# This file contains the SQ learning method with L1 penalty for Setting I.
SQlearning <- function(data_original, 
                       warmstart, lambda, D, max_iter = 5000, tol = 1e-06){
  data_original <- prepare_setting1_data(data_original)
  
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
    result <- genlasso(Y_combined, X_combined, D = D, eps = 0.01)
    theta <- as.numeric(coef(result, lambda = lambda)$beta)
  }
  col_names <- c(paste0("",c("(Intercept)","A1","A2","A1A2","G1","A3","A1A3","A2A3")),
                 paste0("",c("(Intercept)","A1","A2","A1A2")),
                 paste0("",c("(Intercept)","A1")))
  names(theta) <- col_names
  if(iter >= max_iter){warning("SQlearning reached max_iter before convergence.")}
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

CV_predict <- function(data, theta, A1, A2, A3){
  data <- prepare_setting1_data(data)
 
  data_Q1 <- subset(data, G1 == 0 & G2 == 0)
  data_Q2 <- subset(data, G1 == 1 & G2 == 0)
  data_Q3 <- subset(data, G2 == 1)
  
  getc <- function(nm) if (nm %in% names(theta)) unname(theta[nm]) else 0
  
  b30      <- getc("Q3_(Intercept)")
  b3A1     <- getc("Q3_A1")
  b3A2     <- getc("Q3_A2")
  b3A1A2   <- getc("Q3_A1A2")
  b3G1     <- getc("Q3_G1")
  b3A3     <- getc("Q3_A3")
  b3A1A3   <- getc("Q3_A1A3")
  b3A2A3   <- getc("Q3_A2A3")
  # b3A1A2A3 <- getc("Q3_A1A2A3")
  
  ## Q2 coefs
  b20    <- getc("Q2_(Intercept)")
  b2A1   <- getc("Q2_A1")
  b2A2   <- getc("Q2_A2")
  b2A1A2 <- getc("Q2_A1A2")
  
  ## Q1 coefs
  b10  <- getc("Q1_(Intercept)")
  b1A1 <- getc("Q1_A1")
  
  pred_Q1 <- if (nrow(data_Q1) > 0) {
    rep(b10 + b1A1 * A1, nrow(data_Q1))
  } else numeric(0)
  
  pred_Q2 <- if (nrow(data_Q2) > 0) {
    rep(b20 +
          b2A1   * A1 +
          b2A2   * A2 +
          b2A1A2 * (A1 * A2),
        nrow(data_Q2))
  } else numeric(0)
  
  pred_Q3 <- if (nrow(data_Q3) > 0) {
    g1 <- data_Q3$G1
    b30 +
      b3A1     * A1 +
      b3A2     * A2 +
      b3A1A2   * (A1 * A2) +
      b3G1     * g1 +
      b3A3     * A3 +
      b3A1A3   * (A1 * A3) +
      b3A2A3   * (A2 * A3)
      # b3A1A2A3 * (A1 * A2 * A3)
  } else numeric(0)
  
  preds <- c(unlist(pred_Q1), unlist(pred_Q2), unlist(pred_Q3))
  
  # In practice there should be rows overall; if not, return NA_real_ for clarity
  if (length(preds) == 0) return(NA_real_)
  return(mean(preds, na.rm=T))
}

CV_predict_loss <- function(data, theta){
  data <- prepare_setting1_data(data)
  
  data_Q1 <- subset(data, G1 == 0 & G2 == 0)
  data_Q2 <- subset(data, G1 == 1 & G2 == 0)
  data_Q3 <- subset(data, G2 == 1)
  
  getc <- function(nm) if (nm %in% names(theta)) unname(theta[nm]) else 0
  
  b30      <- getc("Q3_(Intercept)")
  b3A1     <- getc("Q3_A1")
  b3A2     <- getc("Q3_A2")
  b3A1A2   <- getc("Q3_A1A2")
  b3G1     <- getc("Q3_G1")
  b3A3     <- getc("Q3_A3")
  b3A1A3   <- getc("Q3_A1A3")
  b3A2A3   <- getc("Q3_A2A3")
  # b3A1A2A3 <- getc("Q3_A1A2A3")
  
  ## Q2 coefs
  b20    <- getc("Q2_(Intercept)")
  b2A1   <- getc("Q2_A1")
  b2A2   <- getc("Q2_A2")
  b2A1A2 <- getc("Q2_A1A2")
  
  ## Q1 coefs
  b10  <- getc("Q1_(Intercept)")
  b1A1 <- getc("Q1_A1")
  
  pred_Q1 <- if (nrow(data_Q1) > 0) {
    (data_Q1$Y - rep(b10 + b1A1 * data_Q1$A1, 1))^2
  } else numeric(0)
  
  pred_Q2 <- if (nrow(data_Q2) > 0) {
    (data_Q2$Y - rep(b20 +
          b2A1   * data_Q2$A1 +
          b2A2   * data_Q2$A2 +
          b2A1A2 * data_Q2$A1A2,1))^2
  } else numeric(0)
  
  pred_Q3 <- if (nrow(data_Q3) > 0) {
    pred3 <- b30 +
      b3A1     * data_Q3$A1 +
      b3A2     * data_Q3$A2 +
      b3A1A2   * data_Q3$A1A2 +
      b3G1     * data_Q3$G1 +
      b3A3     * data_Q3$A3 +
      b3A1A3   * data_Q3$A1A3 +
      b3A2A3   * data_Q3$A2A3
    (data_Q3$Y - pred3)^2
    # b3A1A2A3 * (A1 * A2 * A3)
  } else numeric(0)
  
  preds <- c(unlist(pred_Q1), unlist(pred_Q2), unlist(pred_Q3))
  
  # In practice there should be rows overall; if not, return NA_real_ for clarity
  if (length(preds) == 0) return(NA_real_)
  return(mean(preds, na.rm=T))
}

CV_SQlearning <- function(data_original,
                          warmstart, lambda, D, nfolds, metric = "outcome",
                          max_iter = 5000, tol = 1e-06){
  data_original <- prepare_setting1_data(data_original)
  fold_scores <- NULL
  folds <- createFolds(y = data_original$Y, k = nfolds)
  # return(folds)
  for(i in 1:nfolds){
    train_data <- data_original[-folds[[i]], ]
    test_data  <- data_original[folds[[i]], ]
    
    results <- SQlearning(train_data, warmstart, lambda, D, max_iter = max_iter, tol = tol)
    
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
# CV_SQlearning(data_simu, warmstart, lambda = 1000, D,nfolds = 5, metric = "MSE")



CV_loss_Q <- function(data,theta){
  data <- prepare_setting1_data(data)

  # Helper to fetch a named coef (0 if absent)
  getc <- function(nm) if (nm %in% names(theta)) unname(theta[nm]) else 0

  # Action-dependent parts for greedy improvements
  A3_decision <- c(
    Q3_A3      = getc("Q3_A3"),
    Q3_A1A3    = getc("Q3_A1A3"),
    Q3_A2A3    = getc("Q3_A2A3")
    # Q3_A1A2A3  = getc("Q3_A1A2A3")
  )
  A2_decision <- c(
    Q2_A2    = getc("Q2_A2"),
    Q2_A1A2  = getc("Q2_A1A2")
  )

  n <- nrow(data)
  if (is.null(n) || n == 0) return(NA_real_)

  # Ensure interactions exist for pseudo-outcomes
  ensure_col <- function(df, nm, expr) {
    if (!nm %in% names(df)) df[[nm]] <- eval(expr, df)
    df
  }
  data <- ensure_col(data, "A1A2", quote(A1*A2))
  data <- ensure_col(data, "A1A3", quote(A1*A3))
  data <- ensure_col(data, "A2A3", quote(A2*A3))
  # data <- ensure_col(data, "A1A2A3", quote(A1*A2*A3))

  # ---- Pseudo-outcomes (greedy improvements) ----
  real_A3 <- with(data,
                  A3_decision["Q3_A3"]     * A3 +
                    A3_decision["Q3_A1A3"]   * A1A3 +
                    A3_decision["Q3_A2A3"]   * A2A3
                    # A3_decision["Q3_A1A2A3"] * A1A2A3
  )
  pseudo_A3 <- with(data,
                    A3_decision["Q3_A3"]     * (-A3) +
                      A3_decision["Q3_A1A3"]   * (-A1A3) +
                      A3_decision["Q3_A2A3"]   * (-A2A3)
                      # A3_decision["Q3_A1A2A3"] * (-A1A2A3)
  )
  max_A3 <- pmax(real_A3, pseudo_A3)
  Y_optimal_Q3 <- with(data, G2*(Y - real_A3 + max_A3) + (1 - G2)*Y)

  real_A2 <- with(data,
                  A2_decision["Q2_A2"]   * A2 +
                    A2_decision["Q2_A1A2"] * A1A2
  )
  pseudo_A2 <- with(data,
                    A2_decision["Q2_A2"]   * (-A2) +
                      A2_decision["Q2_A1A2"] * (-A1A2)
  )
  max_A2 <- pmax(real_A2, pseudo_A2)
  Y_optimal_Q2 <- with(data, G1*(Y_optimal_Q3 - real_A2 + max_A2) + (1 - G1)*Y_optimal_Q3)

  # ---- Targets per stage ----
  idx3 <- which(data$G2 == 1L)
  idx2 <- which(data$G1 == 1L)

  Y3 <- if (length(idx3)) data$Y[idx3] else numeric(0)
  Y2 <- if (length(idx2)) Y_optimal_Q3[idx2] else numeric(0)
  Y1 <- Y_optimal_Q2

  # ---- Design matrices with prefixed names ----
  X3 <- if (length(idx3)) {
    mm <- model.matrix(~ A1 + A2 + A1A2 + G1 + A3 + A1A3 + A2A3,
                       data = data[idx3, , drop = FALSE])
    colnames(mm) <- paste0("Q3_", colnames(mm))
    mm
  } else NULL

  X2 <- if (length(idx2)) {
    mm <- model.matrix(~ A1 + A2 + A1A2,
                       data = data[idx2, , drop = FALSE])
    colnames(mm) <- paste0("Q2_", colnames(mm))
    mm
  } else NULL

  X1 <- {
    mm <- model.matrix(~ A1, data = data)
    colnames(mm) <- paste0("Q1_", colnames(mm))
    mm
  }

  # ---- Combine and compute loss ----
  Y_combined <- c(Y3, Y2, Y1)
  mats <- Filter(Negate(is.null), list(X3, X2, X1))
  if (length(mats) == 0L) return(NA_real_)

  X_combined <- Matrix::bdiag(mats)
  colnames(X_combined) <- unlist(lapply(mats, colnames), use.names = FALSE)
  X_combined <- as.matrix(X_combined)
  theta_aligned <- theta[colnames(X_combined)]
  if (anyNA(theta_aligned)) theta_aligned[is.na(theta_aligned)] <- 0

  loss <- mean((Y_combined - as.numeric(X_combined %*% theta_aligned))^2)
  return(loss)
}
