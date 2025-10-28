# ==============================================================================
#
# FILE NAME:   simulated_data.R
# DESCRIPTION: Functionality for creating and analyzing a simulated dataset for
#              the student's personal exercise
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2024-10-09
#
# ==============================================================================

## ---- CONSTANTS: -------------------------------------------------------------

# Simulated data objects:

## Response configuration data:
N_DECIMALS <- 2L   # Decimal places to use for rounding numeric results
## TODO: Delete?
# REL_LEVELS <- -1:1 # Levels for the "relationship" item response

## Variable names:
# SIM_VARIABLES <- c("cat_1", "cat_2", "quant_1", "quant_2")
SIM_VARIABLES <- c("cat_1", "cat_2", "quant_1")
SIM_VAR_NAMES <- c(
  "entorno_educ",
  "apoyo_docente",
  "motiv_acad"
  # "motiv_acad",
  # "horas_sueno"
) |>
  setNames(SIM_VARIABLES)

## Variable data:
SAMPLE_SIZE  <- 500:800             # Random sample size of 500-800 cases
CAT_1_LEVELS <-   0:  2 |> factor() # Values in variable `cat_1`
CAT_2_LEVELS <-   0:  1 |> factor() # Values in variable `cat_2`
QUANT_1_VALS <-   0:100             # Values in variable `quant_1`
QUANT_2_VALS <-  60:100 / 10        # Values in `quant_2` (in 0.1 steps)


# Response data objects:

## Model parameters:
## TODO: Review values
INTERCEPT_VAR_NAME    <- "intercept"
SLOPE_VAR_NAME        <- "slope"
RELATIONSHIP_VAR_NAME <- "relationship"

# Response output objects:

## Headers:
## TODO: Review values
ITEM_NUM_LABEL <- "Nº"
ITEM_LABEL     <- "Pregunta"
RESPONSE_LABEL <- "Respuesta"

## Item labels:
## TODO: Review values
INTERCEPT_LABEL    <- "Intersección"
SLOPE_LABEL        <- "Pendiente"
RELATIONSHIP_LABEL <- "Relación"

## Relationship item values:
## TODO: Review values
RELATIONSHIP_LABELS <- c("Inversa", "No tienen relación", "Directa")


## ---- FUNCTIONS: -------------------------------------------------------------

simulate_data <- function(seed) {

  set.seed(seed)

  sample_size <- sample(SAMPLE_SIZE, size = 1L) # Random sample size

  # Cramer's V formula components:
  n_cat_1 <- length(CAT_1_LEVELS)
  n_cat_2 <- length(CAT_2_LEVELS)
  m       <- min(n_cat_1, n_cat_2) - 1L

  # Cramer's V benchmarks: null, small, medium, large, and max effect sizes
  v_eff_lims <- c("null", "small", "medium", "large", "max")
  v_values   <- c(0, 0, .3, .5, .65) |> setNames(v_eff_lims)
  v_eff_levs <- v_eff_lims[-length(v_eff_lims)] # Possible V levels
  v_probs    <- 0.25 |> # Probabilities for effect sizes
    rep(4L)          |>
    setNames(v_eff_levs)

  # Set a random value for Cramer's V:
  v_size  <- sample(v_eff_levs, size = 1L, prob = v_probs)
  v_min   <- v_values[v_size]
  v_max   <- v_values[match(v_size, v_eff_lims) + 1L]
  v_value <- runif(1, v_min, v_max) # Draw a random value in the selected range
  chi_sq  <- v_value^2 * sample_size * m # Compute chi-squared

  # Simulate data from chi-squared value:
  cat_1_probs     <- rep(1 / n_cat_1, n_cat_1) |>
    setNames(CAT_1_LEVELS) # Equal probs for all CAT_1 levels
  cat_joint_probs <- matrix(
    nrow     = n_cat_1,
    ncol     = n_cat_2,
    dimnames = list(CAT_1_LEVELS, CAT_2_LEVELS)
  )
  cat_joint_probs[CAT_1_LEVELS[1], ] <- rep(
    1 / n_cat_2,
    n_cat_2
  ) * cat_1_probs[CAT_1_LEVELS[1]] # First category in `cat_2` is independent


  # (Approximately) compute association table:

  chi_sq_rest <- chi_sq

  # Warning: This algorithm for computing association probabilities works only
  #   when n_cat_2 == 2L
  for (cat_1_level in CAT_1_LEVELS) {

    cat_1_level_prob           <- cat_1_probs[cat_1_level]
    cat_1_lev_joint_theor_prob <- cat_1_level_prob / n_cat_2

    assoc_max <- sqrt(
      chi_sq_rest * cat_1_lev_joint_theor_prob / sample_size / n_cat_2
    )

    cat_joint_probs[cat_1_level, ] <- if (
      cat_1_level == dplyr::last(CAT_1_LEVELS)
    ) {

      1 / n_cat_2 - cat_joint_probs |> colSums(na.rm = TRUE)

    } else {

      # Create an association that explains "at least an 80%" of the remaining
      #   chi-squared value:
      assoc <- runif(1L, assoc_max * .8, assoc_max)

      # Compute the "remaining" chi-squared to explain:
      chi_sq_rest <- chi_sq_rest -
        assoc^2 * sample_size * n_cat_2 / cat_1_lev_joint_theor_prob

      # The following line assumes n_cat_2 == 2L
      assoc * sample(c(-1, 1), size = n_cat_2) + cat_1_lev_joint_theor_prob
    }
  }

  cat_joint_probs <- cat_joint_probs |>
    tibble::as_tibble(rownames = "cat_1") |>
    tidyr::pivot_longer(
      cols      = -cat_1,
      names_to  = "cat_2",
      values_to = "prob"
    )

  # Simulate data with the probabilities that give the desired association
  #   between the categorical variables:
  sim_data <- cat_joint_probs |>
    dplyr::slice_sample(
      n = sample_size,
      replace = TRUE,
      weight_by = prob
    ) |>
    dplyr::select(-prob)

  # Biserial-point correlations:

  bp_corr <- runif(1L, -1, 1)

  cat_2_props <- sim_data |>
    dplyr::group_by(cat_2) |>
    dplyr::summarize(
      cat_2_props = dplyr::n() / sample_size
    )
  cat_2_est_var <- cat_2_props |> dplyr::pull() |> prod() |> sqrt()

  # Get initial estimates of statistics from "equiprobable" values:
  quant_1_sd   <- QUANT_1_VALS |> sd()
  quant_1_mean <- QUANT_1_VALS |> mean()
  mean_diff    <- bp_corr * quant_1_sd / cat_2_est_var

  cat_2_means <- (quant_1_mean + c(-1, 1) * .5 * ceiling(mean_diff)) |>
    setNames(CAT_2_LEVELS) |>
    tibble::enframe(name = "cat_2", value = "mean") |>
    dplyr::mutate(min_mean = min(mean)) |>
    dplyr::group_by(cat_2) |>
    dplyr::mutate(
      min = max(mean - min_mean, min(QUANT_1_VALS)),
      max = min(2 * mean, max(QUANT_1_VALS))
    ) |>
    dplyr::select(-min_mean)

  sim_data <- sim_data |>
    dplyr::left_join(cat_2_means, by = "cat_2") |>
    dplyr::rowwise() |>
    dplyr::mutate(
      quant_1 = sample(
        min:max,
        size = 1L
      )
    ) |>
    dplyr::ungroup() |>
    dplyr::select(-mean, -min, -max)

  sim_data |> setNames(SIM_VAR_NAMES)
}

get_model_params <- function(data) {

  # To compute biserial-point corr:
  # stat <- sim_data |> summarize(sd = sd(quant_1), n = n())
  # stats <- sim_data |> group_by(cat_2) |> summarize(mean_q = mean(quant_1), n_cat = n()) |> bind_cols(stat) |> mutate(prop = n_cat / n)
  # means <- stats |> pull(mean_q)
  # props <- stats |> pull(prop)
  # diff <- means[2] - means[1]
  # diff / ((stat |> pull(sd)) * sqrt(props[1] * props[2]))

  responses |>
    dplyr::mutate(relationship = slope |> sign() |> factor(levels = REL_LEVELS))
}

get_user_responses <- function(hash) {

  user_sim_data <- simulate_data(hash)

  user_sim_data |> get_model_params()
}

format_responses <- function(responses) {

  relationship_levels <- REL_LEVELS |>
    as.character() |>
    setNames(RELATIONSHIP_LABELS)

  params_varnames    <- c(
    INTERCEPT_VAR_NAME,
    SLOPE_VAR_NAME,
    RELATIONSHIP_VAR_NAME
  )
  params_labels      <- c(INTERCEPT_LABEL, SLOPE_LABEL, RELATIONSHIP_LABEL)
  params_vars_labels <- params_varnames |>
    setNames(params_labels) |>
    tibble::enframe(name = ITEM_LABEL)

  responses |>
    dplyr::mutate(
      relationship = relationship |>
        forcats::fct_recode(!!!relationship_levels),
      dplyr::across(dplyr::everything(), as.character)
    ) |>
    tidyr::pivot_longer(
      cols      = dplyr::everything(),
      values_to = RESPONSE_LABEL
    ) |>
    dplyr::full_join(params_vars_labels, by = c(name = "value")) |>
    dplyr::select(dplyr::all_of(c(ITEM_LABEL, RESPONSE_LABEL))) |>
    tibble::rownames_to_column(ITEM_NUM_LABEL)
}
