script_args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", script_args, value = TRUE)
if (length(file_arg) > 0) {
  root_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[[1]])))
} else if (dir.exists(file.path(getwd(), "Simulation_random_walk"))) {
  root_dir <- file.path(getwd(), "Simulation_random_walk")
} else {
  root_dir <- getwd()
}

source(file.path(root_dir, "validate_candidate_calibration.R"))
source(file.path(root_dir, "calibration_runner_utils.R"))

smoke_subdir <- "candidate_constraint_smoke"
smoke_report_only <- calibration_bool_env("CALIBRATION_REPORT_ONLY", FALSE)
smoke_runner_args <- calibration_runner_args(
  default_mc_n = 5000,
  default_maxeval = 50,
  default_local_maxeval = 20,
  default_n_starts = 1,
  default_print_level = 0
)

smoke_artifacts <- function(artifacts) {
  artifacts <- artifacts[names(artifacts) != "smoke_default"]
  stats::setNames(
    file.path("calibration", smoke_subdir, basename(artifacts)),
    names(artifacts)
  )
}

run_setting_smoke <- function(
  config,
  source_file,
  runner_name,
  runner_args,
  report_title
) {
  setting_env <- new.env(parent = globalenv())
  source(file.path(root_dir, config$dir, source_file), local = setting_env)

  output_dir <- file.path(root_dir, config$dir, "calibration", smoke_subdir)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  runner <- get(runner_name, envir = setting_env)
  all_specs <- eval(formals(runner)$specs, envir = environment(runner))
  selected_specs <- select_calibration_specs(all_specs, config$default_spec)
  if (isTRUE(smoke_report_only)) {
    message(report_config_name(config), ": report-only mode")
  } else {
    do.call(runner, c(
      list(output_dir = output_dir, specs = selected_specs),
      runner_args
    ))
  }

  report_config <- config
  report_config$artifacts <- smoke_artifacts(config$artifacts)
  report_config$artifacts <- report_config$artifacts[
    names(report_config$artifacts) %in% names(selected_specs)
  ]

  rows <- do.call(rbind, lapply(names(report_config$artifacts), function(spec) {
    artifact_path <- file.path(root_dir, report_config$dir, report_config$artifacts[[spec]])
    candidate_rows(
      report_config$setting,
      spec,
      artifact_path,
      report_config$groups,
      report_config$candidate_tolerance
    )
  }))

  status <- write_report(
    report_config$dir,
    report_config$setting,
    rows,
    report_config$candidate_tolerance,
    report_stem = "candidate_calibration_smoke_report",
    report_title_suffix = report_title
  )
  data.frame(
    setting = report_config$setting,
    specs = calibration_selected_names(selected_specs),
    status = status,
    stringsAsFactors = FALSE
  )
}

report_config_name <- function(config) {
  config$setting
}

smoke_plan <- list(
  list(
    config = configs[[1]],
    source_file = "nloptr_Setting1.R",
    runner_name = "run_setting1_shared_parameter_specs",
    runner_args = smoke_runner_args
  ),
  list(
    config = configs[[2]],
    source_file = "nloptr_Setting2.R",
    runner_name = "run_setting2_parameter_specs",
    runner_args = smoke_runner_args
  ),
  list(
    config = configs[[3]],
    source_file = "nloptr_Setting3.R",
    runner_name = "run_setting3_parameter_specs",
    runner_args = smoke_runner_args
  ),
  list(
    config = configs[[4]],
    source_file = "nloptr_Setting3.R",
    runner_name = "run_setting3_parameter_specs",
    runner_args = smoke_runner_args
  )
)

statuses <- do.call(rbind, lapply(smoke_plan, function(plan) {
  run_setting_smoke(
    config = plan$config,
    source_file = plan$source_file,
    runner_name = plan$runner_name,
    runner_args = plan$runner_args,
    report_title = "Candidate Calibration Smoke Report"
  )
}))

print(statuses, row.names = FALSE)
