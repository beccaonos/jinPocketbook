#' Check for Valid Rows in the Chart Data
#'
#' This internal function checks for valid rows in the chart data
#'

validrows <- function (element) {

  !sapply(element,is.null)

  }
