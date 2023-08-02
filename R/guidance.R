#' Build the Justice in Numbers Pocketbook Guidance Page
#'
#' This internal function builds the Justice in Numbers Pocketbook Guidance Page.
#'
#' @param doc A Word document object.
#'
#' @return The modified doc object with guidance added.
#'
#' @examples
#' # This function is not intended to be called directly by the user.

guidance <- function(doc) {

  # Introduction text for the guidance page
  intro1 <- "This pocketbook contains a printable version of the information presented in "
  intro2 <- ". The QR code beneath each measure will take you to the relevant section of Justice in Numbers, where you can find additional trend data, as well as links to source material where additional context and caveats can be found to aid interpretation."

  # Trend data information
  trend <- "Some measures are presented as an annual trend, with data reported at fixed intervals. In some cases, more recent intermediate quarterly figures are published which do not align with these annual periods. These are highlighted in the 'Latest published data point' column of the Summary Tables, and above the relevant trend charts where applicable. The most recent and next publication dates are also listed for each measure. In cases where there is no next publication date listed, this is because a future publication date has not been announced."

  # Add heading for guidance page
  officer::body_add_par(doc, "Guidance", style = "heading 2")

  # Add introductory text to the guidance page
  officer::body_add_par(doc, "", style = "Description text")
  officer::body_add_fpar(
    doc,
    officer::fpar(
      officer::ftext(
        intro1,
        prop = officer::fp_text(font.size = 10)
      ),
      officer::hyperlink_ftext(
        href = "https://data.justice.gov.uk/justice-in-numbers",
        text = "Justice in Numbers",
        prop = officer::fp_text(font.size = 10)
      ),
      officer::ftext(
        intro2,
        prop = officer::fp_text(font.size = 10)
      ),
      officer::run_linebreak()
    )
  )

  # Add trend data information to the guidance page
  officer::body_add_fpar(
    doc,
    officer::fpar(
      officer::ftext(
        trend,
        prop = officer::fp_text(font.size = 10)
      ),
      officer::run_linebreak()
    )
  )

  # Add the link to Justice in Numbers website
  officer::body_add_fpar(
    doc,
    officer::fpar(
      officer::ftext(
        "Justice in Numbers can be accessed at ",
        prop = officer::fp_text(font.size = 10)
      ),
      officer::hyperlink_ftext(
        href = "https://data.justice.gov.uk/justice-in-numbers",
        text = "https://data.justice.gov.uk/justice-in-numbers",
        prop = officer::fp_text(font.size = 10)
      )
    )
  )

  return(doc)

}
