suppl_setting3_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/SupplSetting3_NoShared"

source(file.path(suppl_setting3_dir, "nloptr_Setting3.R"))
source(file.path(dirname(suppl_setting3_dir), "calibration_runner_utils.R"))

runner_args <- calibration_runner_args(
  default_mc_n = 5000,
  default_maxeval = 50,
  default_local_maxeval = 20,
  default_n_starts = 1,
  default_print_level = 0
)
selected_specs <- select_calibration_specs(
  setting3_parameter_specs,
  default_spec = "separated_moderate"
)
output_dir <- calibration_output_dir(suppl_setting3_calibration_dir)

message("Selected specs: ", calibration_selected_names(selected_specs))
message("Calibration controls: ", calibration_runner_args_summary(runner_args))
message("Calibration output dir: ", output_dir)

spec_results <- do.call(run_setting3_parameter_specs, c(
  list(specs = selected_specs, output_dir = output_dir),
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
