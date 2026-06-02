Sys.setenv(
  SETTING4_DIR = "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting4_NoShared",
  SETTING4_SPEC = Sys.getenv("SETTING4_SPEC", unset = "pqff_separated_parsimonious"),
  SETTING4_SEED = Sys.getenv("SETTING4_SEED", unset = "701")
)

source("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting4/Simulation_Setting4.R")

if (sys.nframe() == 0) {
  ns_value <- Sys.getenv("SETTING4_NS", unset = "")
  ns <- if (nzchar(ns_value)) as.integer(strsplit(ns_value, ",", fixed = TRUE)[[1]]) else c(100, 300, 500, 1000)
  n_reps <- setting4_int_env("SETTING4_N_REPS", 200)
  run_setting4_simulation(ns = ns, n_reps = n_reps)
}
