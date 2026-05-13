suppl_setting3_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared"

source(file.path(suppl_setting3_dir, "nloptr_Setting3.R"))

spec_results <- run_setting3_parameter_specs(
  mc_n = 5000,
  maxeval = 50,
  local_maxeval = 20,
  n_starts = 1,
  print_level = 0
)

for (spec_name in names(spec_results)) {
  spec <- spec_results[[spec_name]]
  message(
    spec_name,
    ": best_value = ",
    signif(spec$best_value, 6),
    ", output = ",
    spec$output_path
  )
}
