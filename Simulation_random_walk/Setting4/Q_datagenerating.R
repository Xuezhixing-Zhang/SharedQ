setting4_repo_root <- "/data/cheungyb/home/e1404425/SharedQ"
setting4_dir <- Sys.getenv(
  "SETTING4_DIR",
  unset = file.path(setting4_repo_root, "Simulation_random_walk", "Setting4")
)
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

setting4_base_theta <- c(
  Q2_intercept = 0.10,
  Q2_PQQuit = 0.40,
  Q2_PQSE = 0,
  Q2_PQMotiv = 0,
  Q2_LowEducation = 0,
  Q2_A_FF = 0.12,
  Q2_PQQuit_A_FF = -0.08,
  Q2_PQSE_A_FF = 0,
  Q2_PQMotiv_A_FF = 0,
  Q2_LowEducation_A_FF = 0,
  Q1_intercept = 0.10,
  Q1_QuitSE = 0,
  Q1_QuitMotiv = 0,
  Q1_LowEducation = 0,
  Q1_A_source = 0.20,
  Q1_A_outcome = 0.08,
  Q1_A_story = 0.18,
  Q1_A_efficacy = 0.08,
  Q1_A_multiple = 0.02,
  Q1_QuitSE_A_efficacy = 0,
  Q1_QuitMotiv_A_outcome = 0,
  Q1_LowEducation_A_story = 0
)

setting4_shared_parameter_specs <- list(
  pqff_shared_parsimonious = list(
    seed = 601,
    shared_mu = c(0.35, 0.24, -0.08, 0.16, 0.14, 0.18),
    shared_sigma = c(0.04, 0.03, 0.02, 0.03, 0.03, 0.04)
  ),
  pqff_shared_tight = list(
    seed = 602,
    shared_mu = c(0.35, 0.24, -0.08, 0.16, 0.14, 0.18),
    shared_sigma = c(0.02, 0.015, 0.01, 0.015, 0.015, 0.02)
  ),
  pqff_shared_wide = list(
    seed = 603,
    shared_mu = c(0.35, 0.24, -0.08, 0.16, 0.14, 0.18),
    shared_sigma = c(0.08, 0.06, 0.04, 0.06, 0.06, 0.08)
  )
)

setting4_separated_parameter_specs <- list(
  pqff_separated_parsimonious = c(
    Q2_PQSE = 0.55,
    Q1_QuitSE = -0.05,
    Q2_PQMotiv = -0.15,
    Q1_QuitMotiv = 0.45,
    Q2_LowEducation = 0.30,
    Q1_LowEducation = -0.25,
    Q2_PQSE_A_FF = 0.45,
    Q1_QuitSE_A_efficacy = -0.25,
    Q2_PQMotiv_A_FF = -0.30,
    Q1_QuitMotiv_A_outcome = 0.32,
    Q2_LowEducation_A_FF = 0.50,
    Q1_LowEducation_A_story = -0.20
  ),
  pqff_separated_reversed = c(
    Q2_PQSE = -0.35,
    Q1_QuitSE = 0.50,
    Q2_PQMotiv = 0.40,
    Q1_QuitMotiv = -0.20,
    Q2_LowEducation = -0.30,
    Q1_LowEducation = 0.25,
    Q2_PQSE_A_FF = -0.40,
    Q1_QuitSE_A_efficacy = 0.30,
    Q2_PQMotiv_A_FF = 0.36,
    Q1_QuitMotiv_A_outcome = -0.26,
    Q2_LowEducation_A_FF = -0.42,
    Q1_LowEducation_A_story = 0.28
  ),
  pqff_separated_large = c(
    Q2_PQSE = 0.75,
    Q1_QuitSE = -0.25,
    Q2_PQMotiv = -0.35,
    Q1_QuitMotiv = 0.65,
    Q2_LowEducation = 0.50,
    Q1_LowEducation = -0.45,
    Q2_PQSE_A_FF = 0.65,
    Q1_QuitSE_A_efficacy = -0.45,
    Q2_PQMotiv_A_FF = -0.50,
    Q1_QuitMotiv_A_outcome = 0.52,
    Q2_LowEducation_A_FF = 0.72,
    Q1_LowEducation_A_story = -0.40
  )
)

setting4_default_design <- list(
  source_file = "Simulation_random_walk/Setting4/source_data/cleaned_data.05.21.csv",
  raw_rows = 1848,
  raw_columns = 29,
  consent_rows = 479,
  complete_consent_rows = 469,
  stage1_arms = 16,
  p_quit_se = 0.515991,
  p_quit_motiv = 0.486141,
  p_low_education = 1 - 0.716418,
  p_pq_quit = 0.313433,
  p_pq_se = 0.582090,
  p_pq_motiv = 0.558635,
  p_a_ff_positive = 312 / 469
)

setting4_shared_pairs <- function() {
  rbind(
    c("Q2_PQSE", "Q1_QuitSE"),
    c("Q2_PQMotiv", "Q1_QuitMotiv"),
    c("Q2_LowEducation", "Q1_LowEducation"),
    c("Q2_PQSE_A_FF", "Q1_QuitSE_A_efficacy"),
    c("Q2_PQMotiv_A_FF", "Q1_QuitMotiv_A_outcome"),
    c("Q2_LowEducation_A_FF", "Q1_LowEducation_A_story")
  )
}

setting4_shared_target_values <- function(spec_def) {
  set.seed(spec_def$seed)
  values <- unlist(lapply(seq_along(spec_def$shared_mu), function(i) {
    stats::rnorm(2, spec_def$shared_mu[i], spec_def$shared_sigma[i])
  }), use.names = FALSE)
  names(values) <- as.vector(t(setting4_shared_pairs()))
  values
}

setting4_target_theta <- function(spec = "pqff_shared_parsimonious") {
  theta <- setting4_base_theta
  if (spec %in% names(setting4_shared_parameter_specs)) {
    theta[names(setting4_shared_target_values(setting4_shared_parameter_specs[[spec]]))] <-
      setting4_shared_target_values(setting4_shared_parameter_specs[[spec]])
  } else if (spec %in% names(setting4_separated_parameter_specs)) {
    theta[names(setting4_separated_parameter_specs[[spec]])] <-
      setting4_separated_parameter_specs[[spec]]
  } else {
    stop("Unsupported Setting IV spec: ", spec)
  }
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

generate_synthetic_setting4_source <- function(n, seed = NULL, design = setting4_default_design) {
  if (!is.null(seed)) set.seed(seed)
  arms <- setting4_fractional_factorial_arms()
  arm_idx <- sample(seq_len(nrow(arms)), n, replace = TRUE)
  arm_data <- arms[arm_idx, , drop = FALSE]

  QuitSE <- stats::rbinom(n, 1, design$p_quit_se)
  QuitMotiv <- stats::rbinom(n, 1, design$p_quit_motiv)
  LowEducation <- stats::rbinom(n, 1, design$p_low_education)
  PQQuit <- stats::rbinom(n, 1, design$p_pq_quit)
  PQSE <- stats::rbinom(n, 1, design$p_pq_se)
  PQMotiv <- stats::rbinom(n, 1, design$p_pq_motiv)
  A_FF <- ifelse(stats::rbinom(n, 1, design$p_a_ff_positive) == 1L, 1L, -1L)

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
    source_mode = "synthetic_parametric",
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

generate_setting4_data <- function(n, theta, noise_sd = 1, seed = NULL, design = setting4_default_design) {
  data <- generate_synthetic_setting4_source(n, seed = seed, design = design)
  theta <- theta[setting4_theta_names]
  q1_signal <- as.numeric(setting4_q1_matrix(data) %*% theta[paste0("Q1_", c(
    "intercept", "QuitSE", "QuitMotiv", "LowEducation", "A_source", "A_outcome",
    "A_story", "A_efficacy", "A_multiple", "QuitSE_A_efficacy",
    "QuitMotiv_A_outcome", "LowEducation_A_story"
  ))])
  q2_signal <- as.numeric(setting4_q2_matrix(data) %*% theta[paste0("Q2_", c(
    "intercept", "PQQuit", "PQSE", "PQMotiv", "LowEducation", "A_FF",
    "PQQuit_A_FF", "PQSE_A_FF", "PQMotiv_A_FF", "LowEducation_A_FF"
  ))])
  component_sd <- noise_sd / sqrt(2)
  data$Y_PQ <- q1_signal + stats::rnorm(n, 0, component_sd)
  data$Y_FF <- q2_signal + stats::rnorm(n, 0, component_sd)
  data$Y <- data$Y_PQ + data$Y_FF
  data$Y_PQ_signal <- q1_signal
  data$Y_FF_signal <- q2_signal
  data$Y_signal <- q1_signal + q2_signal
  data
}
