setting1_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting1"

source(file.path(setting1_dir, "nloptr_Setting1.R"))
source(file.path(setting1_dir, "Q_Conventional.R"))
source(file.path(dirname(setting1_dir), "calibration_runner_utils.R"))

runner_args <- calibration_runner_args(
  default_mc_n = 5000,
  default_maxeval = 50,
  default_local_maxeval = 20,
  default_n_starts = 1,
  default_print_level = 0
)
selected_specs <- select_calibration_specs(
  setting1_shared_parameter_specs,
  default_spec = "balanced_small"
)

message("Selected specs: ", calibration_selected_names(selected_specs))
message("Calibration controls: ", calibration_runner_args_summary(runner_args))

spec_results <- do.call(run_setting1_shared_parameter_specs, c(
  list(specs = selected_specs),
  runner_args
))

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
