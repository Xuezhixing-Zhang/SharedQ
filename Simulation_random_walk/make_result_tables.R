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
    table_group = "main_setting_i",
    stale_for_reporting = TRUE,
    status_note = "Superseded by the 2026-06-02 rounded seed-63 `balanced_small` target revision; wait for revised Setting I calibration and production rerun before reporting."
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
  ),
  Setting4 = list(
    label = "IV",
    name = "Setting IV",
    result_dir = "Setting4/simulation_results",
    calibration = "Setting4/calibration/calibration_pqff_shared_parsimonious.rds",
    kind = "setting4_shared",
    table_group = "main_setting_iv"
  ),
  SupplSetting4_NoShared = list(
    label = "Suppl IV No Shared",
    name = "Supplementary Setting IV No Shared",
    result_dir = "SupplSetting4_NoShared/simulation_results",
    calibration = "SupplSetting4_NoShared/calibration/calibration_pqff_separated_parsimonious.rds",
    kind = "setting4_no_shared",
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
  } else if (grepl("^setting4", kind)) {
    paste0(c(
      "Q2_intercept",
      "Q2_PQQuit",
      "Q2_PQSE",
      "Q2_PQMotiv",
      "Q2_LowEducation",
      "Q2_A_FF",
      "Q2_PQQuit_A_FF",
      "Q2_PQSE_A_FF",
      "Q2_PQMotiv_A_FF",
      "Q2_LowEducation_A_FF",
      "Q1_intercept",
      "Q1_QuitSE",
      "Q1_QuitMotiv",
      "Q1_LowEducation",
      "Q1_A_source",
      "Q1_A_outcome",
      "Q1_A_story",
      "Q1_A_efficacy",
      "Q1_A_multiple",
      "Q1_QuitSE_A_efficacy",
      "Q1_QuitMotiv_A_outcome",
      "Q1_LowEducation_A_story"
    ), "_bias")
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

read_results_file <- function(path) {
  tryCatch(
    readRDS(path),
    error = function(e) {
      warning("Could not read result file `", path, "`: ", conditionMessage(e), call. = FALSE)
      NULL
    }
  )
}

read_complete_results <- function(cfg, n) {
  path <- file.path(root_dir, cfg$result_dir, paste0("results_", n, ".rds"))
  results <- read_results_file(path)
  if (is.null(results)) return(list())
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
      results <- read_results_file(result_path)
      if (!is.null(results)) {
        non_null_reps <- sum(!vapply(results, is.null, logical(1)))
      }
    }
    result_mtime <- if (exists) file.info(result_path)$mtime else as.POSIXct(NA)
    artifact_current <- exists && !is.na(result_mtime) && !is.na(calibration_mtime) &&
      result_mtime >= calibration_mtime
    reporting_current <- artifact_current && !isTRUE(cfg$stale_for_reporting)
    data.frame(
      setting = cfg$name,
      n = n,
      result_file = result_path,
      result_mtime = as.character(result_mtime),
      calibration_mtime = as.character(calibration_mtime),
      non_null_reps = non_null_reps,
      expected_reps = expected_reps,
      current_result = reporting_current,
      complete = exists && !is.na(non_null_reps) && non_null_reps == expected_reps &&
        reporting_current,
      status_note = if (!is.null(cfg$status_note)) cfg$status_note else "",
      stringsAsFactors = FALSE
    )
  }))
}))

write.csv(status_rows, file.path(out_dir, "production_result_status.csv"), row.names = FALSE)

markdown_table_lines <- function(data) {
  if (nrow(data) == 0) {
    return("_No rows._")
  }
  data[] <- lapply(data, as.character)
  header <- paste0("| ", paste(names(data), collapse = " | "), " |")
  divider <- paste0("| ", paste(rep("---", ncol(data)), collapse = " | "), " |")
  rows <- apply(data, 1, function(x) paste0("| ", paste(x, collapse = " | "), " |"))
  c(header, divider, rows)
}

write_markdown_table <- function(data, path) {
  writeLines(markdown_table_lines(data), path)
}

write_markdown_table(status_rows, file.path(out_dir, "production_result_status.md"))

status_only <- bool_env("TABLE_STATUS_ONLY", FALSE)
completed_only <- bool_env("TABLE_COMPLETED_ONLY", FALSE)

completed_setting_keys <- names(settings)[vapply(names(settings), function(setting_key) {
  cfg <- settings[[setting_key]]
  rows <- status_rows[status_rows$setting == cfg$name, , drop = FALSE]
  nrow(rows) == length(expected_ns) && all(rows$complete)
}, logical(1))]

active_setting_keys <- names(settings)
if (completed_only) {
  active_setting_keys <- completed_setting_keys
}

if (!all(status_rows$complete)) {
  incomplete <- status_rows[!status_rows$complete, c("setting", "n", "non_null_reps", "result_mtime", "calibration_mtime", "current_result", "status_note")]
  message("Production results are incomplete or stale relative to promoted calibration artifacts.")
  print(incomplete, row.names = FALSE)
  if (completed_only) {
    if (length(active_setting_keys) == 0L) {
      stop("TABLE_COMPLETED_ONLY=1 was requested, but no settings are complete.")
    }
    message(
      "TABLE_COMPLETED_ONLY=1: generating tables for completed settings only: ",
      paste(vapply(settings[active_setting_keys], `[[`, character(1), "name"), collapse = ", ")
    )
  } else {
    if (!status_only) quit(status = 1)
    quit(status = 0)
  }
}

table_rows <- list()
comparison_rows <- list()
tp_fp_rows <- list()

for (setting_key in active_setting_keys) {
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
        a_ff_match = fmt_mean_sd(collect_metric(results, row$evaluation, "A_FF_match")),
        a_source_match = fmt_mean_sd(collect_metric(results, row$evaluation, "A_source_match")),
        a_outcome_match = fmt_mean_sd(collect_metric(results, row$evaluation, "A_outcome_match")),
        a_story_match = fmt_mean_sd(collect_metric(results, row$evaluation, "A_story_match")),
        a_efficacy_match = fmt_mean_sd(collect_metric(results, row$evaluation, "A_efficacy_match")),
        a_multiple_match = fmt_mean_sd(collect_metric(results, row$evaluation, "A_multiple_match")),
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
    } else if (grepl("^setting4", cfg$kind)) {
      true_pairs <- if (identical(cfg$kind, "setting4_shared")) {
        list(c(3, 12), c(4, 13), c(5, 14), c(8, 20), c(9, 21), c(10, 22))
      } else {
        list()
      }
      candidate_pairs <- list(c(3, 12), c(4, 13), c(5, 14), c(8, 20), c(9, 21), c(10, 22))
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

table1_data <- all_tables[all_tables$setting_name == "Setting I", c(
  "setting", "n", "method", "allocation_matching", "weighted_allocation_matching", "bias_a3"
)]
table2_data <- all_tables[all_tables$setting_name %in% c("Setting II", "Setting III"), c(
  "setting", "n", "method", "allocation_matching", "weighted_allocation_matching",
  "bias_a1", "bias_a2", "bias_a3"
)]
suppl_setting_iii_data <- all_tables[all_tables$setting_name == "Supplementary Setting III No Shared", c(
  "setting", "n", "method", "allocation_matching", "weighted_allocation_matching",
  "bias_a1", "bias_a2", "bias_a3"
)]
setting_iv_data <- all_tables[all_tables$setting_name == "Setting IV", c(
  "setting", "n", "method", "allocation_matching", "weighted_allocation_matching",
  "a_ff_match", "mean_abs_bias"
)]
suppl_setting_iv_data <- all_tables[all_tables$setting_name == "Supplementary Setting IV No Shared", c(
  "setting", "n", "method", "allocation_matching", "weighted_allocation_matching",
  "a_ff_match", "mean_abs_bias"
)]

write.csv(all_tables, file.path(out_dir, "all_method_summary.csv"), row.names = FALSE)
write.csv(table1_data, file.path(out_dir, "table1_setting_i.csv"), row.names = FALSE)
write.csv(table2_data, file.path(out_dir, "table2_settings_ii_iii.csv"), row.names = FALSE)
write.csv(suppl_setting_iii_data, file.path(out_dir, "suppl_table_setting_iii_no_shared.csv"), row.names = FALSE)
write.csv(setting_iv_data, file.path(out_dir, "table3_setting_iv.csv"), row.names = FALSE)
write.csv(suppl_setting_iv_data, file.path(out_dir, "suppl_table_setting_iv_no_shared.csv"), row.names = FALSE)
write.csv(tp_fp, file.path(out_dir, "suppl_table_tp_fp.csv"), row.names = FALSE)
write.csv(comparisons, file.path(out_dir, "method_claim_check.csv"), row.names = FALSE)

write_markdown_table(table1_data, file.path(out_dir, "table1_setting_i.md"))
write_markdown_table(table2_data, file.path(out_dir, "table2_settings_ii_iii.md"))
write_markdown_table(suppl_setting_iii_data, file.path(out_dir, "suppl_table_setting_iii_no_shared.md"))
write_markdown_table(setting_iv_data, file.path(out_dir, "table3_setting_iv.md"))
write_markdown_table(suppl_setting_iv_data, file.path(out_dir, "suppl_table_setting_iv_no_shared.md"))
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

main_report_lines <- c(
  "# Completed Main Tables",
  "",
  "Tables follow the structure of `docs/reports_tables_and_figures.docx`.",
  "",
  "Table 1: Simulation Results for Setting I. For each setting, we run 200 replicates.",
  "",
  if (nrow(table1_data) == 0L) {
    "Setting I revised calibration and production are pending, so Table 1 is pending."
  } else {
    markdown_table_lines(table1_data)
  },
  "",
  "Table 2: Simulation Results for Setting II and III. For each setting, we run 200 replicates.",
  "",
  markdown_table_lines(table2_data),
  "",
  "Table 3: Simulation Results for Setting IV. For each setting, we run 200 replicates.",
  "",
  markdown_table_lines(setting_iv_data)
)
writeLines(main_report_lines, file.path(out_dir, "completed_main_tables.md"))

supplement_report_lines <- c(
  "# Completed Supplementary Tables",
  "",
  "Tables follow the structure of `docs/reports_suppl_tables_and_figures.docx`.",
  "",
  "Suppl Table 1: True Positives and False Positives for SQ learning with L1 penalty. For each setting, we run 200 replicates.",
  "",
  markdown_table_lines(tp_fp),
  "",
  "Supplementary simulation results for Setting III No Shared.",
  "",
  markdown_table_lines(suppl_setting_iii_data),
  "",
  "Supplementary simulation results for Setting IV No Shared.",
  "",
  markdown_table_lines(suppl_setting_iv_data)
)
writeLines(supplement_report_lines, file.path(out_dir, "completed_supplement_tables.md"))

xml_escape <- function(x) {
  x <- as.character(x)
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub("\"", "&quot;", x, fixed = TRUE)
  x
}

docx_paragraph <- function(text, bold = FALSE) {
  bold_xml <- if (bold) "<w:rPr><w:b/></w:rPr>" else ""
  paste0("<w:p><w:r>", bold_xml, "<w:t>", xml_escape(text), "</w:t></w:r></w:p>")
}

docx_table <- function(data) {
  if (nrow(data) == 0L) {
    return(docx_paragraph("No rows."))
  }
  data[] <- lapply(data, as.character)
  rows <- list(names(data))
  for (i in seq_len(nrow(data))) {
    rows[[length(rows) + 1L]] <- unname(unlist(data[i, ], use.names = FALSE))
  }
  row_xml <- vapply(seq_along(rows), function(i) {
    cells <- vapply(rows[[i]], function(value) {
      paste0(
        "<w:tc><w:tcPr><w:tcW w:w=\"1800\" w:type=\"dxa\"/></w:tcPr>",
        docx_paragraph(value, bold = i == 1L),
        "</w:tc>"
      )
    }, character(1))
    paste0("<w:tr>", paste(cells, collapse = ""), "</w:tr>")
  }, character(1))
  paste0(
    "<w:tbl><w:tblPr><w:tblStyle w:val=\"TableGrid\"/><w:tblW w:w=\"0\" w:type=\"auto\"/>",
    "<w:tblBorders><w:top w:val=\"single\" w:sz=\"4\" w:space=\"0\" w:color=\"auto\"/>",
    "<w:left w:val=\"single\" w:sz=\"4\" w:space=\"0\" w:color=\"auto\"/>",
    "<w:bottom w:val=\"single\" w:sz=\"4\" w:space=\"0\" w:color=\"auto\"/>",
    "<w:right w:val=\"single\" w:sz=\"4\" w:space=\"0\" w:color=\"auto\"/>",
    "<w:insideH w:val=\"single\" w:sz=\"4\" w:space=\"0\" w:color=\"auto\"/>",
    "<w:insideV w:val=\"single\" w:sz=\"4\" w:space=\"0\" w:color=\"auto\"/></w:tblBorders>",
    "</w:tblPr>",
    paste(row_xml, collapse = ""),
    "</w:tbl>"
  )
}

write_simple_docx <- function(path, body_blocks) {
  doc_dir <- tempfile("docx")
  dir.create(file.path(doc_dir, "_rels"), recursive = TRUE)
  dir.create(file.path(doc_dir, "word", "_rels"), recursive = TRUE)

  writeLines(
    c(
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">',
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>',
      '<Default Extension="xml" ContentType="application/xml"/>',
      '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>',
      '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>',
      '</Types>'
    ),
    file.path(doc_dir, "[Content_Types].xml")
  )
  writeLines(
    c(
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>',
      '</Relationships>'
    ),
    file.path(doc_dir, "_rels", ".rels")
  )
  writeLines(
    c(
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>'
    ),
    file.path(doc_dir, "word", "_rels", "document.xml.rels")
  )
  writeLines(
    c(
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
      '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">',
      '<w:style w:type="table" w:default="1" w:styleId="TableNormal"><w:name w:val="Normal Table"/></w:style>',
      '<w:style w:type="table" w:styleId="TableGrid"><w:name w:val="Table Grid"/></w:style>',
      '</w:styles>'
    ),
    file.path(doc_dir, "word", "styles.xml")
  )
  document <- paste0(
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">',
    '<w:body>',
    paste(body_blocks, collapse = ""),
    '<w:sectPr><w:pgSz w:w="15840" w:h="12240" w:orient="landscape"/>',
    '<w:pgMar w:top="720" w:right="720" w:bottom="720" w:left="720" w:header="360" w:footer="360" w:gutter="0"/>',
    '</w:sectPr></w:body></w:document>'
  )
  writeLines(document, file.path(doc_dir, "word", "document.xml"))

  if (file.exists(path)) unlink(path)
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(doc_dir)
  utils::zip(
    zipfile = normalizePath(path, mustWork = FALSE),
    files = c("[Content_Types].xml", "_rels/.rels", "word/document.xml", "word/styles.xml", "word/_rels/document.xml.rels"),
    flags = "-q"
  )
  setwd(old_wd)
  unlink(doc_dir, recursive = TRUE)
}

write_simple_docx(
  file.path(out_dir, "completed_main_tables.docx"),
  c(
    docx_paragraph("Completed Main Tables", bold = TRUE),
    docx_paragraph("Tables follow the structure of docs/reports_tables_and_figures.docx."),
    docx_paragraph("Table 1: Simulation Results for Setting I. For each setting, we run 200 replicates.", bold = TRUE),
    if (nrow(table1_data) == 0L) docx_paragraph("Setting I revised calibration and production are pending, so Table 1 is pending.") else docx_table(table1_data),
    docx_paragraph("Table 2: Simulation Results for Setting II and III. For each setting, we run 200 replicates.", bold = TRUE),
    docx_table(table2_data),
    docx_paragraph("Table 3: Simulation Results for Setting IV. For each setting, we run 200 replicates.", bold = TRUE),
    docx_table(setting_iv_data)
  )
)

write_simple_docx(
  file.path(out_dir, "reports_tables_and_figures_generated.docx"),
  c(
    docx_paragraph("Generated Main Tables", bold = TRUE),
    docx_paragraph("Tables follow the structure of docs/reports_tables_and_figures.docx."),
    docx_paragraph("Table 1: Simulation Results for Setting I. For each setting, we run 200 replicates.", bold = TRUE),
    if (nrow(table1_data) == 0L) docx_paragraph("Setting I revised calibration and production are pending, so Table 1 is pending.") else docx_table(table1_data),
    docx_paragraph("Table 2: Simulation Results for Setting II and III. For each setting, we run 200 replicates.", bold = TRUE),
    docx_table(table2_data),
    docx_paragraph("Table 3: Simulation Results for Setting IV. For each setting, we run 200 replicates.", bold = TRUE),
    docx_table(setting_iv_data)
  )
)

write_simple_docx(
  file.path(out_dir, "completed_supplement_tables.docx"),
  c(
    docx_paragraph("Completed Supplementary Tables", bold = TRUE),
    docx_paragraph("Tables follow the structure of docs/reports_suppl_tables_and_figures.docx."),
    docx_paragraph("Suppl Table 1: True Positives and False Positives for SQ learning with L1 penalty. For each setting, we run 200 replicates.", bold = TRUE),
    docx_table(tp_fp),
    docx_paragraph("Supplementary simulation results for Setting III No Shared.", bold = TRUE),
    docx_table(suppl_setting_iii_data),
    docx_paragraph("Supplementary simulation results for Setting IV No Shared.", bold = TRUE),
    docx_table(suppl_setting_iv_data)
  )
)

write_simple_docx(
  file.path(out_dir, "reports_suppl_tables_and_figures_generated.docx"),
  c(
    docx_paragraph("Generated Supplementary Tables", bold = TRUE),
    docx_paragraph("Tables follow the structure of docs/reports_suppl_tables_and_figures.docx."),
    docx_paragraph("Suppl Table 1: True Positives and False Positives for SQ learning with L1 penalty. For each setting, we run 200 replicates.", bold = TRUE),
    docx_table(tp_fp),
    docx_paragraph("Supplementary simulation results for Setting III No Shared.", bold = TRUE),
    docx_table(suppl_setting_iii_data),
    docx_paragraph("Supplementary simulation results for Setting IV No Shared.", bold = TRUE),
    docx_table(suppl_setting_iv_data)
  )
)

message("Wrote result tables under: ", out_dir)
