root_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk"

settings <- list(
  Setting1 = list(
    label = "Random Walk Setting I",
    objective = "Binary-treatment near-sharing design.",
    expected_ns = c(100, 300, 500, 1000),
    expected_reps = 200,
    todo_when_missing = "Rerun production simulation for missing sample sizes after confirming calibration."
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
  )
)

fmt <- function(x) {
  if (is.na(x)) return("NA")
  formatC(x, digits = 4, format = "f")
}

parse_n <- function(path) {
  as.integer(sub("^results_([0-9]+)\\.rds$", "\\1", basename(path)))
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
  production_files <- result_files[result_ns %in% cfg$expected_ns]
  missing_ns <- setdiff(cfg$expected_ns, result_ns)

  status_rows <- lapply(result_files, function(path) {
    x <- readRDS(path)
    data.frame(
      file = basename(path),
      n = parse_n(path),
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

  lines <- c(
    paste0("# ", cfg$label, " Current Results Summary"),
    "",
    paste0("- Objective: ", cfg$objective),
    paste0("- Expected production sample sizes: ", paste(cfg$expected_ns, collapse = ", ")),
    paste0("- Expected production replicates per sample size: ", cfg$expected_reps),
    paste0("- Production result files found: ", length(production_files), " of ", length(cfg$expected_ns)),
    paste0("- Missing production sample sizes: ", if (length(missing_ns)) paste(missing_ns, collapse = ", ") else "none"),
    "",
    "## Result Files",
    ""
  )

  if (is.null(status_table)) {
    lines <- c(lines, "- No production `results_*.rds` files found in `simulation_results/`.")
  } else {
    lines <- c(lines, "| File | n | Entries | Non-null |", "| --- | ---: | ---: | ---: |")
    for (i in seq_len(nrow(status_table))) {
      lines <- c(lines, paste0(
        "| `", status_table$file[i], "` | ",
        status_table$n[i], " | ",
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
    "",
    "## Evaluation Output",
    "",
    "- `evaluation_summary.csv` contains mean and standard deviation summaries by setting, sample size, method, and metric.",
    "- Metrics are flattened from each replicate's `evaluation_*` objects so vector bias outputs appear as indexed columns.",
    ""
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
    "- Keep large `.rds` artifacts local or move them to Git LFS/external storage if versioning is required."
  )
  writeLines(todo, file.path(summary_dir, "todo.md"))

  invisible(eval_summary)
}

invisible(mapply(write_setting_summary, names(settings), settings))
