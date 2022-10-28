#' Chi-Square Goodness-of-Fit Test
#'
#' @description Computes a Chi-Square Goodness-of-Fit Test to determine whether there is statistically significant clustering of observations among dominant profiles in a `cacc_matrix`.
#'
#' @param cacc_matrix A tibble. The output of the `cacc` function.
#'
#' @return Returns a list with the Chi-square results. This is the same object returned by the `chisq.test` function from the `stats` package.
#'
#' @export
#'
#' @references Hart, T. C. (2019). Identifying Situational Clustering and Quantifying Its Magnitude in Dominant Case Configurations: New Methods for Conjunctive Analysis. *Crime & Delinquency, 66*(1), 143-159. https://doi.org/10.1177/0011128719866123
#'
#' @examples
#' cluster_xsq(cacc(onharassment, ivs = sex:privacy, dv = rep_victim))

cluster_xsq <- function (cacc_matrix) {

  # Declare the frequency each dominant profile is observed in the sample
  obs <- cacc_matrix$freq

  # Count the dominant profiles observed
  n_obs <- nrow(x = cacc_matrix)

  # Calculate the expected counts by weighting the sum of dominant observations by the number of dominant profiles observed
  exp <- rep(
    x = sum(obs) / n_obs,
    times = n_obs
  )

  # Conduct the Chi-square test ----
  xsq <- stats::chisq.test(
    x = obs,
    p = exp,
    # `rescale.p = TRUE` because probabilities must sum 1
    rescale.p = TRUE
  )

  # Return the Chi-square results ----
  return (xsq)

}
