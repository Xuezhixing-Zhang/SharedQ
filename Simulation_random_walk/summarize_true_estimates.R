root_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk"
docs_dir <- file.path(dirname(root_dir), "docs")

fmt <- function(x) {
  if (is.null(x) || length(x) == 0 || is.na(x)) return("NA")
  formatC(as.numeric(x), digits = 4, format = "f")
}

clean_name <- function(x) {
  sub(".*\\.", "", x)
}

best_theta <- function(path) {
  if (!file.exists(path)) {
    setting_dir <- dirname(path)
    candidate <- file.path(setting_dir, "calibration", basename(path))
    if (file.exists(candidate)) path <- candidate
  }
  x <- readRDS(path)
  best_idx <- which.min(x$values)
  theta <- x$all_theta[, best_idx]
  names(theta) <- clean_name(names(theta))
  list(theta = theta, fit = x, best_idx = best_idx, best_value = x$values[best_idx])
}

line <- function(...) paste(..., sep = " | ")

setting1_rows <- function() {
  specs <- readRDS(file.path(root_dir, "Setting1", "calibration", "shared_parameter_spec_runs.rds"))
  rows <- c(
    line("Setting", "Spec", "Sigma", "Parameter group", "True estimates"),
    line("---", "---", "---", "---", "---")
  )
  for (spec_name in names(specs)) {
    spec <- specs[[spec_name]]
    est <- best_theta(spec$output_path)
    th <- est$theta
    rows <- c(rows,
      line(
        "I",
        spec_name,
        paste0("psi1=", fmt(spec$shared_sigma["psi1"])),
        "psi1: Q3_A1 / Q2_A1",
        paste0("Q3_A1=", fmt(th[2]), "; Q2_A1=", fmt(th[10]))
      ),
      line(
        "I",
        spec_name,
        paste0("psi2=", fmt(spec$shared_sigma["psi2"])),
        "psi2: Q3_A3 / Q2_A2",
        paste0("Q3_A3=", fmt(th[6]), "; Q2_A2=", fmt(th[11]))
      ),
      line(
        "I",
        spec_name,
        paste0("psi3=", fmt(spec$shared_sigma["psi3"])),
        "psi3: Q3_A1A3 / Q2_A1A2",
        paste0("Q3_A1A3=", fmt(th[7]), "; Q2_A1A2=", fmt(th[12]))
      )
    )
  }
  rows
}

setting2_rows <- function() {
  specs <- readRDS(file.path(root_dir, "Setting2", "calibration", "parameter_spec_runs.rds"))
  rows <- c(
    line("Setting", "Spec", "Sigma", "Parameter group", "True estimates"),
    line("---", "---", "---", "---", "---")
  )
  for (spec_name in names(specs)) {
    spec <- specs[[spec_name]]
    est <- best_theta(spec$output_path)
    th <- est$theta
    rows <- c(rows,
      line("II", spec_name, "NA (no shared target)", "Q3_A1 / Q2_A1", paste0("Q3_A1=", fmt(th[2]), "; Q2_A1=", fmt(th[10]))),
      line("II", spec_name, "NA (no shared target)", "Q3_A3 / Q2_A2", paste0("Q3_A3=", fmt(th[6]), "; Q2_A2=", fmt(th[11]))),
      line("II", spec_name, "NA (no shared target)", "Q3_A1A3 / Q2_A1A2", paste0("Q3_A1A3=", fmt(th[7]), "; Q2_A1A2=", fmt(th[12])))
    )
  }
  rows
}

setting3_rows <- function() {
  specs <- readRDS(file.path(root_dir, "Setting3", "calibration", "parameter_spec_runs.rds"))
  rows <- c(
    line("Setting", "Spec", "Sigma", "Parameter group", "True estimates"),
    line("---", "---", "---", "---", "---")
  )
  for (spec_name in names(specs)) {
    spec <- specs[[spec_name]]
    est <- best_theta(spec$output_path)
    th <- est$theta
    rows <- c(rows,
      line("III", spec_name, paste0("psi0=", fmt(spec$sigmas["psi0"])), "psi0: Q3_A3 / Q2_A2 / Q1_A1", paste0("Q3_A3=", fmt(th[10]), "; Q2_A2=", fmt(th[19]), "; Q1_A1=", fmt(th[24]))),
      line("III", spec_name, paste0("psi1=", fmt(spec$sigmas["psi1"])), "psi1: Q3_O3:A3 / Q2_O2:A2 / Q1_O1:A1", paste0("Q3_O3:A3=", fmt(th[11]), "; Q2_O2:A2=", fmt(th[20]), "; Q1_O1:A1=", fmt(th[25]))),
      line("III", spec_name, paste0("psi2=", fmt(spec$sigmas["psi2"])), "psi2: Q3_A2:A3 / Q2_A1:A2", paste0("Q3_A2:A3=", fmt(th[12]), "; Q2_A1:A2=", fmt(th[21]))),
      line("III", spec_name, "NA (unpaired)", "Q3_A1:A2:A3", paste0("Q3_A1:A2:A3=", fmt(th[13])))
    )
  }
  rows
}

supplement_rows <- function() {
  paths <- file.path(root_dir, "SupplSetting3_NoShared", "calibration", c(
    "calibration_separated_moderate.rds",
    "calibration_separated_reversed.rds",
    "calibration_separated_large.rds"
  ))
  names(paths) <- c("separated_moderate", "separated_reversed", "separated_large")
  paths <- paths[file.exists(paths)]
  if (length(paths) == 0L) {
    paths <- file.path(root_dir, "SupplSetting3_NoShared", "calibration", "test_alternative_pars.rds")
    names(paths) <- "smoke_default"
  }

  rows <- c(
    line("Setting", "Spec", "Sigma", "Parameter group", "True estimates"),
    line("---", "---", "---", "---", "---")
  )
  for (spec_name in names(paths)) {
    est <- best_theta(paths[[spec_name]])
    th <- est$theta
    rows <- c(rows,
      line("Supplementary III no-shared", spec_name, "NA (no shared target)", "Q3_A3 / Q2_A2 / Q1_A1", paste0("Q3_A3=", fmt(th[10]), "; Q2_A2=", fmt(th[19]), "; Q1_A1=", fmt(th[24]))),
      line("Supplementary III no-shared", spec_name, "NA (no shared target)", "Q3_O3:A3 / Q2_O2:A2 / Q1_O1:A1", paste0("Q3_O3:A3=", fmt(th[11]), "; Q2_O2:A2=", fmt(th[20]), "; Q1_O1:A1=", fmt(th[25]))),
      line("Supplementary III no-shared", spec_name, "NA (no shared target)", "Q3_A2:A3 / Q2_A1:A2", paste0("Q3_A2:A3=", fmt(th[12]), "; Q2_A1:A2=", fmt(th[21]))),
      line("Supplementary III no-shared", spec_name, "NA (unpaired)", "Q3_A1:A2:A3", paste0("Q3_A1:A2:A3=", fmt(th[13])))
    )
  }
  rows
}

out <- c(
  "# True Estimate And Sigma Summary",
  "",
  "Values are the best available population-projected Q-parameter estimates saved in each calibration `.rds` artifact, not the hand-specified targets. Bounded calibration artifacts use small `mc_n` and optimizer budgets unless production calibration has replaced them.",
  "",
  "## Setting I",
  "",
  setting1_rows(),
  "",
  "## Setting II",
  "",
  setting2_rows(),
  "",
  "## Setting III",
  "",
  setting3_rows(),
  "",
  "## Supplementary Setting III No Shared",
  "",
  supplement_rows(),
  ""
)

writeLines(out, file.path(docs_dir, "simulation_random_walk_true_estimates_sigma_summary.md"))
