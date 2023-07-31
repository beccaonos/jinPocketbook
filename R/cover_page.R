#' Build the Justice in Numbers Pocketbook Cover Page
#'
#' This function builds the Justice in Numbers Pocketbook Cover Page.
#'
#' @param doc A Word document object created by the officer::read_docx() function
#' @return The doc object with cover text added
#' @export

cover_page <- function(doc) {

  officer::cursor_bookmark(doc, "cover_text_new")
  officer::body_add_par(doc, "Justice in Numbers pocketbook", style = "Cover")
  officer::body_add_par(doc, format(Sys.Date(),'%B %Y'), style = "Cover")

  return(doc)

}
