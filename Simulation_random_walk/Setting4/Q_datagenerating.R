setting4_dir <- "/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting4"
setting4_calibration_dir <- file.path(setting4_dir, "calibration")
dir.create(setting4_calibration_dir, showWarnings = FALSE, recursive = TRUE)

setting4_theta_names <- c(
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
)

setting4_target_theta <- function(spec = "pqff_shared_parsimonious") {
  if (!identical(spec, "pqff_shared_parsimonious")) {
    stop("Unsupported Setting IV spec: ", spec)
  }

  theta <- c(
    Q2_intercept = 0.10,
    Q2_PQQuit = 0.40,
    Q2_PQSE = 0.3560,
    Q2_PQMotiv = 0.2389,
    Q2_LowEducation = -0.0863,
    Q2_A_FF = 0.12,
    Q2_PQQuit_A_FF = -0.08,
    Q2_PQSE_A_FF = 0.1116,
    Q2_PQMotiv_A_FF = 0.1322,
    Q2_LowEducation_A_FF = 0.1745,
    Q1_intercept = 0.10,
    Q1_QuitSE = 0.4235,
    Q1_QuitMotiv = 0.2320,
    Q1_LowEducation = -0.1149,
    Q1_A_source = 0.20,
    Q1_A_outcome = 0.08,
    Q1_A_story = 0.18,
    Q1_A_efficacy = 0.08,
    Q1_A_multiple = 0.02,
    Q1_QuitSE_A_efficacy = 0.1229,
    Q1_QuitMotiv_A_outcome = 0.1601,
    Q1_LowEducation_A_story = 0.2000
  )
  theta[setting4_theta_names]
}

setting4_fractional_factorial_arms <- function() {
  base <- expand.grid(
    A_source = c(-1, 1),
    A_outcome = c(-1, 1),
    A_story = c(-1, 1),
    A_efficacy = c(-1, 1)
  )
  base$A_multiple <- with(base, A_source * A_outcome * A_story * A_efficacy)
  base
}

as_binary01 <- function(x) {
  if (is.logical(x)) return(as.integer(x))
  x_num <- suppressWarnings(as.numeric(x))
  if (all(stats::na.omit(x_num) %in% c(0, 1))) return(as.integer(x_num))
  if (all(stats::na.omit(x_num) %in% c(-1, 1))) return(as.integer(x_num == 1))
  as.integer(x_num > stats::median(x_num, na.rm = TRUE))
}

as_pm1 <- function(x) {
  x_num <- suppressWarnings(as.numeric(x))
  if (all(stats::na.omit(x_num) %in% c(-1, 1))) return(as.integer(x_num))
  if (all(stats::na.omit(x_num) %in% c(0, 1))) return(ifelse(x_num == 1, 1L, -1L))
  ifelse(x_num > stats::median(x_num, na.rm = TRUE), 1L, -1L)
}

read_setting4_source_file <- function(path) {
  ext <- tolower(tools::file_ext(path))
  if (identical(ext, "rds")) return(readRDS(path))
  if (ext %in% c("csv", "txt")) return(utils::read.csv(path, stringsAsFactors = FALSE))
  if (ext %in% c("rda", "rdata")) {
    env <- new.env(parent = emptyenv())
    load(path, envir = env)
    objects <- mget(ls(env), envir = env)
    data_objects <- objects[vapply(objects, is.data.frame, logical(1))]
    if (length(data_objects) == 0L) stop("No data.frame object found in ", path)
    return(data_objects[[1]])
  }
  stop("Unsupported Setting IV source data file extension: ", ext)
}

prepare_setting4_source_data <- function(
  source_path = Sys.getenv("SETTING4_SOURCE_DATA", unset = ""),
  allow_synthetic = FALSE,
  synthetic_n = 5000,
  seed = 601
) {
  if (!nzchar(source_path) || !file.exists(source_path)) {
    if (!allow_synthetic) {
      stop(
        "Missing cleaned Project Quit / Forever Free source data. Set SETTING4_SOURCE_DATA ",
        "to a file containing FFConsent, FFArm, QuitOverallSEBin, QuitOverallMotivBin, ",
        "EDUCATION, PQ6Quitstatus, PQ6OverallSEBin, PQ6OverallMotivBin, SOURCE.DEPTH, ",
        "OUTCOME.DEPTH, STORY.DEPTH, EFFICACY.DEPTH, and EXPOSURE. For a code smoke run ",
        "only, set SETTING4_ALLOW_SYNTHETIC=1."
      )
    }
    return(generate_synthetic_setting4_source(synthetic_n, seed = seed))
  }

  raw <- read_setting4_source_file(source_path)
  required <- c(
    "FFConsent", "FFArm", "QuitOverallSEBin", "QuitOverallMotivBin", "EDUCATION",
    "PQ6Quitstatus", "PQ6OverallSEBin", "PQ6OverallMotivBin",
    "SOURCE.DEPTH", "OUTCOME.DEPTH", "STORY.DEPTH", "EFFICACY.DEPTH", "EXPOSURE"
  )
  missing <- setdiff(required, names(raw))
  if (length(missing)) {
    stop("Setting IV source data is missing required columns: ", paste(missing, collapse = ", "))
  }

  keep <- raw[as_binary01(raw$FFConsent) == 1L, , drop = FALSE]
  out <- data.frame(
    QuitSE = as_binary01(keep$QuitOverallSEBin),
    QuitMotiv = as_binary01(keep$QuitOverallMotivBin),
    LowEducation = 1L - as_binary01(keep$EDUCATION),
    PQQuit = as_binary01(keep$PQ6Quitstatus),
    PQSE = as_binary01(keep$PQ6OverallSEBin),
    PQMotiv = as_binary01(keep$PQ6OverallMotivBin),
    A_source = -as_pm1(keep$SOURCE.DEPTH),
    A_outcome = as_pm1(keep$OUTCOME.DEPTH),
    A_story = as_pm1(keep$STORY.DEPTH),
    A_efficacy = as_pm1(keep$EFFICACY.DEPTH),
    A_multiple = -as_pm1(keep$EXPOSURE),
    A_FF = as_pm1(keep$FFArm),
    source_mode = "real",
    stringsAsFactors = FALSE
  )
  stats::na.omit(out)
}

generate_synthetic_setting4_source <- function(n, seed = 601) {
  set.seed(seed)
  arms <- setting4_fractional_factorial_arms()
  arm_idx <- sample(seq_len(nrow(arms)), n, replace = TRUE)
  arm_data <- arms[arm_idx, , drop = FALSE]

  QuitSE <- rbinom(n, 1, 0.48)
  QuitMotiv <- rbinom(n, 1, 0.55)
  LowEducation <- rbinom(n, 1, 0.38)
  logit_pq <- -0.25 + 0.55 * QuitSE + 0.35 * QuitMotiv - 0.20 * LowEducation +
    0.18 * arm_data$A_efficacy + 0.12 * arm_data$A_outcome
  PQQuit <- rbinom(n, 1, stats::plogis(logit_pq))
  PQSE <- rbinom(n, 1, stats::plogis(-0.10 + 0.75 * QuitSE + 0.25 * PQQuit + 0.12 * arm_data$A_efficacy))
  PQMotiv <- rbinom(n, 1, stats::plogis(0.05 + 0.70 * QuitMotiv + 0.20 * PQQuit + 0.10 * arm_data$A_outcome))
  A_FF <- ifelse(rbinom(n, 1, 2 / 3) == 1L, 1L, -1L)

  data.frame(
    QuitSE = QuitSE,
    QuitMotiv = QuitMotiv,
    LowEducation = LowEducation,
    PQQuit = PQQuit,
    PQSE = PQSE,
    PQMotiv = PQMotiv,
    A_source = arm_data$A_source,
    A_outcome = arm_data$A_outcome,
    A_story = arm_data$A_story,
    A_efficacy = arm_data$A_efficacy,
    A_multiple = arm_data$A_multiple,
    A_FF = A_FF,
    source_mode = "synthetic",
    stringsAsFactors = FALSE
  )
}

setting4_q2_matrix <- function(data) {
  cbind(
    Q2_intercept = 1,
    Q2_PQQuit = data$PQQuit,
    Q2_PQSE = data$PQSE,
    Q2_PQMotiv = data$PQMotiv,
    Q2_LowEducation = data$LowEducation,
    Q2_A_FF = data$A_FF,
    Q2_PQQuit_A_FF = data$PQQuit * data$A_FF,
    Q2_PQSE_A_FF = data$PQSE * data$A_FF,
    Q2_PQMotiv_A_FF = data$PQMotiv * data$A_FF,
    Q2_LowEducation_A_FF = data$LowEducation * data$A_FF
  )
}

setting4_q1_matrix <- function(data) {
  cbind(
    Q1_intercept = 1,
    Q1_QuitSE = data$QuitSE,
    Q1_QuitMotiv = data$QuitMotiv,
    Q1_LowEducation = data$LowEducation,
    Q1_A_source = data$A_source,
    Q1_A_outcome = data$A_outcome,
    Q1_A_story = data$A_story,
    Q1_A_efficacy = data$A_efficacy,
    Q1_A_multiple = data$A_multiple,
    Q1_QuitSE_A_efficacy = data$QuitSE * data$A_efficacy,
    Q1_QuitMotiv_A_outcome = data$QuitMotiv * data$A_outcome,
    Q1_LowEducation_A_story = data$LowEducation * data$A_story
  )
}

generate_setting4_data <- function(n, theta, source_data, noise_sd = 1) {
  rows <- sample(seq_len(nrow(source_data)), n, replace = TRUE)
  data <- source_data[rows, , drop = FALSE]
  theta <- theta[setting4_theta_names]
  signal <- as.numeric(setting4_q1_matrix(data) %*% theta[paste0("Q1_", c(
    "intercept", "QuitSE", "QuitMotiv", "LowEducation", "A_source", "A_outcome",
    "A_story", "A_efficacy", "A_multiple", "QuitSE_A_efficacy",
    "QuitMotiv_A_outcome", "LowEducation_A_story"
  ))])
  signal <- signal + as.numeric(setting4_q2_matrix(data) %*% theta[paste0("Q2_", c(
    "intercept", "PQQuit", "PQSE", "PQMotiv", "LowEducation", "A_FF",
    "PQQuit_A_FF", "PQSE_A_FF", "PQMotiv_A_FF", "LowEducation_A_FF"
  ))])
  data$Y <- signal + stats::rnorm(n, 0, noise_sd)
  data$Y_signal <- signal
  data
}
