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
  best_index <- which.min(artifact$values)
  theta <- artifact$all_theta[, best_index]
  target <- artifact$theta_target
  names(theta) <- clean_names(names(theta))
  names(target) <- clean_names(names(target))
  list(
    theta = theta,
    target = target,
    best_index = best_index,
    best_value = artifact$values[best_index],
    mc_n = artifact$mc_n
  )
}

candidate_rows <- function(setting, spec, path, groups, tolerance) {
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
  rows <- list()
  row_i <- 1

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

  do.call(rbind, rows)
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
      candidate_rows(
        config$setting,
        spec,
        artifact_path,
        config$groups,
        config$candidate_tolerance
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
