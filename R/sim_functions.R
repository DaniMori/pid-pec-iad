# ==============================================================================
#
# FILE NAME:   sim_functions.R
# DESCRIPTION: Functionality for data simulation
#
# AUTHOR:      Daniel Morillo
#
# DATE:        2026-09-17
#
# ==============================================================================


## ---- GLOBAL OPTIONS: --------------------------------------------------------

## ---- CONSTANTS: -------------------------------------------------------------

# <level_1_section>:

## <level_2_section>:


## ---- FUNCTIONS: -------------------------------------------------------------

generate_sample_size <- function(min, max) {

  sample(min:max, size = 1L)
}

generate_category_proportions <- function(categories, min_prop = 0) {

  n_categories <- categories |> length()
  n_props      <- min_prop   |> length()

  if (!n_props %in% c(1L, n_categories)) {

    stop("`min_prop` must have length 1 or equal to `categories`.")
  }
  if (any(min_prop > 1/n_categories)) {

    stop("`min_prop` values must be at most 1 / 'nº of categories'.")
  }

  # Tranform "minimal proportions" into the minimal pre-normalized values:
  # min_prop = min_non_norm / (min_non_norm + n_categories - 1)
  min_non_norm <- (n_categories - 1) / (1 / min_prop - 1)

  rel_props <- n_categories |> runif(min = min_non_norm)
  props     <- rel_props / sum(rel_props) # Normalize

  props |> setNames(categories) # Returned value
}

quantitative_2_categorical <- function(variable, proportions, ordinal = TRUE) {

  if (proportions |> names() |> is.null()) {

    stop("`proportions` must have the category labels as names.")
  }

  # Transform prooprtions into the "cumulative proportions" to compute quantiles
  cut_props <- proportions |> cumsum() # TODO: Check that are normalized
  cut_props <- c(0, cut_props) # Extra "cutpoint" needed by `quantile()`

  variable |> cut(   # Quantiles for the cutoff points:
    breaks         = variable |> quantile(cut_props, names = FALSE),
    labels         = proportions |> names(),
    include.lowest = TRUE,
    ordered_result = ordinal
  )
}

round_quant_2_set <- function(variable, values) {

  closest <- variable |>
    purrr::map(~ values[which.min(abs(. - values))]) |>
    unlist()

  if (is.integer(values)) closest <- closest |> as.integer()

  closest
}

generate_correlation <- function(min = -1, max = 1) {

  # Do not generate if both limits are `NA`:
  if (is.na(min) && is.na(max)) return(NA_real_)

  if (is.na(min)) min <- -1
  if (is.na(max)) max <-  1

  runif(n = 1L, min = min, max = max)
}

complete_correlation <- function(corr_matrix, row, col, min = -1, max = 1) {

  if (is.na(min)) min <- -1
  if (is.na(max)) max <-  1

  corr_limits <- corr_matrix |> pos_def_limits(row, col)

  min <- max(min, corr_limits$min)
  max <- min(max, corr_limits$max)

  if (min > max) { # Limits incompatible with earlier correlations

    stop(
      glue::glue(
        "Limits in [{row}, {col}] do not yield positive definite matrix."
      )
    )
  }

  corr_matrix[row, col] <- generate_correlation(min, max)
  corr_matrix[col, row] <- corr_matrix[row, col]

  corr_matrix
}

pos_def_limits <- function(corrs, row, col) {

  if (row == 1L) return(list(min = -1, max = 1))

  # Exact interval for [row, col] that keeps [1:row, col] positive-definite;
  #   assumes [1:row, 1:row] is positive-definite and [1:(row-1), col] already
  #   filled.
  #   NOTE: I do not fully understand this algorithm; it is recommended by
  #   and adapted from Claude:
  #   https://claude.ai/share/920ba62d-3807-4ef6-b7dc-e19fe8c4f9fa

  complete_corrs <- corrs[1:row, 1:row]
  comp_inv_corrs <- complete_corrs |> solve()
  variable_corrs <- corrs[seq_len(row - 1L), col]

  beta  <- sum(comp_inv_corrs[row, -row, drop = FALSE] * variable_corrs)
  gamma <- drop(
    crossprod(
      variable_corrs,
      comp_inv_corrs[-row, -row, drop = FALSE] %*% variable_corrs
    )
  ) - 1
  disc  <- beta^2 - comp_inv_corrs[row, row] * gamma

  list(
    min = (-beta - sqrt(disc)) / comp_inv_corrs[row, row],
    max = (-beta + sqrt(disc)) / comp_inv_corrs[row, row]
  )
}

is_pos_def <- function(corr_matrix, tol = 1e-8) {

  eigendecomposition <- eigen(corr_matrix, symmetric = TRUE, only.values = TRUE)
  all(eigendecomposition$values > tol)
}

generate_corr_matrix <- function(min       = NA_real_,
                                 max       = NA_real_,
                                 max_tries = 1000L) {

  if (identical(min, NA_real_) & identical(max, NA_real_)) {

    stop("At least one of `min` or `max` must be defined.")
  }
  ## TODO: Review and add additional defensive clauses

  # TODO: Make sure `min` and `max` have the same dimensions
  dim_corr <- dim(min)[1] # TODO: Make sure `min` and `max` are square matrices
  names    <- dimnames(min) # TODO: Check & corrrect name assignment

  for (iteration in 1:max_tries) {

    # Create result correlation matrix "template"
    result           <- diag(dim_corr)
    dimnames(result) <- names

    # Generate correlations with defined limits
    tryCatch(
      for (col in 2:dim_corr) {

        for (row in 1:(col - 1L)) {

          result <- result |>
            complete_correlation(row, col, min[row, col], max[row, col])
        }
      },
      error = \(e) message(geterrmessage())
    )
    if (is_pos_def(result)) return(result)

    warning(
      glue::glue(
        "Matrix generated in iteration {iteration} was not positive-definite."
      )
    )
  }

  stop(
    glue::glue(
      "Could not generate a correlation matrix after {max_tries} tries."
    )
  )
}
