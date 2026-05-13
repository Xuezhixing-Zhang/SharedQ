Generate_data <- function(n){
  
  data_large <- readRDS("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting3/calibration/data_original.rds")
  indices <- sample(1:nrow(data_large), size = n)
  data_all <- data_large[indices,]
  data_all$Y <- data_all$Y +rnorm(n)
  
  return(data_all)
  
}
