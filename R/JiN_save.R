#' Save the Justice in Numbers Summary Tables
#'
#' This function saves the Justice in Numbers Summary Tables either to an S3 bucket or locally based on the specified settings.
#'
#' @param doc A Word document object created by the officer::read_docx() function
#' @param targetpath Path to the directory where the summary tables should be saved
#' @param S3target Logical indicating whether to save to an S3 bucket (default is TRUE)
#' @param doc_type Whether the file is a pocketbook or summary tables
#'

jin_save <- function(doc,
                     targetpath,
                     S3target,
                     doc_type) {

  file_prefix <- if (doc_type == "pocketbook") {
                    "/JiN_Pocketbook_"
                  } else if (doc_type == "summary_tables") {
                    "/JiN_Summary_Tables_"
                  }

  message("Saving file...")

  if (S3target == TRUE) {

    # Save the document to S3
    docpath <- print(doc, target = tempfile(fileext = ".docx"))

    Rs3tools::write_file_to_s3(docpath,
                               paste0(targetpath, file_prefix, Sys.Date(), ".docx"),
                               overwrite = TRUE)
  } else {

    # Save the summary tables locally
    print(doc, target = paste0(targetpath, file_prefix, Sys.Date(), ".docx"))

  }

}
