source("/data/cheungyb/home/e1404425/SharedQ/Simulation_random_walk/Setting4/Q_datagenerating.R")

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

coef_or_zero <- function(fit, names_out) {
  coefs <- stats::coef(fit)
  coefs[!is.finite(coefs)] <- 0
  out <- stats::setNames(rep(0, length(names_out)), names_out)
  common <- intersect(names(out), names(coefs))
  out[common] <- coefs[common]
  out
}

q2_treatment_score <- function(data, theta) {
  theta["Q2_A_FF"] +
    data$PQQuit * theta["Q2_PQQuit_A_FF"] +
    data$PQSE * theta["Q2_PQSE_A_FF"] +
    data$PQMotiv * theta["Q2_PQMotiv_A_FF"] +
    data$LowEducation * theta["Q2_LowEducation_A_FF"]
}

q1_arm_score <- function(data, theta, arm) {
  arm$A_source * theta["Q1_A_source"] +
    arm$A_outcome * (theta["Q1_A_outcome"] + data$QuitMotiv * theta["Q1_QuitMotiv_A_outcome"]) +
    arm$A_story * (theta["Q1_A_story"] + data$LowEducation * theta["Q1_LowEducation_A_story"]) +
    arm$A_efficacy * (theta["Q1_A_efficacy"] + data$QuitSE * theta["Q1_QuitSE_A_efficacy"]) +
    arm$A_multiple * theta["Q1_A_multiple"]
}

setting4_policy <- function(data, theta, arms = setting4_fractional_factorial_arms()) {
  theta <- theta[setting4_theta_names]
  scores <- vapply(seq_len(nrow(arms)), function(i) q1_arm_score(data, theta, arms[i, ]), numeric(nrow(data)))
  best <- max.col(scores, ties.method = "first")
  best_arms <- arms[best, , drop = FALSE]
  rownames(best_arms) <- NULL
  list(
    A_source = best_arms$A_source,
    A_outcome = best_arms$A_outcome,
    A_story = best_arms$A_story,
    A_efficacy = best_arms$A_efficacy,
    A_multiple = best_arms$A_multiple,
    A_FF = ifelse(q2_treatment_score(data, theta) >= 0, 1L, -1L)
  )
}

fit_setting4_q <- function(data, arms = setting4_fractional_factorial_arms()) {
  q2_outcome <- if ("Y_FF" %in% names(data)) data$Y_FF else data$Y
  q2_data <- data
  q2_data$Q2_outcome <- q2_outcome
  q2_fit <- stats::lm(
    Q2_outcome ~ PQQuit + PQSE + PQMotiv + LowEducation + A_FF +
      PQQuit:A_FF + PQSE:A_FF + PQMotiv:A_FF + LowEducation:A_FF,
    data = q2_data
  )
  q2_names <- c(
    "(Intercept)", "PQQuit", "PQSE", "PQMotiv", "LowEducation", "A_FF",
    "PQQuit:A_FF", "PQSE:A_FF", "PQMotiv:A_FF", "LowEducation:A_FF"
  )
  q2_theta <- coef_or_zero(q2_fit, q2_names)
  names(q2_theta) <- setting4_theta_names[1:10]

  theta_partial <- stats::setNames(rep(0, length(setting4_theta_names)), setting4_theta_names)
  theta_partial[1:10] <- q2_theta
  real_a2 <- data$A_FF * q2_treatment_score(data, theta_partial)
  max_a2 <- abs(q2_treatment_score(data, theta_partial))
  y_opt_q2 <- data$Y - real_a2 + max_a2

  q1_data <- data
  q1_data$Y_opt_q2 <- y_opt_q2
  q1_fit <- stats::lm(
    Y_opt_q2 ~ QuitSE + QuitMotiv + LowEducation + A_source + A_outcome +
      A_story + A_efficacy + A_multiple + QuitSE:A_efficacy +
      QuitMotiv:A_outcome + LowEducation:A_story,
    data = q1_data
  )
  q1_names <- c(
    "(Intercept)", "QuitSE", "QuitMotiv", "LowEducation", "A_source", "A_outcome",
    "A_story", "A_efficacy", "A_multiple", "QuitSE:A_efficacy",
    "QuitMotiv:A_outcome", "LowEducation:A_story"
  )
  q1_theta <- coef_or_zero(q1_fit, q1_names)
  names(q1_theta) <- setting4_theta_names[11:22]

  theta <- c(q2_theta, q1_theta)
  names(theta) <- setting4_theta_names
  policy <- setting4_policy(data, theta, arms = arms)
  list(theta = theta, Q2_fit = q2_fit, Q1_fit = q1_fit, policy = policy)
}

apply_setting4_fusion <- function(theta, type = c("shared", "l1", "l2"), lambda = 0.10) {
  type <- match.arg(type)
  out <- theta
  pairs <- setting4_shared_pairs()
  for (i in seq_len(nrow(pairs))) {
    a <- pairs[i, 1]
    b <- pairs[i, 2]
    mean_ab <- mean(theta[c(a, b)])
    diff_ab <- theta[a] - theta[b]
    if (identical(type, "shared")) {
      out[c(a, b)] <- mean_ab
    } else if (identical(type, "l1")) {
      shrunk_diff <- sign(diff_ab) * max(abs(diff_ab) - 2 * lambda, 0)
      out[a] <- mean_ab + shrunk_diff / 2
      out[b] <- mean_ab - shrunk_diff / 2
    } else {
      shrunk_diff <- diff_ab / (1 + 2 * lambda)
      out[a] <- mean_ab + shrunk_diff / 2
      out[b] <- mean_ab - shrunk_diff / 2
    }
  }
  out
}
setting4_result_from_theta <- function(data, theta, method, arms = setting4_fractional_factorial_arms()) {
  list(theta = theta, method = method, policy = setting4_policy(data, theta, arms = arms))
}

evaluate_setting4 <- function(results, theta_true, data_original, arms = setting4_fractional_factorial_arms()) {
  true_policy <- setting4_policy(data_original, theta_true, arms = arms)
  est_policy <- results$policy
  action_names <- c("A_source", "A_outcome", "A_story", "A_efficacy", "A_multiple", "A_FF")
  action_matches <- vapply(action_names, function(a) est_policy[[a]] == true_policy[[a]], logical(nrow(data_original)))
  theta <- results$theta[setting4_theta_names]
  theta_true <- theta_true[setting4_theta_names]
  bias <- theta - theta_true

  out <- list(
    M = mean(rowSums(action_matches) == length(action_names)),
    M_weighted = mean(action_matches),
    A_source_match = mean(action_matches[, "A_source"]),
    A_outcome_match = mean(action_matches[, "A_outcome"]),
    A_story_match = mean(action_matches[, "A_story"]),
    A_efficacy_match = mean(action_matches[, "A_efficacy"]),
    A_multiple_match = mean(action_matches[, "A_multiple"]),
    A_FF_match = mean(action_matches[, "A_FF"])
  )
  for (nm in names(bias)) {
    out[[paste0(nm, "_bias")]] <- unname(bias[[nm]])
  }
  out
}
