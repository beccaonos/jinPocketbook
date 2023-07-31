one_column <- function() {

  block_section(
  prop_section(
    type = "nextPage"
  )
)

}

two_columns <- function() {

  block_section(
  prop_section(
    type = "continuous",
    section_columns = section_columns(widths = c(1.88, 1.88), space = 0.5, sep = FALSE)
  )
)

}

second_column <- function() {

  block_section(
  prop_section(
    type = "nextColumn"
  )
)

}

validrows <- function (element) {
  !sapply(element,is.null)
}
