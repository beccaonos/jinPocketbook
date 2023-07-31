#' Build the Justice in Numbers Pocketbook Contents Page
#'
#' This function builds the Justice in Numbers Pocketbook Contents Page.
#'
#' @param doc A Word document object created by the officer::read_docx() function
#' @return The doc object with table of contents added
#' @export

contents <- function(doc) {

  officer::cursor_bookmark(doc, "text_start")
  officer::slip_in_text(doc, "Contents", style = "Contents Heading Char")
  officer::body_add(doc,
                    officer::fpar(
                      officer::ftext(
                        "The information in this edition of the pocketbook represents the latest information available from ",
                        prop = officer::fp_text(font.size = 10)
                        ),
                      officer::hyperlink_ftext(
                        href = "https://data.justice.gov.uk/justice-in-numbers",
                        text = "Justice in Numbers",
                        prop = officer::fp_text(font.size = 10)
                        ),
                      officer::ftext(
                        " on ",
                        prop = officer::fp_text(font.size = 10)
                        ),
                      officer::ftext(
                        format(Sys.Date(),'%d %B %Y'),
                        prop = officer::fp_text(bold=TRUE,font.size = 10)
                        ),
                      officer::ftext(
                        ".",
                        prop = officer::fp_text(font.size = 10)
                        ),
                      officer::run_linebreak()
                      )
                    )
  officer::body_add_toc(doc)

  return(doc)

}
