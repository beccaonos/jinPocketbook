#' Build the Justice in Numbers Pocketbook Cover Page
#'
#' This internal function builds the Justice in Numbers Pocketbook Cover Page.
#'
#' @param doc A Word document object created by the officer::read_docx() function.
#'
#' @return The modified doc object with cover text added.
#'
#' @examples
#' # This function is not intended to be called directly by the user.

cover_page <- function(doc) {

  # Set the cursor at a bookmark set within the template at the start of the text to mark the cover page text location
  officer::cursor_bookmark(doc, "cover_text_new")

  # Add the title and date to the cover page
  officer::body_add_par(doc, "Justice in Numbers pocketbook", style = "Cover")
  officer::body_add_par(doc, format(Sys.Date(), '%B %Y'), style = "Cover")

  return(doc)

}
