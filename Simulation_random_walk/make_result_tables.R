script_args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", script_args, value = TRUE)
if (length(file_arg) > 0) {
  root_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[[1]])))
} else if (dir.exists(file.path(getwd(), "Simulation_random_walk"))) {
  root_dir <- file.path(getwd(), "Simulation_random_walk")
} else {
  root_dir <- getwd()
}

bool_env <- function(name, default = FALSE) {
  value <- tolower(Sys.getenv(name, unset = ""))
  if (!nzchar(value)) return(default)
  if (value %in% c("1", "true", "yes", "y")) return(TRUE)
  if (value %in% c("0", "false", "no", "n")) return(FALSE)
  stop(name, " must be boolean-like; got `", value, "`.")
}

expected_ns <- c(100, 300, 500, 1000)
expected_reps <- 200
out_dir <- file.path(root_dir, "Writing", "generated_tables")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

settings <- list(
  Setting1 = list(
    label = "I",
    name = "Setting I",
    result_dir = "Setting1/simulation_results",
    calibration = "Setting1/calibration/calibration_balanced_small.rds",
    kind = "binary_shared",
    table_group = "main_setting_i"
  ),
  Setting2 = list(
    label = "II",
    name = "Setting II",
    result_dir = "Setting2/simulation_results",
    calibration = "Setting2/calibration/calibration_separated_moderate.rds",
    kind = "binary_no_shared",
    table_group = "main_settings_ii_iii"
  ),
  Setting3 = list(
    label = "III",
    name = "Setting III",
    result_dir = "Setting3/simulation_results",
    calibration = "Setting3/calibration/calibration_rw_sigma_moderate.rds",
    kind = "continuous_shared",
    table_group = "main_settings_ii_iii"
  ),
  SupplSetting3_NoShared = list(
    label = "Suppl III No Shared",
    name = "Supplementary Setting III No Shared",
    result_dir = "SupplSetting3_NoShared/simulation_results",
    calibration = "SupplSetting3_NoShared/calibration/calibration_separated_moderate.rds",
    kind = "continuous_no_shared",
    table_group = "supplement"
  )
)

binary_methods <- data.frame(
  evaluation = c(
    "evaluation_1",
    "evaluation_3",
    "evaluation_3_mis",
    "evaluation_2",
    "evaluation_2_mis",
    "evaluation_4",
    "evaluation_4_mis"
  ),
  result = c(
    "results_1",
    "results_3",
    "results_3_mis",
    "results_2",
    "results_2_mis",
    "results_4",
    "results_4_mis"
  ),
  method = c(
    "Q learning",
    "Q shared",
    "Misspecified Q shared",
    "SQ learning (L1 penalty)",
    "Misspecified SQ learning (L1 penalty)",
    "SQ learning (L2 penalty)",
    "Misspecified SQ learning (L2 penalty)"
  ),
  role = c(
    "traditional",
    "old_shared",
    "old_shared_mis",
    "proposed_l1",
    "proposed_l1_mis",
    "proposed_l2",
    "proposed_l2_mis"
  ),
  stringsAsFactors = FALSE
)

continuous_methods <- data.frame(
  evaluation = c("evaluation_1", "evaluation_3", "evaluation_2", "evaluation_4"),
  result = c("results_1", "results_3", "results_2", "results_4"),
  method = c(
    "Q learning",
    "Q shared",
    "SQ learning (L1 penalty)",
    "SQ learning (L2 penalty)"
  ),
  role = c("traditional", "old_shared", "proposed_l1", "proposed_l2"),
  stringsAsFactors = FALSE
)

methods_for <- function(kind) {
  if (grepl("^binary", kind)) binary_methods else continuous_methods
}

fmt_mean_sd <- function(x, digits = 3) {
  x <- as.numeric(unlist(x, use.names = FALSE))
  x <- x[is.finite(x)]
  if (length(x) == 0) return("")
  sprintf(
    paste0("%.", digits, "f (%.", digits, "f)"),
    mean(x, na.rm = TRUE),
    stats::sd(x, na.rm = TRUE)
  )
}

mean_numeric <- function(x) {
  x <- as.numeric(unlist(x, use.names = FALSE))
  x <- x[is.finite(x)]
  if (length(x) == 0) return(NA_real_)
  mean(x, na.rm = TRUE)
}

collect_metric <- function(results, evaluation_name, metric) {
  unlist(lapply(results, function(rep) {
    if (!evaluation_name %in% names(rep)) return(NA_real_)
    value <- rep[[evaluation_name]][[metric]]
    if (is.null(value)) NA_real_ else value
  }), use.names = FALSE)
}

bias_metrics_for <- function(kind) {
  if (grepl("^binary", kind)) {
    c("A3_bias", "A2_bias", "A1_bias", "A1A3_bias", "A1A2_bias")
  } else {
    c(
      "A1_bias",
      "O1A1_bias",
      "A2_bias",
      "O2A2_bias",
      "A1A2_bias",
      "A3_bias",
      "O3A3_bias",
      "A2A3_bias",
      "A1A2A3_bias"
    )
  }
}

collect_abs_bias <- function(results, evaluation_name, kind) {
  abs(unlist(lapply(bias_metrics_for(kind), function(metric) {
    collect_metric(results, evaluation_name, metric)
  }), use.names = FALSE))
}

read_complete_results <- function(cfg, n) {
  path <- file.path(root_dir, cfg$result_dir, paste0("results_", n, ".rds"))
  results <- readRDS(path)
  results[!vapply(results, is.null, logical(1))]
}

status_rows <- do.call(rbind, lapply(names(settings), function(setting_key) {
  cfg <- settings[[setting_key]]
  calibration_path <- file.path(root_dir, cfg$calibration)
  calibration_mtime <- if (file.exists(calibration_path)) file.info(calibration_path)$mtime else as.POSIXct(NA)

  do.call(rbind, lapply(expected_ns, function(n) {
    result_path <- file.path(root_dir, cfg$result_dir, paste0("results_", n, ".rds"))
    exists <- file.exists(result_path)
    non_null_reps <- NA_integer_
    if (exists) {
      results <- readRDS(result_path)
      non_null_reps <- sum(!vapply(results, is.null, logical(1)))
    }
    result_mtime <- if (exists) file.info(result_path)$mtime else as.POSIXct(NA)
    data.frame(
      setting = cfg$name,
      n = n,
      result_file = result_path,
      result_mtime = as.character(result_mtime),
      calibration_mtime = as.character(calibration_mtime),
      non_null_reps = non_null_reps,
      expected_reps = expected_reps,
      current_result = exists && !is.na(result_mtime) && !is.na(calibration_mtime) &&
        result_mtime >= calibration_mtime,
      complete = exists && !is.na(non_null_reps) && non_null_reps == expected_reps &&
        !is.na(result_mtime) && !is.na(calibration_mtime) && result_mtime >= calibration_mtime,
      stringsAsFactors = FALSE
    )
  }))
}))

write.csv(status_rows, file.path(out_dir, "production_result_status.csv"), row.names = FALSE)

write_markdown_table <- function(data, path) {
  if (nrow(data) == 0) {
    writeLines("_No rows._", path)
    return(invisible(NULL))
  }
  data[] <- lapply(data, as.character)
  header <- paste0("| ", paste(names(data), collapse = " | "), " |")
  divider <- paste0("| ", paste(rep("---", ncol(data)), collapse = " | "), " |")
  rows <- apply(data, 1, function(x) paste0("| ", paste(x, collapse = " | "), " |"))
  writeLines(c(header, divider, rows), path)
}

write_markdown_table(status_rows, file.path(out_dir, "production_result_status.md"))

status_only <- bool_env("TABLE_STATUS_ONLY", FALSE)
if (!all(status_rows$complete)) {
  incomplete <- status_rows[!status_rows$complete, c("setting", "n", "non_null_reps", "result_mtime", "calibration_mtime", "current_result")]
  message("Production results are incomplete or stale relative to promoted calibration artifacts.")
  print(incomplete, row.names = FALSE)
  if (!status_only) quit(status = 1)
  quit(status = 0)
}

table_rows <- list()
comparison_rows <- list()
tp_fp_rows <- list()

for (setting_key in names(settings)) {
  cfg <- settings[[setting_key]]
  method_map <- methods_for(cfg$kind)

  for (n in expected_ns) {
    results <- read_complete_results(cfg, n)
    available_methods <- method_map[method_map$evaluation %in% names(results[[1]]), , drop = FALSE]

    for (i in seq_len(nrow(available_methods))) {
      row <- available_methods[i, ]
      table_rows[[length(table_rows) + 1L]] <- data.frame(
        setting = cfg$label,
        setting_name = cfg$name,
        n = n,
        method = row$method,
        role = row$role,
        allocation_matching = fmt_mean_sd(collect_metric(results, row$evaluation, "M")),
        weighted_allocation_matching = fmt_mean_sd(collect_metric(results, row$evaluation, "M_weighted")),
        bias_a1 = fmt_mean_sd(collect_metric(results, row$evaluation, "A1_bias")),
        bias_a2 = fmt_mean_sd(collect_metric(results, row$evaluation, "A2_bias")),
        bias_a3 = fmt_mean_sd(collect_metric(results, row$evaluation, "A3_bias")),
        bias_a1a2 = fmt_mean_sd(collect_metric(results, row$evaluation, "A1A2_bias")),
        bias_a1a3 = fmt_mean_sd(collect_metric(results, row$evaluation, "A1A3_bias")),
        bias_a2a3 = fmt_mean_sd(collect_metric(results, row$evaluation, "A2A3_bias")),
        mean_m = mean_numeric(collect_metric(results, row$evaluation, "M")),
        mean_m_weighted = mean_numeric(collect_metric(results, row$evaluation, "M_weighted")),
        mean_abs_bias = mean_numeric(collect_abs_bias(results, row$evaluation, cfg$kind)),
        stringsAsFactors = FALSE
      )
    }

    compare_map <- available_methods[available_methods$role %in% c("traditional", "old_shared", "proposed_l1", "proposed_l2"), , drop = FALSE]
    proposed <- compare_map[compare_map$role %in% c("proposed_l1", "proposed_l2"), , drop = FALSE]
    baselines <- compare_map[compare_map$role %in% c("traditional", "old_shared"), , drop = FALSE]
    for (p in seq_len(nrow(proposed))) {
      for (b in seq_len(nrow(baselines))) {
        p_m <- mean_numeric(collect_metric(results, proposed$evaluation[p], "M"))
        b_m <- mean_numeric(collect_metric(results, baselines$evaluation[b], "M"))
        p_mw <- mean_numeric(collect_metric(results, proposed$evaluation[p], "M_weighted"))
        b_mw <- mean_numeric(collect_metric(results, baselines$evaluation[b], "M_weighted"))
        p_bias <- mean_numeric(collect_abs_bias(results, proposed$evaluation[p], cfg$kind))
        b_bias <- mean_numeric(collect_abs_bias(results, baselines$evaluation[b], cfg$kind))
        wins <- c(p_m >= b_m, p_mw >= b_mw, p_bias <= b_bias)
        comparison_rows[[length(comparison_rows) + 1L]] <- data.frame(
          setting = cfg$label,
          n = n,
          proposed_method = proposed$method[p],
          comparator = baselines$method[b],
          delta_m = p_m - b_m,
          delta_m_weighted = p_mw - b_mw,
          delta_abs_bias = p_bias - b_bias,
          wins = sum(wins, na.rm = TRUE),
          supports_claim = sum(wins, na.rm = TRUE) >= 2,
          stringsAsFactors = FALSE
        )
      }
    }

    if (grepl("binary", cfg$kind)) {
      true_pairs <- if (identical(cfg$kind, "binary_shared")) list(c(2, 10), c(6, 11), c(7, 12)) else list()
      candidate_pairs <- list(c(2, 10), c(6, 11), c(7, 12), c(2, 14), c(10, 14))
    } else {
      true_pairs <- if (identical(cfg$kind, "continuous_shared")) {
        list(c(10, 19), c(10, 24), c(19, 24), c(11, 20), c(11, 25), c(20, 25), c(12, 21))
      } else {
        list()
      }
      candidate_pairs <- list(c(10, 19), c(10, 24), c(19, 24), c(11, 20), c(11, 25), c(20, 25), c(12, 21))
    }
    false_pairs <- Filter(function(pair) {
      !any(vapply(true_pairs, function(tp) identical(pair, tp), logical(1)))
    }, candidate_pairs)

    sq_rows <- available_methods[available_methods$role %in% c("proposed_l1", "proposed_l1_mis"), , drop = FALSE]
    for (i in seq_len(nrow(sq_rows))) {
      result_name <- sq_rows$result[i]
      tp <- vapply(results, function(rep) {
        theta <- rep[[result_name]]$theta
        if (!length(true_pairs)) return(NA_real_)
        sum(vapply(true_pairs, function(pair) isTRUE(all.equal(theta[pair[1]], theta[pair[2]], tolerance = 1e-5)), logical(1)))
      }, numeric(1))
      fp <- vapply(results, function(rep) {
        theta <- rep[[result_name]]$theta
        if (!length(false_pairs)) return(NA_real_)
        sum(vapply(false_pairs, function(pair) isTRUE(all.equal(theta[pair[1]], theta[pair[2]], tolerance = 1e-5)), logical(1)))
      }, numeric(1))
      tp_fp_rows[[length(tp_fp_rows) + 1L]] <- data.frame(
        setting = cfg$label,
        n = n,
        method = sq_rows$method[i],
        true_positives = fmt_mean_sd(tp),
        false_positives = fmt_mean_sd(fp),
        stringsAsFactors = FALSE
      )
    }
  }
}

all_tables <- do.call(rbind, table_rows)
comparisons <- do.call(rbind, comparison_rows)
tp_fp <- do.call(rbind, tp_fp_rows)

write.csv(all_tables, file.path(out_dir, "all_method_summary.csv"), row.names = FALSE)
write.csv(
  all_tables[all_tables$setting_name == "Setting I", c(
    "setting", "n", "method", "allocation_matching", "weighted_allocation_matching", "bias_a3"
  )],
  file.path(out_dir, "table1_setting_i.csv"),
  row.names = FALSE
)
write.csv(
  all_tables[all_tables$setting_name %in% c("Setting II", "Setting III"), c(
    "setting", "n", "method", "allocation_matching", "weighted_allocation_matching",
    "bias_a1", "bias_a2", "bias_a3"
  )],
  file.path(out_dir, "table2_settings_ii_iii.csv"),
  row.names = FALSE
)
write.csv(
  all_tables[all_tables$setting_name == "Supplementary Setting III No Shared", c(
    "setting", "n", "method", "allocation_matching", "weighted_allocation_matching",
    "bias_a1", "bias_a2", "bias_a3"
  )],
  file.path(out_dir, "suppl_table_setting_iii_no_shared.csv"),
  row.names = FALSE
)
write.csv(tp_fp, file.path(out_dir, "suppl_table_tp_fp.csv"), row.names = FALSE)
write.csv(comparisons, file.path(out_dir, "method_claim_check.csv"), row.names = FALSE)

write_markdown_table(
  all_tables[all_tables$setting_name == "Setting I", c(
    "setting", "n", "method", "allocation_matching", "weighted_allocation_matching", "bias_a3"
  )],
  file.path(out_dir, "table1_setting_i.md")
)
write_markdown_table(
  all_tables[all_tables$setting_name %in% c("Setting II", "Setting III"), c(
    "setting", "n", "method", "allocation_matching", "weighted_allocation_matching",
    "bias_a1", "bias_a2", "bias_a3"
  )],
  file.path(out_dir, "table2_settings_ii_iii.md")
)
write_markdown_table(
  all_tables[all_tables$setting_name == "Supplementary Setting III No Shared", c(
    "setting", "n", "method", "allocation_matching", "weighted_allocation_matching",
    "bias_a1", "bias_a2", "bias_a3"
  )],
  file.path(out_dir, "suppl_table_setting_iii_no_shared.md")
)
write_markdown_table(tp_fp, file.path(out_dir, "suppl_table_tp_fp.md"))
write_markdown_table(comparisons, file.path(out_dir, "method_claim_check.md"))

claim_summary <- data.frame(
  total_comparisons = nrow(comparisons),
  supported_comparisons = sum(comparisons$supports_claim),
  support_rate = mean(comparisons$supports_claim),
  flagged_comparisons = sum(!comparisons$supports_claim),
  stringsAsFactors = FALSE
)
write.csv(claim_summary, file.path(out_dir, "method_claim_summary.csv"), row.names = FALSE)
write_markdown_table(claim_summary, file.path(out_dir, "method_claim_summary.md"))

message("Wrote result tables under: ", out_dir)
