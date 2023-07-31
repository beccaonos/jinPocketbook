#' Build the Justice in Numbers Pocketbook
#'
#' This function builds the Justice in Numbers Pocketbook
#'
#' @export

if (!requireNamespace("a11ycharts", quietly = TRUE)) {
  remotes::install_github("moj-analytical-services/a11ycharts")
}

build_pocketbook <- function() {

read_docx(system.file("templates/jin_pocketbook_template.docx", package = "jinPocketbook")) %>%
  cover_page() %>%
  contents() %>%
  officer::body_add_break() %>%
  guidance() %>%
  officer::body_add_break() %>%
  summary_tables() %>%
  officer::body_add_break() %>%
  cjs_flowchart() %>%
  JiN_measures() %>%
  print(target=paste0("outputs/JiN_Pocketbook_",Sys.Date(),".docx"))

}
