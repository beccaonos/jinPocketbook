#' Build the Justice in Numbers Pocketbook
#'
#' This function builds the Justice in Numbers Pocketbook
#'
#' @export

build_pocketbook <- function(rootpath = "https://data.justice.gov.uk",
                             ext = "",
                             targetpath = "alpha-jin-pocketbook/Pocketbook",
                             S3target = TRUE) {

  message("Building Pocketbook...", appendLF = FALSE)

  doc <- officer::read_docx(system.file("templates/jin_pocketbook_template.docx", package = "jinPocketbook")) %>%
            cover_page() %>%
            contents() %>%
            officer::body_add_break() %>%
            guidance() %>%
            officer::body_add_break() %>%
            summary_tables() %>%
            officer::body_add_break() %>%
            cjs_flowchart() %>%
            JiN_measures()

  message("done.")
  message("Saving file...")

  if (S3target == TRUE) {

      docpath <- print(doc,target=tempfile(fileext = ".docx"))

      Rs3tools::write_file_to_s3(docpath,
                                 paste0(targetpath,"/JiN_Pocketbook_",Sys.Date(),".docx"),
                                 overwrite =TRUE)
  } else {

      print(doc,target=paste0(targetpath,"/JiN_Pocketbook_",Sys.Date(),".docx"))

  }

}
