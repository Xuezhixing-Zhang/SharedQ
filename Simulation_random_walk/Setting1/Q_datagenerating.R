Generate_data <- function(n){
  data_path <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting1/calibration/data_original.rds"
  if (!file.exists(data_path)) {
    stop("Missing Monte Carlo population dataset: ", data_path,
         ". Run nloptr_Setting1.R or Q_learning_Setting_1(..., save = TRUE) first.")
  }

  data_large <- readRDS(data_path)
  indices <- sample(1:nrow(data_large), size = n)
  data_all <- data_large[indices, ]
  data_all$Y <- data_all$Y + rnorm(n)

  return(data_all)
}
