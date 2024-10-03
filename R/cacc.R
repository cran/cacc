#' Conjunctive Analysis of Case Configurations
#'
#' @description Computes a Conjunctive Analysis of Case Configurations (CACC).
#'
#' @param data A data frame or a tibble.
#' @param ivs A vector of names of the independent variables, without quotes. Variables must be categorical, either integer, character, or factor.
#' @param dv Name of the dependent variable, without quotes. Variable must be a dichotomous integer or factor with values 0 (absence) and 1 (presence).
#'
#' @return Returns a tibble with the CACC matrix.
#'
#' @importFrom rlang .data
#' @export
#'
#' @references Miethe, T. D., Hart, T. C., & Regoeczi, W. C. (2008). The Conjunctive Analysis of Case Configurations: An Exploratory Method for Discrete Multivariate Analyses of Crime Data. *Journal of Quantitative Criminology, 24*, 227–241. https://doi.org/10.1007/s10940-008-9044-8
#'
#' @examples
#' cacc(
#'   data = onharassment,
#'   ivs = c(sex, age, hours, snapchat, instagram, facebook, twitter, name, photos, privacy),
#'   dv = rep_victim
#')
#' cacc(onharassment, ivs = sex:privacy, dv = rep_victim)
#'
#' # Syntax with the native R pipe
#' onharassment |> cacc(ivs = sex:privacy, dv = rep_victim)

cacc <- function (data, ivs, dv) {

  # Generate the CACC matrix ----
  # Count all profiles
  matrix_total <- data |>
    dplyr::group_by(dplyr::across({{ ivs }})) |>
    dplyr::count() |>
    dplyr::ungroup() |>
    dplyr::arrange(dplyr::desc(.data$n)) |>
    dplyr::rename(freq_total = "n")

  # Count profiles associated with presence of the DV
  matrix_one <- data |>
    dplyr::filter({{ dv }} == 1) |>
    dplyr::group_by(dplyr::across({{ ivs }})) |>
    dplyr::count() |>
    dplyr::ungroup() |>
    dplyr::arrange(dplyr::desc(.data$n)) |>
    dplyr::rename(freq_one = "n")

  # Calculate the probabilities of occurrence for each dominant profile ----
  # Merge both data frames
  cacc_matrix <- dplyr::full_join(
    matrix_total,
    matrix_one
  ) |>
    # Calculate probabilities of ocurrence for each profile
    dplyr::mutate(p = .data$freq_one / .data$freq_total) |>
    # Filter by dominant profiles
    # Determine the threshold for dominant profiles based on sample size
    dplyr::filter(.data$freq_total >= dplyr::if_else(
      condition = nrow(data) < 1000,
      true = 5,
      false = 10
    )) |>
    dplyr::arrange(dplyr::desc(.data$p)) |>
    dplyr::select(- .data$freq_one) |>
    dplyr::rename(freq = "freq_total") |>
    dplyr::mutate(p = tidyr::replace_na(.data$p, 0))

  # Return the CACC matrix ----
  return (cacc_matrix)

}
