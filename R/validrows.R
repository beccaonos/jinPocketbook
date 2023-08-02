#' Check for Valid Rows in the Chart Data
#'
#' This internal function checks for valid rows in the chart data based on non-missing values in the "data" field.
#'
#' @param data A list representing the chart data.
#'
#' @return A logical vector indicating whether each row in the chart data is valid (TRUE) or not (FALSE).
#'
#' @examples
#' # This function is not intended to be called directly by the user.

validrows <- function(data) {

  # Check if the "data" field in each row of the chart data is non-missing
  valid <- sapply(data, function(x) !is.null(x$data))

  return(valid)
}
