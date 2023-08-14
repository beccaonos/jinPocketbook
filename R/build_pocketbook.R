#' Build the Justice in Numbers Pocketbook
#'
#' This function builds the Justice in Numbers Pocketbook.
#' It takes several parameters to customize the pocketbook generation process.
#'
#' @param rootpath The root URL path for the API data (default is "https://data.justice.gov.uk").
#' @param ext Additional extension to be appended to the target file name (default is an empty string).
#' @param targetpath The target path for saving the generated pocketbook (default is "alpha-jin-pocketbook/Pocketbook").
#' @param S3target Logical. If TRUE, the generated pocketbook will be saved to S3 (default is TRUE).
#' @param change_check Logical. If TRUE, the function will check whether the generated pocketbook has changed compared to the latest version on S3 and update accordingly (default is FALSE).
#'
#' @examples
#' # Generate the pocketbook and save it to the default location in S3 without checking for changes
#' build_pocketbook()
#'
#' # Generate the pocketbook but only save it to the default location in S3 if it has changed since it was last run
#' build_pocketbook(change_check = TRUE)
#'
#' # Generate the pocketbook and save it to a folder in the working directory called 'outputs'
#' build_pocketbook(targetpath = "outputs", S3target = FALSE)

build_pocketbook <- function(rootpath = "https://data.justice.gov.uk",
                             ext = "",
                             targetpath = "alpha-jin-pocketbook/Pocketbook",
                             S3target = TRUE,
                             change_check = FALSE) {

  # Check if change_check is set correctly
  if (S3target == FALSE & change_check == TRUE) {
    stop("change_check can only be TRUE if S3target = TRUE.")
  }

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
    if (isTRUE(all.equal(old_doc[-c(5,8),], new_doc[-c(5,8),]))) {

      message("No changes detected. File will not be updated.")

    } else {

      message("Changes detected. New file will be created.")

      # Save the new pocketbook
      jin_save(doc,
               targetpath,
               S3target,
               doc_type = "pocketbook")

    }

  } else {

    # Save the pocketbook without checking for changes
    jin_save(doc,
             targetpath,
             S3target,
             doc_type = "pocketbook")

  }

}
