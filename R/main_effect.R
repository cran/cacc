#' Main effect
#'
#' @description Computes the main effect that a specific value of a variable produces on the outcome probability in a `cacc_matrix`.
#'
#' @param cacc_matrix A tibble. The output of the `cacc` function.
#' @param iv A single variable name contained in a `cacc_matrix`.
#' @param value A single numeric or character value the `iv` specified can take.
#' @param summary Logical. Defaults to `TRUE`. Whether or not to return the summary statistics for the main effect.
#'
#' @return When `summary = TRUE`, returns a tibble with summary stats for the main effect. If `summary = FALSE`, returns a tibble containing a single numeric variable, ranging from 0 to 1, containing the main effects of the `value` of the selected `iv` on the probability of outcome.
#'
#' @export
#'
#' @references Hart, T. C., Rennison, C. M., & Miethe, T. D. (2017). Identifying Patterns of Situational Clustering and Contextual Variability in Criminological Data: An Overview of Conjunctive Analysis of  Case  Configurations. *Journal  of  Contemporary Criminal  Justice, 33*(2),  112–120. https://doi.org/10.1177/1043986216689746
#'
#' @examples
#' main_effect(
#'   cacc_matrix = cacc(onharassment, ivs = sex:privacy, dv = rep_victim),
#'   iv = age,
#'   value = "15-17"
#')
#' main_effect(
#'   cacc_matrix = cacc(onharassment, ivs = sex:privacy, dv = rep_victim),
#'   iv = age,
#'   value = "15-17",
#'   summary = FALSE
#')

main_effect <- function (cacc_matrix, iv, value, summary = TRUE) {

  # Calculate the main effect ----
  cacc_effect <- cacc_matrix |>
    dplyr::group_by(dplyr::across(-c({{ iv }}, .data$freq, .data$p))) |>
    dplyr::filter(dplyr::n() > 1) |>
    dplyr::arrange({{ iv }}, .by_group = TRUE) |>
    dplyr::mutate(
      pre_effect = mean(stats::na.omit(dplyr::if_else(
        condition = {{ iv }} == value,
        true = NA_real_,
        false = .data$p
      ))),
      effect = dplyr::if_else(
        condition = {{ iv }} == value,
        true = .data$p - .data$pre_effect,
        false = NA_real_,
      )
    ) |>
    dplyr::ungroup() |>
    tidyr::drop_na()

  # Return summary statistics for main effects ----
  if ({{ summary }} == TRUE) {

    return (
      cacc_effect |>
        dplyr::summarise(
          median = round(x = stats::median(.data$effect), digits = 3),
          mean = round(x = mean(.data$effect), digits = 3),
          sd = round(x = stats::sd(.data$effect), digits = 3),
          min = round(x = min(.data$effect), digits = 3),
          max = round(x = max(.data$effect), digits = 3)
        )
    )

  } else {

    return (cacc_effect |> dplyr::select(.data$effect))

  }

}
