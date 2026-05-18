script_args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", script_args, value = TRUE)
if (length(file_arg) > 0) {
  root_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[[1]])))
} else if (dir.exists(file.path(getwd(), "Simulation_random_walk"))) {
  root_dir <- file.path(getwd(), "Simulation_random_walk")
} else {
  root_dir <- getwd()
}

candidate_tolerance <- as.numeric(
  Sys.getenv("CANDIDATE_TARGET_TOLERANCE", unset = "0.03")
)

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

candidate_rows <- function(setting, spec, path, groups) {
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
        pass = abs(error) <= candidate_tolerance,
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
          pass = abs(error) <= candidate_tolerance,
          stringsAsFactors = FALSE
        )
        row_i <- row_i + 1
      }
    }
  }

  do.call(rbind, rows)
}

write_report <- function(setting_dir, setting_name, rows) {
  summarize_dir <- file.path(root_dir, setting_dir, "Summarize")
  dir.create(summarize_dir, recursive = TRUE, showWarnings = FALSE)

  csv_path <- file.path(summarize_dir, "candidate_calibration_report.csv")
  md_path <- file.path(summarize_dir, "candidate_calibration_report.md")
  write.csv(rows, csv_path, row.names = FALSE)

  status <- if (all(rows$pass)) "PASS" else "FAIL"
  lines <- c(
    paste0("# ", setting_name, " Candidate Calibration Report"),
    "",
    paste0("- Tolerance: `", candidate_tolerance, "`"),
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
    groups = continuous_groups,
    artifacts = c(
      separated_moderate = "calibration/calibration_separated_moderate.rds",
      separated_reversed = "calibration/calibration_separated_reversed.rds",
      separated_large = "calibration/calibration_separated_large.rds",
      smoke_default = "calibration/test_alternative_pars.rds"
    )
  )
)

statuses <- character(0)
for (config in configs) {
  rows <- do.call(rbind, lapply(names(config$artifacts), function(spec) {
    artifact_path <- file.path(root_dir, config$dir, config$artifacts[[spec]])
    candidate_rows(config$setting, spec, artifact_path, config$groups)
  }))
  statuses <- c(statuses, write_report(config$dir, config$setting, rows))
}

if (!all(statuses == "PASS")) {
  quit(status = 1)
}
