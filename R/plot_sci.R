#' Lorenz Curve for the Situational Clustering Index
#'
#' @description Plots a Lorenz Curve for the Situational Clustering Index (SCI) to visualize the magnitude of the clustering of observations among dominant profiles in a `cacc_matrix`.
#'
#' @param cacc_matrix A tibble. The output of the `cacc` function.
#'
#' @return Returns a ggplot object.
#'
#' @export
#'
#' @references Hart, T. C. (2019). Identifying Situational Clustering and Quantifying Its Magnitude in Dominant Case Configurations: New Methods for Conjunctive Analysis. *Crime & Delinquency, 66*(1), 143-159.
#'
#' @examples
#' plot_sci(cacc_matrix = cacc(onharassment, ivs = sex:privacy, dv = rep_victim))

plot_sci <- function (cacc_matrix) {

  # Prepare the data frame ----
  cacc_matrix <- cacc_matrix |>
    # Rank the dominant profiles in the CACC matrix from more to less frequent
    dplyr::arrange(dplyr::desc(.data$freq)) |>
    # Insert a new row with the total `freq`
    tibble::add_row(
      freq = sum(cacc_matrix |> dplyr::pull(.data$freq)),
      .before = 1
    ) |>
    dplyr::mutate(
      freq_max = dplyr::lag(dplyr::if_else(
        condition = .data$freq == max(.data$freq),
        true = .data$freq,
        false = as.integer(0)
      )),
      freq_dif = .data$freq_max - .data$freq,
      freq_dif = tidyr::replace_na(.data$freq_dif, 0),
      freq_cum = abs(cumsum(.data$freq_dif) - dplyr::lead(.data$freq_max, default = 0)),
      prop_cum = .data$freq_cum / max(.data$freq),
      n_config = (dplyr::n():1) - 1,
      prop_config = .data$n_config / max(.data$n_config),
      # Calculate the area under the curve
      auc = (.data$prop_cum + dplyr::lead(.data$prop_cum, default = 0)) / 2 * (1 / max(.data$n_config))
    )

  # Plot the Lorenz curve ----
  plot_lorenz <- cacc_matrix |>
    ggplot2::ggplot(mapping = ggplot2::aes(
      x = .data$prop_config,
      y = .data$prop_cum
    )) +
    ggplot2::geom_area() +
    ggplot2::geom_abline() +
    ggplot2::annotate(
      geom = "text",
      x = min(cacc_matrix$prop_config) + 0.1,
      y = max(cacc_matrix$prop_cum) - 0.1,
      label = paste("SCI = ", round(
        x = 1 - (2 * sum(cacc_matrix$auc)),
        digits = 3
      ))
    ) +
    ggplot2::labs(
      x = "Proportion of observations",
      y = "Proportion of dominant profiles"
    )

  return (plot_lorenz)

}
