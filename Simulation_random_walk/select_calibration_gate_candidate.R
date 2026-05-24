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

gate_env <- function(name, default = "") {
  value <- Sys.getenv(name, unset = "")
  if (nzchar(value)) value else default
}

gate_bool_env <- function(name, default = FALSE) {
  value <- tolower(gate_env(name))
  if (!nzchar(value)) return(default)
  if (value %in% c("1", "true", "yes", "y")) return(TRUE)
  if (value %in% c("0", "false", "no", "n")) return(FALSE)
  stop(name, " must be boolean-like; got `", value, "`.")
}

split_env <- function(name) {
  value <- gate_env(name)
  if (!nzchar(value)) return(character(0))
  trimws(strsplit(value, ",", fixed = TRUE)[[1]])
}

rel_path <- function(path) {
  sub(paste0("^", normalizePath(root_dir, winslash = "/", mustWork = TRUE), "/?"),
      "",
      normalizePath(path, winslash = "/", mustWork = FALSE))
}

selected_gate_configs <- function() {
  requested <- split_env("CALIBRATION_GATE_SETTINGS")
  if (length(requested) == 0) return(configs)

  keep <- vapply(configs, function(config) {
    config$dir %in% requested || config$setting %in% requested
  }, logical(1))
  if (!any(keep)) {
    stop("No calibration settings matched CALIBRATION_GATE_SETTINGS.")
  }
  configs[keep]
}

selected_gate_specs <- function(config) {
  requested <- split_env("CALIBRATION_GATE_SPECS")
  if (length(requested) == 0) return(config$default_spec)

  selected <- requested[nzchar(requested)]
  missing <- setdiff(selected, names(config$artifacts))
  if (length(missing) > 0) {
    stop(
      config$setting,
      " has no artifact for spec(s): ",
      paste(missing, collapse = ", ")
    )
  }
  selected
}

candidate_metrics <- function(config, spec, artifact_path, source, run_id) {
  if (!file.exists(artifact_path)) {
    return(data.frame(
      setting = config$setting,
      spec = spec,
      source = source,
      run_id = run_id,
      artifact_path = rel_path(artifact_path),
      mc_n = NA_integer_,
      target_tolerance = NA_real_,
      constraint_tolerance = NA_real_,
      best_value = NA_real_,
      max_abs_error = Inf,
      mean_abs_error = Inf,
      failed_checks = NA_integer_,
      pass = FALSE,
      stringsAsFactors = FALSE
    ))
  }

  rows <- candidate_rows(
    config$setting,
    spec,
    artifact_path,
    config$groups,
    config$candidate_tolerance
  )
  artifact <- readRDS(artifact_path)
  best_index <- which.min(artifact$values)
  errors <- abs(rows$error)
  data.frame(
    setting = config$setting,
    spec = spec,
    source = source,
    run_id = run_id,
    artifact_path = rel_path(artifact_path),
    mc_n = artifact$mc_n,
    target_tolerance = if (!is.null(artifact$target_tolerance)) artifact$target_tolerance else NA_real_,
    constraint_tolerance = if (!is.null(artifact$constraint_tolerance)) artifact$constraint_tolerance else NA_real_,
    best_value = artifact$values[best_index],
    max_abs_error = max(errors, na.rm = TRUE),
    mean_abs_error = mean(errors, na.rm = TRUE),
    failed_checks = sum(!rows$pass),
    pass = all(rows$pass),
    stringsAsFactors = FALSE
  )
}

gate_artifacts_for <- function(config, spec, artifact_file) {
  gate_root <- file.path(root_dir, config$dir, "calibration", "gate_candidates")
  if (!dir.exists(gate_root)) {
    return(data.frame(path = character(0), run_id = character(0), stringsAsFactors = FALSE))
  }

  paths <- list.files(
    gate_root,
    pattern = paste0("^", artifact_file, "$"),
    recursive = TRUE,
    full.names = TRUE
  )
  if (length(paths) == 0) {
    return(data.frame(path = character(0), run_id = character(0), stringsAsFactors = FALSE))
  }

  data.frame(
    path = paths,
    run_id = basename(dirname(paths)),
    stringsAsFactors = FALSE
  )
}

rank_candidates <- function(rows) {
  rows[order(!rows$pass, rows$max_abs_error, rows$mean_abs_error, rows$best_value), , drop = FALSE]
}

write_selection_report <- function(config, rows, selected, promoted) {
  summarize_dir <- file.path(root_dir, config$dir, "Summarize")
  dir.create(summarize_dir, recursive = TRUE, showWarnings = FALSE)

  stem <- "calibration_gate_candidate_selection"
  csv_path <- file.path(summarize_dir, paste0(stem, ".csv"))
  md_path <- file.path(summarize_dir, paste0(stem, ".md"))
  write.csv(rows, csv_path, row.names = FALSE)

  status <- if (nrow(selected) > 0) "PASS" else "FAIL"
  lines <- c(
    paste0("# ", config$setting, " Calibration Gate Candidate Selection"),
    "",
    paste0("- Validation tolerance: `", config$candidate_tolerance, "`"),
    paste0("- Overall status: `", status, "`"),
    paste0("- Promoted: `", if (isTRUE(promoted)) "yes" else "no", "`"),
    "",
    "| Source | Run | Spec | mc_n | Target Tol | Best Value | Max Abs Error | Failed Checks | Pass | Artifact |",
    "| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | --- | --- |"
  )

  fmt_num <- function(x) {
    if (is.na(x) || is.infinite(x)) return("")
    formatC(as.numeric(x), digits = 6, format = "fg")
  }

  for (i in seq_len(nrow(rows))) {
    lines <- c(lines, paste0("| ", paste(
      rows$source[i],
      rows$run_id[i],
      rows$spec[i],
      if (is.na(rows$mc_n[i])) "" else rows$mc_n[i],
      fmt_num(rows$target_tolerance[i]),
      fmt_num(rows$best_value[i]),
      fmt_num(rows$max_abs_error[i]),
      if (is.na(rows$failed_checks[i])) "" else rows$failed_checks[i],
      if (isTRUE(rows$pass[i])) "PASS" else "FAIL",
      rows$artifact_path[i],
      sep = " | "
    ), " |"))
  }

  if (nrow(selected) > 0) {
    lines <- c(
      lines,
      "",
      paste0("- Selected artifact: `", selected$artifact_path[[1]], "`")
    )
  }

  writeLines(lines, md_path)
  message(config$setting, ": ", status, " (", md_path, ")")
  invisible(status)
}

select_for_config <- function(config, promote = FALSE) {
  rows <- list()
  row_i <- 1

  for (spec in selected_gate_specs(config)) {
    production_rel <- config$artifacts[[spec]]
    production_path <- file.path(root_dir, config$dir, production_rel)
    artifact_file <- basename(production_rel)

    if (gate_bool_env("CALIBRATION_GATE_INCLUDE_PRODUCTION", TRUE)) {
      rows[[row_i]] <- candidate_metrics(config, spec, production_path, "production", "current")
      row_i <- row_i + 1
    }

    gate_paths <- gate_artifacts_for(config, spec, artifact_file)
    if (nrow(gate_paths) > 0) {
      for (i in seq_len(nrow(gate_paths))) {
        rows[[row_i]] <- candidate_metrics(
          config,
          spec,
          gate_paths$path[i],
          "gate_candidate",
          gate_paths$run_id[i]
        )
        row_i <- row_i + 1
      }
    }
  }

  if (length(rows) == 0) {
    rows <- data.frame()
  } else {
    rows <- do.call(rbind, rows)
    rows <- rank_candidates(rows)
  }

  selected <- rows[rows$pass, , drop = FALSE]
  if (nrow(selected) > 0) {
    selected <- selected[1, , drop = FALSE]
  }

  promoted <- FALSE
  if (isTRUE(promote) && nrow(selected) > 0 && !identical(selected$source[[1]], "production")) {
    destination <- file.path(root_dir, config$dir, config$artifacts[[selected$spec[[1]]]])
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    file.copy(file.path(root_dir, selected$artifact_path[[1]]), destination, overwrite = TRUE)
    promoted <- TRUE
  }

  status <- write_selection_report(config, rows, selected, promoted)
  list(status = status, rows = rows, selected = selected, promoted = promoted)
}

promote <- gate_bool_env("CALIBRATION_GATE_PROMOTE", FALSE)
results <- lapply(selected_gate_configs(), select_for_config, promote = promote)
statuses <- vapply(results, `[[`, character(1), "status")
if (!all(statuses == "PASS")) {
  quit(status = 1)
}
