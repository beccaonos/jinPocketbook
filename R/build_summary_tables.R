#' Build the Justice in Numbers Summary Tables document
#'
#' This function builds the Justice in Numbers Summary Tables.
#' It takes several parameters to customize the generation process.
#'
#' @param rootpath The root URL path for the API data (default is "https://data.justice.gov.uk").
#' @param ext Additional extension to be appended to the target file name (default is an empty string).
#' @param targetpath The target path for saving the generated document (default is "alpha-jin-pocketbook/Summary").
#' @param S3target Logical. If TRUE, the generated document will be saved to S3 (default is TRUE).
#' @param change_check Logical. If TRUE, the function will check whether the generated document has changed compared to the latest version on S3 and update accordingly (default is FALSE).
#'
#' @examples
#' # Generate the document and save it to the default location in S3 without checking for changes
#' build_summary_tables()
#'
#' # Generate the document but only save it to the default location in S3 if it has changed since it was last run
#' build_summary_tables(change_check = TRUE)
#'
#' # Generate the summary tables document and save it to a folder in the working directory called 'outputs'
#' build_summary_tables(targetpath = "outputs", S3target = FALSE)

build_summary_tables <- function(rootpath = "https://data.justice.gov.uk",
                             ext = "",
                             targetpath = "alpha-jin-pocketbook/Summary",
                             S3target = TRUE,
                             change_check = FALSE) {

  # Check if change_check is set correctly
  if (S3target == FALSE & change_check == TRUE) {
    stop("change_check can only be TRUE if S3target = TRUE.")
  }

  message("Building Summary Tables...", appendLF = FALSE)

  # Generate the Justice in Numbers summary tables using various functions that each create a section of the document
  doc <- officer::read_docx(system.file("templates/summary_tables_template.docx", package = "jinPocketbook")) %>%
    summary_tables_heading() %>%
    summary_tables()

  message("Done.")

  # Check if change_check is TRUE and handle accordingly
  if (change_check == TRUE) {

    message("Checking whether file has changed (this can take a while)...", appendLF = FALSE)

    # Get the list of files in the target S3 bucket
    bucket_files <- Rs3tools::list_files_in_buckets(
      stringr::str_split(targetpath, "/", simplify = TRUE)[1])

    temp <- tempfile(fileext = ".docx")

    # Download the latest version of the summary tables from S3
    Rs3tools::download_file_from_s3(
      max(bucket_files$path[stringr::str_starts(bucket_files$path,targetpath)]),
      temp,
      overwrite = TRUE)

    message("...", appendLF = FALSE)

    # Read the old and new documents
    old_doc <- officer::read_docx(temp) %>%
      officer::docx_summary()

    message("...")

    new_doc <- officer::docx_summary(doc)

    # Compare old and new summaries to check for changes
    if (isTRUE(all.equal(old_doc[-c(5,8),], new_doc[-c(5,8),]))) {

      message("No changes detected. File will not be updated.")

    } else {

      message("Changes detected. New file will be created.")

      # Save the new summary tables
      jin_save(doc,
               targetpath,
               S3target,
               output_type = "summary_tables")

    }

  } else {

    # Save the summary tables without checking for changes
    jin_save(doc,
             targetpath,
             S3target,
             output_type = "summary_tables")

  }

}
