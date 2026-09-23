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

get_missing_corrs <- function(corr_matrix) {

  missing_corrs <- which(is.na(corr_matrix), arr.ind = TRUE, useNames = FALSE)
  dimnames(missing_corrs) <- list(character(0), c("row", "col")) # Name columns

  # Return only the upper triangle:
  missing_corrs[missing_corrs[, 1] < missing_corrs[, 2], ]
}

upper_left_corner <- function(matrix, max_row, max_col) {

  matrix[1:max_row, 1:max_col]
}

complete_corr <- function(corr_matrix, row, col) {

  corrs_part  <- corr_matrix |> upper_left_corner(row, col)
  corrs       <- corrs_part[upper.tri(corrs_part)]
  corr_limits <- faux::pos_def_limits(corrs)

  corr_matrix[row, col] <- generate_correlation(
    corr_limits$min,
    corr_limits$max
  )

  corr_matrix
}

complete_corrs <- function(corr_matrix) {

  missing_corrs <- get_missing_corrs(corr_matrix)

  for (index in 1:nrow(missing_corrs)) {

    index_1 <- missing_corrs[index, 1]
    index_2 <- missing_corrs[index, 2]

    corr_matrix <- corr_matrix |> complete_corr(index_1, index_2)
  }

  corr_matrix
}

complete_lower_tri_corrs <- function(corr_matrix) {

  corr_vector                         <- corr_matrix[upper.tri(corr_matrix)]
  corr_matrix                         <- t(corr_matrix)
  corr_matrix[upper.tri(corr_matrix)] <- corr_vector

  corr_matrix
}

generate_corr_matrix <- function(min = NA_real_, max = NA_real_) {

  if (identical(min, NA_real_) & identical(max, NA_real_)) {

    stop("At least one of `min` or `max` must be defined.")
  }
  ## TODO: Review and add additional defensive clauses

  # TODO: Make sure `min` and `max` have the same dimensions
  dim_corr <- dim(min)[1] # TODO: Make sure `min` and `max` are square matrices
  names    <- dimnames(min) # TODO: Check & corrrect name assignment

  # Create result correlation matrix "template"
  result       <- matrix(nrow = dim_corr, ncol = dim_corr, dimnames = names)
  diag(result) <- 1L

  # Generate correlations with defined limits
  result[upper.tri(result)] <- purrr::map2_dbl(
    min[upper.tri(min)],
    max[upper.tri(max)],
    generate_correlation
  )

  # Complete correlation matrix with non-restricted correlations
  result |>
    complete_corrs() |>
    complete_lower_tri_corrs() # Complete lower triangle
}

## ---- MAIN: ------------------------------------------------------------------

## ----<chunk-name>----------------------------------------


