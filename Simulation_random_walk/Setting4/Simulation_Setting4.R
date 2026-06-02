source("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting4/Q_functions.R")

setting4_simulation_results_dir <- file.path(setting4_dir, "simulation_results")
dir.create(setting4_simulation_results_dir, showWarnings = FALSE, recursive = TRUE)

setting4_bool_env <- function(name, default = FALSE) {
  value <- tolower(Sys.getenv(name, unset = ""))
  if (!nzchar(value)) return(default)
  value %in% c("1", "true", "yes", "y")
}

setting4_int_env <- function(name, default) {
  value <- Sys.getenv(name, unset = "")
  if (!nzchar(value)) return(default)
  as.integer(value)
}

setting4_num_env <- function(name, default) {
  value <- Sys.getenv(name, unset = "")
  if (!nzchar(value)) return(default)
  as.numeric(value)
}

run_setting4_simulation <- function(
  ns = c(100, 300, 500, 1000),
  n_reps = 200,
  spec = Sys.getenv("SETTING4_SPEC", unset = "pqff_shared_parsimonious"),
  seed = setting4_int_env("SETTING4_SEED", 601),
  calibration_mc_n = setting4_int_env("SETTING4_CALIBRATION_MC_N", 100000),
  noise_sd = setting4_num_env("SETTING4_NOISE_SD", 1),
  result_prefix = Sys.getenv("SETTING4_RESULT_PREFIX", unset = "results"),
  recalibrate = setting4_bool_env("SETTING4_RECALIBRATE", FALSE)
) {
  calibration_path <- file.path(setting4_calibration_dir, paste0("calibration_", spec, ".rds"))

  calibration <- NULL
  if (file.exists(calibration_path) && !isTRUE(recalibrate)) {
    calibration <- readRDS(calibration_path)
    if (is.null(calibration$gamma) ||
        !identical(calibration$source_mode, "synthetic_parametric") ||
        !identical(calibration$spec, spec)) {
      message("Existing Setting IV calibration is stale or invalid; rebuilding ", calibration_path)
      calibration <- NULL
    }
  }
  if (is.null(calibration)) {
    calibration <- build_setting4_calibration(
      output_path = calibration_path,
      spec = spec,
      mc_n = calibration_mc_n,
      seed = seed
    )
  }
  gamma_true <- calibration$gamma
  theta_true <- calibration$theta

  set.seed(seed)
  for (n in ns) {
    results_n <- vector("list", n_reps)
    for (i in seq_len(n_reps)) {
      message("Setting IV synthetic-parametric, spec=", spec, ", n=", n, ", rep=", i)
      results_n[[i]] <- Simu_IV(n, gamma_true, theta_true, noise_sd = noise_sd)
      saveRDS(
        results_n,
        file.path(setting4_simulation_results_dir, paste0(result_prefix, "_", n, ".rds"))
      )
    }
    names(results_n) <- paste0("result_", seq_len(n_reps))
    saveRDS(
      results_n,
      file.path(setting4_simulation_results_dir, paste0(result_prefix, "_", n, ".rds"))
    )
  }

  invisible(TRUE)
}

if (sys.nframe() == 0) {
  ns_value <- Sys.getenv("SETTING4_NS", unset = "")
  ns <- if (nzchar(ns_value)) as.integer(strsplit(ns_value, ",", fixed = TRUE)[[1]]) else c(100, 300, 500, 1000)
  n_reps <- setting4_int_env("SETTING4_N_REPS", 200)
  run_setting4_simulation(ns = ns, n_reps = n_reps)
}
