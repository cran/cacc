#' Density Plot for the Main Effect
#'
#' @description Plots an annotated boxplot and kernel density estimate to visualize the distribution of the main effect that a specific value of a variable produces on the outcome probability in a `cacc_matrix`.
#'
#' @param cacc_matrix A tibble. The output of the `cacc` function.
#' @param iv A single variable name contained in a `cacc_matrix`.
#' @param value A single numeric or character value the `iv` specified can take.
#'
#' @return Returns a ggplot object.
#'
#' @importFrom rlang :=
#' @export
#'
#' @references Hart, T. C., Rennison, C. M., & Miethe, T. D. (2017). Identifying Patterns of Situational Clustering and Contextual Variability in Criminological Data: An Overview of Conjunctive Analysis of  Case  Configurations. *Journal  of  Contemporary Criminal  Justice, 33*(2),  112–120. https://doi.org/10.1177/1043986216689746
#'
#' @examples
#' plot_effect(
#'   cacc_matrix = cacc(onharassment, ivs = sex:privacy, dv = rep_victim),
#'   iv = age,
#'   value = "15-17"
#')

plot_effect <- function (cacc_matrix, iv, value) {

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
      {{ iv }} := dplyr::if_else(
        condition = {{ iv }} == value,
        true = .data$p - .data$pre_effect,
        false = NA_real_,
      )
    ) |>
    dplyr::ungroup() |>
    tidyr::drop_na()

  # Plot the main effect ----

  # Declare the summary stats
  summary_stats <- cacc_effect |>
    dplyr::summarise(
      mean = round(x = mean({{ iv }}), digits = 3),
      sd = round(x = stats::sd({{ iv }}), digits = 3)
    )

  # Produce a distribution plot
  cacc_effect |>
    ggplot2::ggplot(mapping = ggplot2::aes(x = {{ iv }})) +
    ggplot2::geom_density(
      fill = "grey",
      alpha = .5
    ) +
    ggplot2::geom_boxplot() +
    ggplot2::geom_vline(
      xintercept = 0,
      linetype = 2
    ) +
    ggplot2::scale_y_discrete() +
    # Add an annotation layer to the plot with the summary stats
    ggplot2::annotate(
      geom = "text",
      x = c(-Inf, -Inf),
      y = c(Inf, Inf),
      hjust = c(0, 0),
      vjust = c(1.5, 3.5),
      label = c(
        paste("italic(M) ==", summary_stats |> dplyr::pull(.data$mean)),
        paste("italic(SD) ==", summary_stats |> dplyr::pull(.data$sd))
      ),
      parse = TRUE
    ) +
    ggplot2::labs(
      x = "Main effect",
      y = paste0(rlang::as_label(rlang::enquo(iv)), "; ", rlang::as_label(rlang::enquo(value)))
    )

}
