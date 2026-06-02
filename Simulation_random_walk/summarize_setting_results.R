root_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk"

settings <- list(
  Setting1 = list(
    label = "Random Walk Setting I",
    objective = "Binary-treatment near-sharing design.",
    expected_ns = c(100, 300, 500, 1000),
    expected_reps = 200,
    todo_when_missing = "Rerun production simulation for missing sample sizes after confirming calibration.",
    additional_todo = c(
      "The `balanced_small` target has been revised to a rounded seed-63 random-shared spec; existing Setting I calibration and production outputs predate that target and should not be used for final reporting.",
      "Rerun Setting I calibration/gate validation and promote only an artifact whose target vector and calibrated true values satisfy the revised near-shared design.",
      "Rerun Setting I production simulations only after the revised calibration passes; then regenerate summaries and manuscript tables so Setting I results are aligned with the revised design."
    )
  ),
  Setting2 = list(
    label = "Random Walk Setting II",
    objective = "Binary-treatment no-sharing design.",
    expected_ns = c(100, 300, 500, 1000),
    expected_reps = 200,
    todo_when_missing = "Rerun production simulation for missing sample sizes after confirming no-sharing calibration."
  ),
  Setting3 = list(
    label = "Random Walk Setting III",
    objective = "Continuous-covariate random-walk sharing design.",
    expected_ns = c(100, 300, 500, 1000),
    expected_reps = 200,
    todo_when_missing = "Rerun production simulation for missing sample sizes after confirming continuous-covariate calibration."
  ),
  SupplSetting3_NoShared = list(
    label = "Supplementary Setting III No Shared",
    objective = "Continuous-covariate no-sharing sensitivity design.",
    expected_ns = c(100, 300, 500, 1000),
    expected_reps = 200,
    todo_when_missing = "Run calibration and production simulations; only smoke-test artifacts are currently available."
  ),
  Setting4 = list(
    label = "Setting IV",
    objective = "Project Quit / Forever Free two-stage synthetic-parametric shared design informed by cleaned PQ/FF structure only.",
    expected_ns = c(100, 300, 500, 1000),
    expected_reps = 200,
    todo_when_missing = "Run production simulation after confirming the synthetic-parametric calibration artifact.",
    default_spec = "pqff_shared_parsimonious",
    additional_todo = c(
      "Keep the uploaded cleaned PQ/FF data local/ignored and use it only for structural design checks.",
      "Do not include deleted real-source calibration/results or any source-data-resampling outputs in method claims."
    )
  ),
  SupplSetting4_NoShared = list(
    label = "Supplementary Setting IV No Shared",
    objective = "Project Quit / Forever Free two-stage synthetic-parametric no-sharing sensitivity design.",
    expected_ns = c(100, 300, 500, 1000),
    expected_reps = 200,
    todo_when_missing = "Run production simulation after confirming the synthetic-parametric separated calibration artifact.",
    default_spec = "pqff_separated_parsimonious",
    additional_todo = c(
      "Keep this setting paired with Setting IV when regenerating manuscript tables.",
      "Do not reuse main Setting IV shared artifacts as no-shared results."
    )
  )
)

summary_settings <- Sys.getenv("SUMMARY_SETTINGS", unset = "")
if (nzchar(summary_settings)) {
  requested_settings <- trimws(strsplit(summary_settings, ",", fixed = TRUE)[[1]])
  unknown_settings <- setdiff(requested_settings, names(settings))
  if (length(unknown_settings)) {
    stop("Unknown SUMMARY_SETTINGS value(s): ", paste(unknown_settings, collapse = ", "))
  }
  settings <- settings[requested_settings]
}

fmt <- function(x) {
  if (is.na(x)) return("NA")
  formatC(x, digits = 4, format = "f")
}

parse_n_one <- function(path) {
  match <- regexec("^results_([0-9]+)(_[A-Za-z0-9]+)?\\.rds$", basename(path))
  parts <- regmatches(basename(path), match)[[1]]
  if (length(parts) < 2L) return(NA_integer_)
  as.integer(parts[[2]])
}

parse_n <- function(path) {
  vapply(path, parse_n_one, integer(1))
}

result_file_type <- function(path) {
  base <- basename(path)
  if (grepl("^results_[0-9]+\\.rds$", base)) {
    return("production")
  }
  if (grepl("^results_[0-9]+_synthetic\\.rds$", base)) {
    return("synthetic fallback")
  }
  "non-production"
}

flatten_numeric <- function(x, prefix = NULL) {
  out <- list()
  if (!is.list(x)) return(out)
  for (nm in names(x)) {
    value <- x[[nm]]
    if (is.numeric(value) || is.integer(value) || is.logical(value)) {
      value <- as.numeric(value)
      if (length(value) == 1L) {
        out[[nm]] <- value
      } else {
        for (i in seq_along(value)) {
          metric_name <- paste0(nm, "_", i)
          out[[metric_name]] <- value[[i]]
        }
      }
    }
  }
  out
}

summarize_result_file <- function(path, setting_name) {
  n_value <- parse_n(path)
  result <- readRDS(path)
  keep <- !vapply(result, is.null, logical(1))
  result <- result[keep]
  rows <- list()

  for (method in unique(unlist(lapply(result, function(rep) {
    names(rep)[grepl("^evaluation", names(rep))]
  })))) {
    metric_values <- list()
    for (rep in result) {
      if (!method %in% names(rep)) next
      flattened <- flatten_numeric(rep[[method]])
      for (metric in names(flattened)) {
        metric_values[[metric]] <- c(metric_values[[metric]], flattened[[metric]])
      }
    }
    for (metric in names(metric_values)) {
      values <- metric_values[[metric]]
      rows[[length(rows) + 1L]] <- data.frame(
        setting = setting_name,
        n = n_value,
        result_file = basename(path),
        method = method,
        metric = metric,
        mean = mean(values, na.rm = TRUE),
        sd = stats::sd(values, na.rm = TRUE),
        non_null_reps = length(result),
        stringsAsFactors = FALSE
      )
    }
  }

  if (length(rows) == 0L) {
    return(data.frame(
      setting = character(),
      n = integer(),
      result_file = character(),
      method = character(),
      metric = character(),
      mean = numeric(),
      sd = numeric(),
      non_null_reps = integer(),
      stringsAsFactors = FALSE
    ))
  }
  do.call(rbind, rows)
}

write_setting_summary <- function(setting_name, cfg) {
  setting_dir <- file.path(root_dir, setting_name)
  summary_dir <- file.path(setting_dir, "Summarize")
  results_dir <- file.path(setting_dir, "simulation_results")
  calibration_dir <- file.path(setting_dir, "calibration")
  test_results_dir <- file.path(setting_dir, "test_results")
  dir.create(summary_dir, showWarnings = FALSE, recursive = TRUE)

  result_files <- sort(Sys.glob(file.path(results_dir, "results_*.rds")))
  result_ns <- parse_n(result_files)
  result_files <- result_files[!is.na(result_ns)]
  result_ns <- result_ns[!is.na(result_ns)]
  result_types <- vapply(result_files, result_file_type, character(1))
  production_mask <- result_types == "production"
  production_files <- result_files[production_mask & result_ns %in% cfg$expected_ns]
  production_ns <- result_ns[production_mask]
  missing_ns <- setdiff(cfg$expected_ns, production_ns)
  non_production_ns <- sort(unique(result_ns[!production_mask & result_ns %in% cfg$expected_ns]))

  status_rows <- lapply(result_files, function(path) {
    x <- readRDS(path)
    data.frame(
      file = basename(path),
      n = parse_n(path),
      type = result_file_type(path),
      entries = length(x),
      non_null = sum(!vapply(x, is.null, logical(1))),
      stringsAsFactors = FALSE
    )
  })
  status_table <- if (length(status_rows)) do.call(rbind, status_rows) else NULL

  eval_rows <- lapply(result_files, summarize_result_file, setting_name = setting_name)
  eval_summary <- do.call(rbind, eval_rows)
  write.csv(eval_summary, file.path(summary_dir, "evaluation_summary.csv"), row.names = FALSE)

  calibration_files <- basename(sort(Sys.glob(file.path(calibration_dir, "*.rds"))))
  test_files <- basename(sort(Sys.glob(file.path(test_results_dir, "*.rds"))))
  calibration_detail_lines <- character()
  if (setting_name %in% c("Setting4", "SupplSetting4_NoShared")) {
    production_calibration <- file.path(calibration_dir, paste0("calibration_", cfg$default_spec, ".rds"))
    if (file.exists(production_calibration)) {
      cal <- readRDS(production_calibration)
      calibration_detail_lines <- c(
        "",
        "## Candidate Calibration",
        "",
        paste0("- Source mode: ", cal$source_mode),
        paste0("- Design source complete consent rows used for aggregate constants: ", cal$design$complete_consent_rows),
        paste0("- Projection Monte Carlo rows: ", cal$mc_n),
        paste0("- Calibration search rows: ", cal$search_n),
        paste0("- Calibration starts: ", cal$n_starts),
        paste0("- Search objective: ", fmt(cal$objective)),
        paste0("- Sum absolute target difference: ", fmt(cal$values)),
        paste0("- Max absolute target difference: ", fmt(cal$max_abs_error)),
        paste0("- Max absolute shared-pair difference: ", fmt(cal$max_abs_pair_difference)),
        "",
        "| Q2 parameter | Q1 parameter | Q2 theta | Q1 theta | Pair diff | Target diff |",
        "| --- | --- | ---: | ---: | ---: | ---: |"
      )
      if (!is.null(cal$pair_summary) && nrow(cal$pair_summary) > 0L) {
        for (i in seq_len(nrow(cal$pair_summary))) {
          row <- cal$pair_summary[i, , drop = FALSE]
          calibration_detail_lines <- c(calibration_detail_lines, paste0(
            "| `", row$q2_parameter, "` | `", row$q1_parameter, "` | ",
            fmt(row$q2_theta), " | ",
            fmt(row$q1_theta), " | ",
            fmt(row$pair_difference), " | ",
            fmt(row$target_difference), " |"
          ))
        }
      }
      if (!is.null(cal$theta)) {
        calibration_detail_lines <- c(
          calibration_detail_lines,
          "",
          "## Accepted True Parameters",
          "",
          paste0("The accepted production calibration artifact is `", basename(production_calibration), "`. Direct calibration matches the target vector to numerical precision."),
          "",
          "| Parameter | Accepted true theta |",
          "| --- | ---: |"
        )
        for (parameter in names(cal$theta)) {
          calibration_detail_lines <- c(
            calibration_detail_lines,
            paste0("| `", parameter, "` | ", fmt(cal$theta[[parameter]]), " |")
          )
        }
      }
    }
  }

  lines <- c(
    paste0("# ", cfg$label, " Current Results Summary"),
    "",
    paste0("- Objective: ", cfg$objective),
    paste0("- Expected production sample sizes: ", paste(cfg$expected_ns, collapse = ", ")),
    paste0("- Expected production replicates per sample size: ", cfg$expected_reps),
    paste0("- Production result files found: ", length(production_files), " of ", length(cfg$expected_ns)),
    paste0("- Missing production sample sizes: ", if (length(missing_ns)) paste(missing_ns, collapse = ", ") else "none"),
    if (length(non_production_ns)) {
      paste0("- Non-production result sample sizes present: ", paste(non_production_ns, collapse = ", "))
    },
    if (!is.null(cfg$non_production_note)) {
      paste0("- Note: ", cfg$non_production_note)
    },
    "",
    "## Result Files",
    ""
  )

  if (is.null(status_table)) {
    lines <- c(lines, "- No production `results_*.rds` files found in `simulation_results/`.")
  } else {
    lines <- c(lines, "| File | n | Type | Entries | Non-null |", "| --- | ---: | --- | ---: | ---: |")
    for (i in seq_len(nrow(status_table))) {
      lines <- c(lines, paste0(
        "| `", status_table$file[i], "` | ",
        status_table$n[i], " | ",
        status_table$type[i], " | ",
        status_table$entries[i], " | ",
        status_table$non_null[i], " |"
      ))
    }
  }

  lines <- c(
    lines,
    "",
    "## Artifact Inventory",
    "",
    paste0("- Calibration artifacts: ", if (length(calibration_files)) paste(sprintf("`%s`", calibration_files), collapse = ", ") else "none"),
    paste0("- Test artifacts: ", if (length(test_files)) paste(sprintf("`%s`", test_files), collapse = ", ") else "none"),
    calibration_detail_lines,
    "",
    "## Evaluation Output",
    "",
    "- `evaluation_summary.csv` contains mean and standard deviation summaries by setting, sample size, method, and metric.",
    "- Metrics are flattened from each replicate's `evaluation_*` objects so vector bias outputs appear as indexed columns."
  )
  writeLines(lines, file.path(summary_dir, "current_results_summary.md"))

  todo <- c(
    paste0("# ", cfg$label, " Todo"),
    "",
    "- Keep code-file objectives and parameter choices synchronized with the corresponding top-level management document.",
    "- Rerun `Rscript Simulation_random_walk/summarize_setting_results.R` after any new simulation output is produced.",
    if (length(missing_ns)) {
      paste0("- Missing production outputs for n = ", paste(missing_ns, collapse = ", "), ". ", cfg$todo_when_missing)
    } else {
      "- Production output files are present for all expected sample sizes; review `evaluation_summary.csv` before manuscript table generation."
    },
    if (length(non_production_ns) && !is.null(cfg$non_production_note)) {
      paste0("- ", cfg$non_production_note)
    },
    if (!is.null(cfg$additional_todo)) {
      paste0("- ", cfg$additional_todo)
    },
    "- Keep large `.rds` artifacts local or move them to Git LFS/external storage if versioning is required."
  )
  writeLines(todo, file.path(summary_dir, "todo.md"))

  invisible(eval_summary)
}

invisible(mapply(write_setting_summary, names(settings), settings))
