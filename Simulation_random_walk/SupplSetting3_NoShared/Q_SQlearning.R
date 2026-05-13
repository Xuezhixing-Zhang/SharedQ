######################## SQlearning (setting 3) #######################
SQlearning <- function(data_original,
                       warmstart, lambda, D, max_iter = 5000, tol = 1e-06){
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
  result <- NULL
  A3_decision <- theta[10:13]
  A2_decision <- theta[19:21]
  A1_decision <- theta[24:25]
  real_A3 <- as.numeric(as.matrix(A3_block) %*% A3_decision)
  pseudo_A3 <- as.numeric(as.matrix(-A3_block) %*% A3_decision)
  optimal_A3 <- ifelse(real_A3 >= pseudo_A3, data_original$A3, -data_original$A3)
  real_A2 <- as.numeric(as.matrix(A2_block) %*% A2_decision)
  pseudo_A2 <- as.numeric(as.matrix(-A2_block) %*% A2_decision)
  optimal_A2 <- ifelse(real_A2 >= pseudo_A2, data_original$A2, -data_original$A2)
  real_A1 <- as.numeric(as.matrix(A1_block) %*% A1_decision)
  pseudo_A1 <- as.numeric(as.matrix(-A1_block) %*% A1_decision)
  optimal_A1 <- ifelse(real_A1 >= pseudo_A1, data_original$A1, -data_original$A1)
  delta <- sqrt(sum((theta - theta_prev)^2))
  while (is.finite(delta) && delta > tol && iter < max_iter) {
    
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
    
    result <- genlasso(Y_combined, X_combined, D = D, eps = 0.01)
    theta_new <- as.numeric(coef(result, lambda = lambda)$beta)
    bad <- is.na(theta_new) | is.nan(theta_new) | is.infinite(theta_new)
    if (any(bad)) {
      theta_new[bad] <- theta_prev[bad]
      warning("SQlearning produced non-finite coefficients; replaced them with previous-iteration values.")
    }
    theta <- theta_new
    delta <- sqrt(sum((theta - theta_prev)^2))
  }
  
  col_names <- c(
    paste0("", c("(Intercept)","O1","A1","O1:A1","O2","A2","O2:A2","A1:A2","O3","A3","O3:A3","A2:A3","A1:A2:A3")),
    paste0("", c("(Intercept)","O1","A1","O1:A1","O2","A2","O2:A2","A1:A2")),
    paste0("", c("(Intercept)","O1","A1","O1:A1"))
  )
  names(theta) <- col_names
  if (iter >= max_iter) { 
    warning("SQlearning reached max_iter before convergence.") 
    notes <- paste0("SQlearning reached max_iter before convergence.")
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

################### CV helpers (setting 2) ############################
CV_predict <- function(data, theta, A1, A2, A3){
  
  data_Q1 <- subset(data, R1 == 1)
  data_Q2 <- subset(data, R1 == 0 & R2 == 1)
  data_Q3 <- subset(data, R1 == 0 & R2 == 0)
  
  getc <- function(nm) if (nm %in% names(theta)) unname(theta[nm]) else 0
  
  ## Q3
  b30        <- getc("Q3_(Intercept)")
  b3O1       <- getc("Q3_O1")
  b3A1       <- getc("Q3_A1")
  b3O1A1     <- getc("Q3_O1:A1")
  b3O2       <- getc("Q3_O2")
  b3A2       <- getc("Q3_A2")
  b3O2A2     <- getc("Q3_O2:A2")
  b3A1A2     <- getc("Q3_A1:A2")
  b3O3       <- getc("Q3_O3")
  b3A3       <- getc("Q3_A3")
  b3O3A3     <- getc("Q3_O3:A3")
  b3A2A3     <- getc("Q3_A2:A3")
  b3A1A2A3   <- getc("Q3_A1:A2:A3")
  
  ## Q2
  b20     <- getc("Q2_(Intercept)")
  b2O1    <- getc("Q2_O1")
  b2A1    <- getc("Q2_A1")
  b2O1A1  <- getc("Q2_O1:A1")
  b2O2    <- getc("Q2_O2")
  b2A2    <- getc("Q2_A2")
  b2O2A2  <- getc("Q2_O2:A2")
  b2A1A2  <- getc("Q2_A1:A2")
  
  ## Q1
  b10    <- getc("Q1_(Intercept)")
  b1O1   <- getc("Q1_O1")
  b1A1   <- getc("Q1_A1")
  b1O1A1 <- getc("Q1_O1:A1")
  
  pred_Q1 <- if (nrow(data_Q1) > 0) {
    o1 <- data_Q1$O1
    b10 + b1O1 * o1 + b1A1 * A1 + b1O1A1 * (o1 * A1)
  } else numeric(0)
  
  pred_Q2 <- if (nrow(data_Q2) > 0) {
    o1 <- data_Q2$O1; o2 <- data_Q2$O2
    b20 +
      b2O1   * o1 +
      b2A1   * A1 +
      b2O1A1 * (o1 * A1) +
      b2O2   * o2 +
      b2A2   * A2 +
      b2O2A2 * (o2 * A2) +
      b2A1A2 * (A1 * A2)
  } else numeric(0)
  
  pred_Q3 <- if (nrow(data_Q3) > 0) {
    o1 <- data_Q3$O1; o2 <- data_Q3$O2; o3 <- data_Q3$O3
    b30 +
      b3O1     * o1 +
      b3A1     * A1 +
      b3O1A1   * (o1 * A1) +
      b3O2     * o2 +
      b3A2     * A2 +
      b3O2A2   * (o2 * A2) +
      b3A1A2   * (A1 * A2) +
      b3O3     * o3 +
      b3A3     * A3 +
      b3O3A3   * (o3 * A3) +
      b3A2A3   * (A2 * A3) +
      b3A1A2A3 * (A1 * A2 * A3)
  } else numeric(0)
  
  preds <- c(unlist(pred_Q1), unlist(pred_Q2), unlist(pred_Q3))
  if (length(preds) == 0) return(NA_real_)
  return(mean(preds, na.rm = TRUE))
}
##########################################################################
###############################################################################
CV_loss_Q <- function(data, theta) {
  # Helper to fetch a named coef (0 if absent)
  getc <- function(nm) if (nm %in% names(theta)) unname(theta[nm]) else 0
  
  n <- nrow(data)
  if (is.null(n) || n == 0) return(NA_real_)
  
  # ---------- Greedy decisions (only action-dependent parts) ----------
  # Q3 coefficients relevant for A3 decision
  A3_decision <- c(
    Q3_A3        = getc("Q3_A3"),
    Q3_O3A3      = getc("Q3_O3:A3"),
    Q3_A2A3      = getc("Q3_A2:A3"),
    Q3_A1A2A3    = getc("Q3_A1:A2:A3")
  )
  
  # Q2 coefficients relevant for A2 decision
  A2_decision <- c(
    Q2_A2        = getc("Q2_A2"),
    Q2_O2A2      = getc("Q2_O2:A2"),
    Q2_A1A2      = getc("Q2_A1:A2")
  )
  
  # Q1 coefficients relevant for A1 decision
  A1_decision <- c(
    Q1_A1        = getc("Q1_A1"),
    Q1_O1A1      = getc("Q1_O1:A1")
  )
  
  # ---------- Pseudo-outcomes (Bellman / greedy improvements) ----------
  
  Y <- data$Y
  
  ## Q3: improvement over A3
  real_A3 <- with(data,
                  A3_decision["Q3_A3"]     * A3 +
                    A3_decision["Q3_O3A3"]  * (O3 * A3) +
                    A3_decision["Q3_A2A3"]  * (A2 * A3) +
                    A3_decision["Q3_A1A2A3"] * (A1 * A2 * A3)
  )
  
  pseudo_A3 <- with(data,
                    A3_decision["Q3_A3"]     * (-A3) +
                      A3_decision["Q3_O3A3"]  * (-O3 * A3) +
                      A3_decision["Q3_A2A3"]  * (-A2 * A3) +
                      A3_decision["Q3_A1A2A3"] * (-A1 * A2 * A3)
  )
  
  max_A3 <- pmax(real_A3, pseudo_A3)
  
  Y_optimal_Q3 <- ifelse(
    data$R2 == 0 & data$R1 == 0,
    Y - real_A3 + max_A3,  # stage-3 reachable
    Y                      # else just Y
  )
  
  ## Q2: improvement over A2
  real_A2 <- with(data,
                  A2_decision["Q2_A2"]   * A2 +
                    A2_decision["Q2_O2A2"] * (O2 * A2) +
                    A2_decision["Q2_A1A2"] * (A1 * A2)
  )
  
  pseudo_A2 <- with(data,
                    A2_decision["Q2_A2"]   * (-A2) +
                      A2_decision["Q2_O2A2"] * (-O2 * A2) +
                      A2_decision["Q2_A1A2"] * (-A1 * A2)
  )
  
  max_A2 <- pmax(real_A2, pseudo_A2)
  
  Y_optimal_Q2 <- ifelse(
    data$R1 == 0,
    Y_optimal_Q3 - real_A2 + max_A2, 
    Y_optimal_Q3
  )
  
  # ---------- Targets per stage (robust to empty subsets) ----------
  
  idx3 <- which(data$R2 == 0 & data$R1 == 0)
  idx2 <- which(data$R1 == 0)
  
  # Q3 fits Y on stage-3 rows
  Y3 <- if (length(idx3)) Y[idx3] else numeric(0)
  
  # Q2 fits pseudo-outcome from Q3 on stage-2 rows
  Y2 <- if (length(idx2)) Y_optimal_Q3[idx2] else numeric(0)
  
  # Q1 fits pseudo-outcome from Q2 on all rows
  Y1 <- Y_optimal_Q2
  
  Y_combined <- c(Y3, Y2, Y1)
  
  # ---------- Design matrices with prefixed names ----------
  
  # Q3 design (only for rows reaching stage 3)
  X3 <- if (length(idx3)) {
    mm <- model.matrix(
      ~ O1 + A1 + O1:A1 +
        O2 + A2 + O2:A2 + A1:A2 +
        O3 + A3 + O3:A3 + A2:A3 + A1:A2:A3,
      data = data[idx3, , drop = FALSE]
    )
    colnames(mm) <- paste0("Q3_", colnames(mm))
    mm
  } else NULL
  
  # Q2 design (rows with R1 == 0)
  X2 <- if (length(idx2)) {
    mm <- model.matrix(
      ~ O1 + A1 + O1:A1 +
        O2 + A2 + O2:A2 + A1:A2,
      data = data[idx2, , drop = FALSE]
    )
    colnames(mm) <- paste0("Q2_", colnames(mm))
    mm
  } else NULL
  
  # Q1 design (all rows)
  X1 <- {
    mm <- model.matrix(
      ~ O1 + A1 + O1:A1,
      data = data
    )
    colnames(mm) <- paste0("Q1_", colnames(mm))
    mm
  }
  
  mats <- Filter(Negate(is.null), list(X3, X2, X1))
  if (length(mats) == 0L) return(NA_real_)
  
  X_combined <- Matrix::bdiag(mats)
  X_combined <- as.matrix(X_combined)
  
  # Make sure colnames survive bdiag
  colnames(X_combined) <- unlist(lapply(mats, colnames), use.names = FALSE)
  
  # ---------- Align theta by name and compute loss ----------
  
  theta_aligned <- theta[colnames(X_combined)]
  if (anyNA(theta_aligned)) theta_aligned[is.na(theta_aligned)] <- 0
  
  preds <- as.numeric(X_combined %*% theta_aligned)
  loss  <- mean((Y_combined - preds)^2)
  
  return(loss)
}




###############################################################################
CV_predict_loss <- function(data, theta){
  
  #Only keep observations that uses primary outcomes at each stage.
  data_Q1 <- subset(data, R1 == 1) #Responders at stage 1
  data_Q2 <- subset(data, R1 == 0 & R2 == 1) #Responders at stage 2
  data_Q3 <- subset(data, R1 == 0 & R2 == 0)  #NonResponders at stage 2
  
  getc <- function(nm) if (nm %in% names(theta)) unname(theta[nm]) else 0
  
  b30        <- getc("Q3_(Intercept)")
  b3O1       <- getc("Q3_O1")
  b3A1       <- getc("Q3_A1")
  b3O1A1     <- getc("Q3_O1:A1")
  b3O2       <- getc("Q3_O2")
  b3A2       <- getc("Q3_A2")
  b3O2A2     <- getc("Q3_O2:A2")
  b3A1A2     <- getc("Q3_A1:A2")
  b3O3       <- getc("Q3_O3")
  b3A3       <- getc("Q3_A3")
  b3O3A3     <- getc("Q3_O3:A3")
  b3A2A3     <- getc("Q3_A2:A3")
  b3A1A2A3   <- getc("Q3_A1:A2:A3")
  
  b20     <- getc("Q2_(Intercept)")
  b2O1    <- getc("Q2_O1")
  b2A1    <- getc("Q2_A1")
  b2O1A1  <- getc("Q2_O1:A1")
  b2O2    <- getc("Q2_O2")
  b2A2    <- getc("Q2_A2")
  b2O2A2  <- getc("Q2_O2:A2")
  b2A1A2  <- getc("Q2_A1:A2")
  
  b10    <- getc("Q1_(Intercept)")
  b1O1   <- getc("Q1_O1")
  b1A1   <- getc("Q1_A1")
  b1O1A1 <- getc("Q1_O1:A1")
  
  pred_Q1 <- if (nrow(data_Q1) > 0) {
    o1 <- data_Q1$O1
    (data_Q1$Y - (b10 + b1O1 * o1 + b1A1 * data_Q1$A1 + b1O1A1 * (o1 * data_Q1$A1)))^2
  } else numeric(0)
  
  pred_Q2 <- if (nrow(data_Q2) > 0) {
    o1 <- data_Q2$O1; o2 <- data_Q2$O2
    mu2 <- b20 +
      b2O1   * o1 +
      b2A1   * data_Q2$A1 +
      b2O1A1 * (o1 * data_Q2$A1) +
      b2O2   * o2 +
      b2A2   * data_Q2$A2 +
      b2O2A2 * (o2 * data_Q2$A2) +
      b2A1A2 * (data_Q2$A1 * data_Q2$A2)
    (data_Q2$Y - mu2)^2
  } else numeric(0)
  
  pred_Q3 <- if (nrow(data_Q3) > 0) {
    o1 <- data_Q3$O1; o2 <- data_Q3$O2; o3 <- data_Q3$O3
    mu3 <- b30 +
      b3O1     * o1 +
      b3A1     * data_Q3$A1 +
      b3O1A1   * (o1 * data_Q3$A1) +
      b3O2     * o2 +
      b3A2     * data_Q3$A2 +
      b3O2A2   * (o2 * data_Q3$A2) +
      b3A1A2   * (data_Q3$A1 * data_Q3$A2) +
      b3O3     * o3 +
      b3A3     * data_Q3$A3 +
      b3O3A3   * (o3 * data_Q3$A3) +
      b3A2A3   * (data_Q3$A2 * data_Q3$A3) +
      b3A1A2A3 * (data_Q3$A1 * data_Q3$A2 * data_Q3$A3)
    (data_Q3$Y - mu3)^2
  } else numeric(0)
  
  preds <- c(unlist(pred_Q1), unlist(pred_Q2), unlist(pred_Q3))
  if (length(preds) == 0) return(NA_real_)
  return(mean(preds, na.rm = TRUE))
}

CV_SQlearning <- function(data_original,
                          warmstart, lambda, D, nfolds, metric = "outcome",
                          max_iter = 5000, tol = 1e-06){
  fold_scores <- NULL
  folds <- createFolds(y = data_original$Y, k = nfolds)
  for(i in 1:nfolds){
    train_data <- data_original[-folds[[i]], ]
    test_data  <- data_original[folds[[i]], ]
    
    results <- SQlearning(train_data, warmstart, lambda, D, max_iter = max_iter, tol = tol)
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
