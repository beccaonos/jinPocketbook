#' Build the Justice in Numbers Pocketbook CJS Flowchart page
#'
#' This internal function builds the Justice in Numbers CJS Flowchart Page.
#'
#' @param doc A Word document object to which the flowchart page will be added.
#'
#' @return The modified doc object with the CJS flowchart page added.
#'
#' @examples
#' # This function is not intended to be called directly by the user.

cjs_flowchart <- function(doc) {

  # Add heading and flowchart image to the Word document
  officer::body_add_par(doc, "Flow through the Criminal Justice System - Year ending March 2022", style = "heading 2")
  officer::body_add_img(doc, system.file("images/CJS Flowchart March 2022.png", package = "jinPocketbook"), width = 4.3, height = 4.5)

  # Add notes to the Word document
  officer::body_add_par(
    doc,
    "NOTES: Note A: Covers all indictable offences, including triable either way, plus a few closely associated summary offences. Excludes fraud offences recorded by Action Fraud/CIFAS/Financial Fraud Action UK.
    Note B: Includes males, females, persons where sex 'Not Stated and other offenders, i.e. companies, public bodies, etc.
    Note D: Defendants tried or sentenced at the Crown Court in a given year may have been committed for trial or sentence by a magistrate in a previous year.
    Note F: Prison receptions of offenders sentenced to immediate custody, excluding fine defaulters.
    Note G: Offenders starting Community Order or Suspended Sentence Order supervision by the Probation Service. Includes Suspended Sentence Orders without requirements.",
    style = "Table Text"
  )

  return(doc)

}
