calibration_env <- function(name) {
  Sys.getenv(name, unset = "")
}

calibration_numeric_env <- function(name, default) {
  value <- calibration_env(name)
  if (!nzchar(value)) return(default)
  numeric_value <- suppressWarnings(as.numeric(value))
  if (is.na(numeric_value)) {
    stop(name, " must be numeric; got `", value, "`.")
  }
  numeric_value
}

calibration_integer_env <- function(name, default) {
  value <- calibration_numeric_env(name, default)
  if (value != as.integer(value)) {
    stop(name, " must be an integer; got `", value, "`.")
  }
  as.integer(value)
}

calibration_bool_env <- function(name, default = FALSE) {
  value <- tolower(calibration_env(name))
  if (!nzchar(value)) return(default)
  if (value %in% c("1", "true", "yes", "y")) return(TRUE)
  if (value %in% c("0", "false", "no", "n")) return(FALSE)
  stop(name, " must be boolean-like; got `", value, "`.")
}

calibration_runner_args <- function(
  default_mc_n = 5000,
  default_maxeval = 50,
  default_local_maxeval = 20,
  default_n_starts = 1,
  default_print_level = 0
) {
  list(
    mc_n = calibration_integer_env("CALIBRATION_MC_N", default_mc_n),
    maxeval = calibration_integer_env("CALIBRATION_MAXEVAL", default_maxeval),
    local_maxeval = calibration_integer_env("CALIBRATION_LOCAL_MAXEVAL", default_local_maxeval),
    n_starts = calibration_integer_env("CALIBRATION_N_STARTS", default_n_starts),
    print_level = calibration_integer_env("CALIBRATION_PRINT_LEVEL", default_print_level)
  )
}

calibration_runner_args_summary <- function(args) {
  paste(sprintf("%s=%s", names(args), unlist(args, use.names = FALSE)), collapse = ", ")
}

calibration_requested_specs <- function() {
  requested <- calibration_env("CALIBRATION_SPECS")
  if (!nzchar(requested)) return(character(0))
  trimws(strsplit(requested, ",", fixed = TRUE)[[1]])
}

select_calibration_specs <- function(specs, default_spec) {
  requested <- calibration_requested_specs()
  mode <- tolower(calibration_env("CALIBRATION_SPEC_MODE"))
  if (!nzchar(mode)) mode <- "all"

  if (length(requested) > 0) {
    selected <- requested[nzchar(requested)]
  } else if (identical(mode, "default")) {
    selected <- default_spec
  } else if (identical(mode, "all")) {
    selected <- names(specs)
  } else {
    stop("CALIBRATION_SPEC_MODE must be `default` or `all`; got `", mode, "`.")
  }

  missing <- setdiff(selected, names(specs))
  if (length(missing) > 0) {
    stop("Unknown calibration spec(s): ", paste(missing, collapse = ", "))
  }

  specs[selected]
}

calibration_selected_names <- function(specs) {
  paste(names(specs), collapse = ", ")
}
