#' Build the Justice in Numbers Pocketbook Contents Page
#'
#' This internal function builds the Justice in Numbers Pocketbook Contents Page.
#'
#' @param doc A Word document object created by the officer::read_docx() function.
#'
#' @return The modified doc object with the table of contents added.
#'
#' @examples
#' # This function is not intended to be called directly by the user.

contents <- function(doc) {

  # Set the cursor at a bookmark set within the template at the start of the text to mark the contents page location
  officer::cursor_bookmark(doc, "text_start")

  # Add "Contents" heading to the document
  officer::slip_in_text(doc, "Contents", style = "Contents Heading Char")

  # Add introductory text with hyperlink to the Justice in Numbers website and date
  officer::body_add(
    doc,
    officer::fpar(
      officer::ftext("The information in this edition of the pocketbook represents the latest information available from ",
                     prop = officer::fp_text(font.size = 10)),
      officer::hyperlink_ftext(href = "https://data.justice.gov.uk/justice-in-numbers",
                               text = "Justice in Numbers",
                               prop = officer::fp_text(font.size = 10)),
      officer::ftext(" on ",
                     prop = officer::fp_text(font.size = 10)),
      officer::ftext(format(Sys.Date(), '%d %B %Y'),
                     prop = officer::fp_text(bold = TRUE, font.size = 10)),
      officer::ftext(".",
                     prop = officer::fp_text(font.size = 10)),
      officer::run_linebreak()
    )
  )

  # Add table of contents to the document
  officer::body_add_toc(doc)

  return(doc)

}
