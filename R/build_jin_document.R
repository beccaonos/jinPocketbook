#' Build the Justice in Numbers Pocketbook documents
#'
#' This function builds the Justice in Numbers Pocketbook or Summary Tables document.
#' It takes several parameters to customize the document generation process.
#'
#' @param doc_type Either "pocketbook" or "summary_tables" depending on which document you want to create.
#' @param rootpath The root URL path for the API data (default is "https://data.justice.gov.uk").
#' @param ext Additional extension to be appended to the API file name (default is an empty string).
#' @param targetpath The target path for saving the generated document (default is "alpha-jin-pocketbook").
#' @param S3target Logical. If TRUE, the generated pocketbook will be saved to S3 (default is TRUE).
#' @param change_check Logical. If TRUE, the function will check whether the generated document has changed compared to the latest version on S3 and update accordingly (default is FALSE).
#'
#' @export
#'
#' @examples
#' # Generate the pocketbook and save it to the default location in S3 without checking for changes
#' build_jin_document("pocketbook")
#'
#' # Generate the pocketbook but only save it to the default location in S3 if it has changed since it was last run
#' build_jin_document("pocketbook", change_check = TRUE)
#'
#' # Generate the summary_tables and save them to a folder in the working directory called 'outputs'
#' build_jin_document("summary_tables", targetpath = "outputs", S3target = FALSE)

build_jin_document <- function(doc_type,
                               rootpath = "https://data.justice.gov.uk",
                               ext = "",
                               targetpath = "alpha-jin-pocketbook",
                               S3target = TRUE,
                               change_check = FALSE) {

  # Check if change_check is set correctly
  if (S3target == FALSE & change_check == TRUE) {
    stop("change_check can only be TRUE if S3target = TRUE.")
  }

  if (doc_type == "pocketbook") {

    targetpath <- paste0(targetpath,"/Pocketbook")

    daterows <- c(5,8)

    message("Building Pocketbook...", appendLF = FALSE)

    # Generate the Justice in Numbers pocketbook using various functions that each create a section of the pocketbook
    doc <- officer::read_docx(system.file("templates/jin_pocketbook_template.docx", package = "jinPocketbook")) %>%
      cover_page() %>%
      contents() %>%
      officer::body_add_break() %>%
      guidance() %>%
      officer::body_add_break() %>%
      officer::slip_in_text("Summary Tables", style = "Heading 2 Char") %>%
      summary_tables() %>%
      officer::body_add_break() %>%
      cjs_flowchart() %>%
      JiN_measures()

  } else if (doc_type == "summary_tables") {

    targetpath <- paste0(targetpath,"/Summary")

    daterows <- c(1,2)

    message("Building Summary Tables...", appendLF = FALSE)

    # Generate the Justice in Numbers summary tables using various functions that each create a section of the document
    doc <- officer::read_docx(system.file("templates/summary_tables_template.docx", package = "jinPocketbook")) %>%
      summary_tables_heading() %>%
      summary_tables()

  }

  message("Done.")

  # Check if change_check is TRUE and handle accordingly
  if (change_check == TRUE) {

    message("Checking whether file has changed (this can take a while)...", appendLF = FALSE)

    # Get the list of files in the target S3 bucket
    bucket_files <- Rs3tools::list_files_in_buckets(
      stringr::str_split(targetpath, "/", simplify = TRUE)[1])

    temp <- tempfile(fileext = ".docx")

    # Download the latest version of the pocketbook from S3
    Rs3tools::download_file_from_s3(
      max(bucket_files$path[stringr::str_starts(bucket_files$path,targetpath)]),
      temp,
      overwrite = TRUE)

    message("...", appendLF = FALSE)

    # Read the old and new pocketbook summaries
    old_doc <- officer::read_docx(temp) %>%
      officer::docx_summary()

    message("...")

    new_doc <- officer::docx_summary(doc)

    # Compare old and new summaries to check for changes
    if (isTRUE(all.equal(old_doc[-daterows,], new_doc[-daterows,]))) {

      message("No changes detected. File will not be updated.")

    } else {

      message("Changes detected. New file will be created.")

      # Save the new pocketbook
      jin_save(doc,
               targetpath,
               S3target,
               doc_type)

    }

  } else {

    # Save the pocketbook without checking for changes
    jin_save(doc,
             targetpath,
             S3target,
             doc_type)

  }

}
