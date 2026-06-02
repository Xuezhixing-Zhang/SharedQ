script_args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", script_args, value = TRUE)
if (length(file_arg) > 0) {
  root_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[[1]])))
} else if (dir.exists(file.path(getwd(), "Simulation_random_walk"))) {
  root_dir <- file.path(getwd(), "Simulation_random_walk")
} else {
  root_dir <- getwd()
}

numeric_env <- function(name, default) {
  value <- Sys.getenv(name, unset = "")
  if (!nzchar(value)) return(default)
  numeric_value <- suppressWarnings(as.numeric(value))
  if (is.na(numeric_value)) {
    stop(name, " must be numeric; got `", value, "`.")
  }
  numeric_value
}

character_env <- function(name, default) {
  value <- Sys.getenv(name, unset = "")
  if (!nzchar(value)) default else value
}

candidate_tolerance <- numeric_env("CANDIDATE_TARGET_TOLERANCE", NA_real_)
shared_candidate_tolerance <- numeric_env("SHARED_CANDIDATE_TARGET_TOLERANCE", 0.01)
no_shared_candidate_tolerance <- numeric_env("NO_SHARED_CANDIDATE_TARGET_TOLERANCE", 0.03)
candidate_tolerance_slack <- numeric_env(
  "CANDIDATE_TARGET_TOLERANCE_SLACK",
  sqrt(.Machine$double.eps)
)

setting_candidate_tolerance <- function(default_tolerance) {
  if (!is.na(candidate_tolerance)) candidate_tolerance else default_tolerance
}

validation_requested_specs <- function() {
  requested <- character_env("VALIDATION_SPECS", "")
  if (!nzchar(requested)) return(character(0))
  trimws(strsplit(requested, ",", fixed = TRUE)[[1]])
}

validation_spec_mode <- function() {
  mode <- tolower(character_env("VALIDATION_SPEC_MODE", "all"))
  if (!mode %in% c("default", "all")) {
    stop("VALIDATION_SPEC_MODE must be `default` or `all`; got `", mode, "`.")
  }
  mode
}

select_validation_artifacts <- function(config) {
  requested <- validation_requested_specs()
  if (length(requested) > 0) {
    selected <- requested[nzchar(requested)]
  } else if (identical(validation_spec_mode(), "default")) {
    selected <- config$default_spec
  } else {
    selected <- names(config$artifacts)
  }

  missing <- setdiff(selected, names(config$artifacts))
  if (length(missing) > 0) {
    stop(
      config$setting,
      " has no validation artifact for spec(s): ",
      paste(missing, collapse = ", ")
    )
  }

  config$artifacts[selected]
}

validation_report_stem <- function() {
  explicit <- character_env("VALIDATION_REPORT_STEM", "")
  if (nzchar(explicit)) return(explicit)
  if (length(validation_requested_specs()) > 0) return("candidate_calibration_selected_report")
  if (identical(validation_spec_mode(), "default")) return("candidate_calibration_default_report")
  "candidate_calibration_report"
}

validation_report_title_suffix <- function() {
  explicit <- character_env("VALIDATION_REPORT_TITLE_SUFFIX", "")
  if (nzchar(explicit)) return(explicit)
  if (length(validation_requested_specs()) > 0) return("Candidate Calibration Selected Report")
  if (identical(validation_spec_mode(), "default")) return("Candidate Calibration Default Report")
  "Candidate Calibration Report"
}

within_candidate_tolerance <- function(error, tolerance) {
  abs(error) <= tolerance + candidate_tolerance_slack
}

fmt <- function(x) {
  if (is.na(x)) return("")
  formatC(as.numeric(x), digits = 4, format = "f")
}

clean_names <- function(x) {
  sub(".*\\.", "", x)
}

best_theta <- function(path) {
  artifact <- readRDS(path)
  if (!is.null(artifact$all_theta)) {
    best_index <- which.min(artifact$values)
    theta <- artifact$all_theta[, best_index]
    best_value <- artifact$values[best_index]
  } else if (!is.null(artifact$theta)) {
    best_index <- 1L
    theta <- artifact$theta
    best_value <- artifact$values
  } else {
    stop("Calibration artifact lacks both `all_theta` and `theta`: ", path)
  }
  target <- artifact$theta_target
  names(theta) <- clean_names(names(theta))
  names(target) <- clean_names(names(target))
  list(
    theta = theta,
    target = target,
    artifact = artifact,
    best_index = best_index,
    best_value = best_value,
    mc_n = artifact$mc_n
  )
}

expected_theta_for_spec <- function(config, spec) {
  env <- new.env(parent = globalenv())

  if (identical(config$dir, "Setting1")) {
    source(file.path(root_dir, config$dir, "nloptr_Setting1.R"), local = env)
    spec_def <- env$setting1_shared_parameter_specs[[spec]]
    target <- env$build_theta_target(
      shared_mu = spec_def$shared_mu,
      shared_sigma = spec_def$shared_sigma,
      shared_seed = spec_def$seed
    )
  } else if (identical(config$dir, "Setting2")) {
    source(file.path(root_dir, config$dir, "nloptr_Setting2.R"), local = env)
    spec_def <- env$setting2_parameter_specs[[spec]]
    target <- env$build_theta_target(spec_def$values)
  } else if (identical(config$dir, "Setting3")) {
    source(file.path(root_dir, config$dir, "nloptr_Setting3.R"), local = env)
    spec_def <- env$setting3_parameter_specs[[spec]]
    target <- env$build_setting3_theta_target(
      psi0_mu = spec_def$psi0_mu,
      psi1_mu = spec_def$psi1_mu,
      psi2_mu = spec_def$psi2_mu,
      psi0_sigma = spec_def$psi0_sigma,
      psi1_sigma = spec_def$psi1_sigma,
      psi2_sigma = spec_def$psi2_sigma,
      shared_seed = spec_def$seed
    )
    names(target) <- names(env$theta_target)
  } else if (identical(config$dir, "SupplSetting3_NoShared")) {
    source(file.path(root_dir, config$dir, "nloptr_Setting3.R"), local = env)
    spec_def <- env$setting3_parameter_specs[[spec]]
    target <- env$build_setting3_theta_target(
      q3_a3 = spec_def$q3_a3,
      q2_a2 = spec_def$q2_a2,
      q1_a1 = spec_def$q1_a1,
      q3_o3a3 = spec_def$q3_o3a3,
      q2_o2a2 = spec_def$q2_o2a2,
      q1_o1a1 = spec_def$q1_o1a1,
      q3_a2a3 = spec_def$q3_a2a3,
      q2_a1a2 = spec_def$q2_a1a2,
      q3_a1a2a3 = spec_def$q3_a1a2a3
    )
    names(target) <- names(env$theta_target)
  } else if (identical(config$dir, "Setting4") || identical(config$dir, "SupplSetting4_NoShared")) {
    source(file.path(root_dir, "Setting4", "Q_datagenerating.R"), local = env)
    target <- env$setting4_target_theta(spec)
  } else {
    stop("No expected-target builder configured for ", config$setting, ".")
  }

  names(target) <- clean_names(names(target))
  target
}

target_definition_rows <- function(setting, spec, calibration, expected_target) {
  if (is.null(expected_target)) return(NULL)
  if (length(calibration$target) != length(expected_target)) {
    stop(
      setting,
      " ",
      spec,
      " target length mismatch: artifact has ",
      length(calibration$target),
      ", current script has ",
      length(expected_target),
      "."
    )
  }

  target_error <- calibration$target - expected_target
  data.frame(
    setting = setting,
    spec = spec,
    check_type = "target_definition",
    group = "theta_target",
    item = if (is.null(names(expected_target))) seq_along(expected_target) else names(expected_target),
    target = expected_target,
    calibrated = calibration$target,
    error = target_error,
    pass = abs(target_error) <= candidate_tolerance_slack,
    stringsAsFactors = FALSE
  )
}

candidate_rows <- function(setting, spec, path, groups, tolerance, expected_target = NULL) {
  if (!file.exists(path)) {
    return(data.frame(
      setting = setting,
      spec = spec,
      check_type = "artifact",
      group = "",
      item = basename(path),
      target = NA_real_,
      calibrated = NA_real_,
      error = NA_real_,
      pass = FALSE,
      stringsAsFactors = FALSE
    ))
  }

  calibration <- best_theta(path)
  rows <- list(target_definition_rows(setting, spec, calibration, expected_target))
  row_i <- length(rows) + 1

  if (!is.null(calibration$artifact$source_mode)) {
    rows[[row_i]] <- data.frame(
      setting = setting,
      spec = spec,
      check_type = "artifact",
      group = "source_mode",
      item = basename(path),
      target = NA_real_,
      calibrated = NA_real_,
      error = NA_real_,
      pass = !identical(calibration$artifact$source_mode, "real"),
      stringsAsFactors = FALSE
    )
    row_i <- row_i + 1
  }

  for (group_name in names(groups)) {
    group <- groups[[group_name]]
    for (term_name in names(group)) {
      idx <- group[[term_name]]
      target <- calibration$target[idx]
      calibrated <- calibration$theta[idx]
      error <- calibrated - target
      rows[[row_i]] <- data.frame(
        setting = setting,
        spec = spec,
        check_type = "coefficient",
        group = group_name,
        item = term_name,
        target = target,
        calibrated = calibrated,
        error = error,
        pass = within_candidate_tolerance(error, tolerance),
        stringsAsFactors = FALSE
      )
      row_i <- row_i + 1
    }

    if (length(group) >= 2) {
      pairs <- utils::combn(seq_along(group), 2)
      for (j in seq_len(ncol(pairs))) {
        pair <- pairs[, j]
        left <- group[[pair[1]]]
        right <- group[[pair[2]]]
        target_diff <- calibration$target[left] - calibration$target[right]
        calibrated_diff <- calibration$theta[left] - calibration$theta[right]
        error <- calibrated_diff - target_diff
        rows[[row_i]] <- data.frame(
          setting = setting,
          spec = spec,
          check_type = "difference",
          group = group_name,
          item = paste(names(group)[pair], collapse = " - "),
          target = target_diff,
          calibrated = calibrated_diff,
          error = error,
          pass = within_candidate_tolerance(error, tolerance),
          stringsAsFactors = FALSE
        )
        row_i <- row_i + 1
      }
    }
  }

  do.call(rbind, rows[!vapply(rows, is.null, logical(1))])
}

write_report <- function(
  setting_dir,
  setting_name,
  rows,
  tolerance,
  report_stem = "candidate_calibration_report",
  report_title_suffix = "Candidate Calibration Report"
) {
  summarize_dir <- file.path(root_dir, setting_dir, "Summarize")
  dir.create(summarize_dir, recursive = TRUE, showWarnings = FALSE)

  csv_path <- file.path(summarize_dir, paste0(report_stem, ".csv"))
  md_path <- file.path(summarize_dir, paste0(report_stem, ".md"))
  write.csv(rows, csv_path, row.names = FALSE)

  status <- if (all(rows$pass)) "PASS" else "FAIL"
  lines <- c(
    paste0("# ", setting_name, " ", report_title_suffix),
    "",
    paste0("- Tolerance: `", tolerance, "`"),
    paste0("- Numerical slack: `", candidate_tolerance_slack, "`"),
    paste0("- Overall status: `", status, "`"),
    "",
    "| Spec | Check | Group | Item | Target | Calibrated | Error | Pass |",
    "| --- | --- | --- | --- | ---: | ---: | ---: | --- |"
  )

  for (i in seq_len(nrow(rows))) {
    lines <- c(lines, paste0("| ", paste(
        rows$spec[i],
        rows$check_type[i],
        rows$group[i],
        rows$item[i],
        fmt(rows$target[i]),
        fmt(rows$calibrated[i]),
        fmt(rows$error[i]),
        if (isTRUE(rows$pass[i])) "PASS" else "FAIL",
        sep = " | "
      ), " |"
    ))
  }

  writeLines(lines, md_path)
  message(setting_name, ": ", status, " (", md_path, ")")
  invisible(status)
}

binary_groups <- list(
  psi1 = c(Q3_A1 = 2, Q2_A1 = 10),
  psi2 = c(Q3_A3 = 6, Q2_A2 = 11),
  psi3 = c(Q3_A1A3 = 7, Q2_A1A2 = 12)
)

continuous_groups <- list(
  psi0 = c(Q3_A3 = 10, Q2_A2 = 19, Q1_A1 = 24),
  psi1 = c(Q3_O3A3 = 11, Q2_O2A2 = 20, Q1_O1A1 = 25),
  psi2 = c(Q3_A2A3 = 12, Q2_A1A2 = 21),
  psi3 = c(Q3_A1A2A3 = 13)
)

setting4_groups <- list(
  SE_main = c(Q2_PQSE = 3, Q1_QuitSE = 12),
  Motiv_main = c(Q2_PQMotiv = 4, Q1_QuitMotiv = 13),
  LowEducation_main = c(Q2_LowEducation = 5, Q1_LowEducation = 14),
  SE_treatment = c(Q2_PQSE_A_FF = 8, Q1_QuitSE_A_efficacy = 20),
  Motiv_treatment = c(Q2_PQMotiv_A_FF = 9, Q1_QuitMotiv_A_outcome = 21),
  LowEducation_treatment = c(Q2_LowEducation_A_FF = 10, Q1_LowEducation_A_story = 22)
)

configs <- list(
  list(
    setting = "Setting I",
    dir = "Setting1",
    candidate_tolerance = setting_candidate_tolerance(shared_candidate_tolerance),
    default_spec = "balanced_small",
    groups = binary_groups,
    artifacts = c(
      balanced_small = "calibration/calibration_balanced_small.rds",
      tighter_small = "calibration/calibration_tighter_small.rds",
      wider_small = "calibration/calibration_wider_small.rds"
    )
  ),
  list(
    setting = "Setting II",
    dir = "Setting2",
    candidate_tolerance = setting_candidate_tolerance(no_shared_candidate_tolerance),
    default_spec = "separated_moderate",
    groups = binary_groups,
    artifacts = c(
      separated_moderate = "calibration/calibration_separated_moderate.rds",
      separated_reversed = "calibration/calibration_separated_reversed.rds",
      separated_large = "calibration/calibration_separated_large.rds"
    )
  ),
  list(
    setting = "Setting III",
    dir = "Setting3",
    candidate_tolerance = setting_candidate_tolerance(shared_candidate_tolerance),
    default_spec = "rw_sigma_moderate",
    groups = continuous_groups,
    artifacts = c(
      rw_sigma_moderate = "calibration/calibration_rw_sigma_moderate.rds",
      rw_sigma_tight = "calibration/calibration_rw_sigma_tight.rds",
      rw_sigma_wide = "calibration/calibration_rw_sigma_wide.rds"
    )
  ),
  list(
    setting = "Supplementary Setting III No Shared",
    dir = "SupplSetting3_NoShared",
    candidate_tolerance = setting_candidate_tolerance(no_shared_candidate_tolerance),
    default_spec = "separated_moderate",
    groups = continuous_groups,
    artifacts = c(
      separated_moderate = "calibration/calibration_separated_moderate.rds",
      separated_reversed = "calibration/calibration_separated_reversed.rds",
      separated_large = "calibration/calibration_separated_large.rds",
      smoke_default = "calibration/test_alternative_pars.rds"
    )
  ),
  list(
    setting = "Setting IV",
    dir = "Setting4",
    candidate_tolerance = setting_candidate_tolerance(shared_candidate_tolerance),
    default_spec = "pqff_shared_parsimonious",
    groups = setting4_groups,
    artifacts = c(
      pqff_shared_parsimonious = "calibration/calibration_pqff_shared_parsimonious.rds",
      pqff_shared_tight = "calibration/calibration_pqff_shared_tight.rds",
      pqff_shared_wide = "calibration/calibration_pqff_shared_wide.rds"
    )
  ),
  list(
    setting = "Supplementary Setting IV No Shared",
    dir = "SupplSetting4_NoShared",
    candidate_tolerance = setting_candidate_tolerance(no_shared_candidate_tolerance),
    default_spec = "pqff_separated_parsimonious",
    groups = setting4_groups,
    artifacts = c(
      pqff_separated_parsimonious = "calibration/calibration_pqff_separated_parsimonious.rds",
      pqff_separated_reversed = "calibration/calibration_pqff_separated_reversed.rds",
      pqff_separated_large = "calibration/calibration_pqff_separated_large.rds"
    )
  )
)

run_candidate_calibration_validation <- function(
  validation_configs = configs,
  report_stem = validation_report_stem(),
  report_title_suffix = validation_report_title_suffix()
) {
  statuses <- character(0)
  for (config in validation_configs) {
    artifacts <- select_validation_artifacts(config)
    rows <- do.call(rbind, lapply(names(artifacts), function(spec) {
      artifact_path <- file.path(root_dir, config$dir, artifacts[[spec]])
      expected_target <- expected_theta_for_spec(config, spec)
      candidate_rows(
        config$setting,
        spec,
        artifact_path,
        config$groups,
        config$candidate_tolerance,
        expected_target = expected_target
      )
    }))
    statuses <- c(statuses, write_report(
      config$dir,
      config$setting,
      rows,
      config$candidate_tolerance,
      report_stem = report_stem,
      report_title_suffix = report_title_suffix
    ))
  }
  statuses
}

if (sys.nframe() == 0) {
  statuses <- run_candidate_calibration_validation()
  if (!all(statuses == "PASS")) {
    quit(status = 1)
  }
}
