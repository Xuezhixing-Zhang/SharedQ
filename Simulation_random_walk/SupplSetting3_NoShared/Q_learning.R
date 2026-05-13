################## Q learning ##############
Q_learning <- function(data_original){
  
  ## Q3
  data_Q3 <- subset(data_original, R2 == 0 & R1 == 0)
  Q3_fit <- lm(Y ~ O1 + A1 + O1:A1 + O2 + A2 + O2:A2 + A1:A2 + O3 + A3 + O3:A3 + A2:A3 + A1:A2:A3, data=data_Q3)
  
  A3_block <- cbind(A3 = data_original$A3, 
                    `O3:A3` = data_original$O3*data_original$A3, 
                    `A2:A3` = data_original$A2*data_original$A3, 
                    `A1:A2:A3` = data_original$A1*data_original$A2*data_original$A3)
  b3 <- coef(Q3_fit)[c("A3","O3:A3","A2:A3","A1:A2:A3")]
  real_A3 <- as.numeric(as.matrix(A3_block) %*% b3)
  pseudo_A3 <- as.numeric(as.matrix(-A3_block) %*% b3)
  max_A3 <- pmax(real_A3, pseudo_A3)
  
  optimal_A3 <- ifelse(real_A3 >= pseudo_A3, data_original$A3, -data_original$A3)
  Y_optimal_Q3 <- ifelse(data_original$R2 == 0 & data_original$R1 == 0,
                         data_original$Y - real_A3 + max_A3,
                         data_original$Y)
  
  ## Q2
  data_Q2 <- data_original %>% 
    mutate(Y = Y_optimal_Q3) %>% 
    filter(R1 == 0) %>% 
    select(Y, O1, A1, O2, A2)
  
  Q2_fit <- lm(Y ~ O1 + A1 + O1:A1 + O2 + A2 + O2:A2 + A1:A2, data=data_Q2)
  
  A2_block <- cbind(A2 = data_original$A2, 
                    `O2:A2` = data_original$O2*data_original$A2, 
                    `A1:A2` = data_original$A1*data_original$A2)
  b2 <- coef(Q2_fit)[c("A2","O2:A2","A1:A2")]
  real_A2 <- as.numeric(as.matrix(A2_block) %*% b2)
  pseudo_A2 <- as.numeric(as.matrix(-A2_block) %*% b2)
  max_A2 <- pmax(real_A2, pseudo_A2)
  
  optimal_A2 <- ifelse(real_A2 >= pseudo_A2, data_original$A2, -data_original$A2)
  Y_optimal_Q2 <- ifelse(data_original$R1 == 0,
                         Y_optimal_Q3 - real_A2 + max_A2,
                         Y_optimal_Q3)
  
  ## Q1
  data_Q1 <- data_original %>% select(Y, O1, A1) %>% mutate(Y = Y_optimal_Q2)
  Q1_fit <- lm(Y ~ O1 + A1 + O1:A1, data=data_Q1)
  A1_block <- cbind(A1 = data_original$A1, 
                    `O1:A1` = data_original$O1*data_original$A1)
  b1 <- coef(Q1_fit)[c("A1","O1:A1")]
  real_A1 <- as.numeric(as.matrix(A1_block) %*% b1)
  pseudo_A1 <- as.numeric(as.matrix(-A1_block) %*% b1)
  max_A1 <- pmax(real_A1, pseudo_A1)
  optimal_A1 <- ifelse(real_A1 >= pseudo_A1, data_original$A1, -data_original$A1)
  
  
  theta <- c(
    coef(Q3_fit)[c("(Intercept)","O1","A1","O1:A1","O2","A2","O2:A2","A1:A2","O3","A3","O3:A3","A2:A3","A1:A2:A3")],
    coef(Q2_fit)[c("(Intercept)","O1","A1","O1:A1","O2","A2","O2:A2","A1:A2")],
    coef(Q1_fit)[c("(Intercept)","O1","A1","O1:A1")]
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

