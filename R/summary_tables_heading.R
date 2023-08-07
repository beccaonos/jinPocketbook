#' Justice in Numbers - Summary Tables Heading
#'
#' This function adds the heading for the Summary Tables section in the Justice in Numbers pocketbook.
#'
#' @param doc A Word document object created by the officer::read_docx() function
#' @return The doc object with the summary tables heading added
#'

summary_tables_heading <- function(doc) {

  # Add the heading for the Summary Tables section
  officer::slip_in_text(doc,
                        paste0("Justice in Numbers - Summary Tables: ",
                               format(Sys.Date(),'%d %B %Y')),
                        style = "Heading 2 Char")

  # Add the introductory text for the Summary Tables section
  officer::body_add(doc,
                    officer::fpar(officer::ftext("The below tables summarise the latest information presented in Justice in Numbers as at ",
                                                 prop = officer::fp_text(font.size = 12)),
                                  officer::ftext(format(Sys.Date(),'%d %B %Y'),
                                                 prop = officer::fp_text(bold=TRUE,font.size = 12)),
                                  officer::ftext(".",prop = officer::fp_text(font.size = 12)),
                                  officer::run_linebreak(),
                                  officer::run_linebreak(),
                                  officer::ftext("Some measures are presented as an annual trend, with data reported at fixed intervals. In some of these cases, more recent intermediate quarterly figures are published which do not align with these annual periods. These are highlighted in the 'Latest published data point' column. The most recent and next publication dates are also listed for each measure. In cases where there is no next publication date listed, this is because a future publication date has not been announced.",
                                                 prop = officer::fp_text(font.size = 12)),
                                  officer::run_linebreak(),
                                  officer::run_linebreak(),
                                  officer::ftext("For a full explanation of each measure, sources used and full time series please visit ",
                                                 prop = officer::fp_text(font.size = 12)),
                                  officer::hyperlink_ftext(
                                    href = "https://data.justice.gov.uk/justice-in-numbers",
                                    text = "https://data.justice.gov.uk/justice-in-numbers",
                                    prop = officer::fp_text(font.size = 12))))
  officer::body_add_par(doc,"")

  return(doc)

}
