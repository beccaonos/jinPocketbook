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
#' @export
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

  summary_tables_heading <- function(doc) {

    officer::slip_in_text(doc,
                          paste0("Justice in Numbers - Summary Tables: ",
                                 format(Sys.Date(),'%d %B %Y')),
                          style = "Heading 2 Char")

    officer::body_add(doc,
                      officer::fpar(officer::ftext("The below tables summarise the latest information presented in Justice in Numbers as at ",prop = officer::fp_text(font.size = 12)),
                      officer::ftext(format(Sys.Date(),'%d %B %Y'),prop = officer::fp_text(bold=TRUE,font.size = 12)),
                      officer::ftext(".",prop = officer::fp_text(font.size = 12)),
                      officer::run_linebreak(),
                      officer::run_linebreak(),
                      officer::ftext("Some measures are presented as an annual trend, with data reported at fixed intervals. In some of these cases, more recent intermediate quarterly figures are published which do not align with these annual periods. These are highlighted in the 'Latest published data point' column. The most recent and next publication dates are also listed for each measure. In cases where there is no next publication date listed, this is because a future publication date has not been announced.",prop = officer::fp_text(font.size = 12)),
                      officer::run_linebreak(),
                      officer::run_linebreak(),
                      officer::ftext("For a full explanation of each measure, sources used and full time series please visit ",prop = officer::fp_text(font.size = 12)),
                      officer::hyperlink_ftext(
                        href = "https://data.justice.gov.uk/justice-in-numbers",
                        text = "https://data.justice.gov.uk/justice-in-numbers",
                        prop = officer::fp_text(font.size = 12))))
    officer::body_add_par(doc,"")

    return(doc)

  }


  message("Building Summary Tables...", appendLF = FALSE)

  # Generate the Justice in Numbers summary tables using various functions that each create a section of the document
  doc <- officer::read_docx(system.file("templates/summary_tables_template.docx", package = "jinPocketbook")) %>%
    summary_tables_heading() %>%
    summary_tables()

  message("Done.")

  # Define a function to save the generated summary tables
  jin_save <- function() {

    message("Saving file...")

    if (S3target == TRUE) {

      # Save the summary tables to S3
      docpath <- print(doc, target = tempfile(fileext = ".docx"))
      Rs3tools::write_file_to_s3(docpath,
                                 paste0(targetpath, "/JiN_Summary_Tables_", Sys.Date(), ext, ".docx"),
                                 overwrite = TRUE)
    } else {

      # Save the summary tables locally
      print(doc, target = paste0(targetpath, "/JiN_Summary_Tables_", Sys.Date(), ext, ".docx"))

    }

  }

  # Check if change_check is TRUE and handle accordingly
  if (change_check == TRUE) {

    message("Checking whether file has changed (this can take a while)...", appendLF = FALSE)

    # Get the list of files in the target S3 bucket
    bucket_files <- Rs3tools::list_files_in_buckets(
      stringr::str_split(targetpath, "/", simplify = TRUE)[1])

    temp <- tempfile(fileext = ".docx")

    # Download the latest version of the summary tables from S3
    Rs3tools::download_file_from_s3(max(bucket_files$path), temp, overwrite = TRUE)

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
      jin_save()

    }

  } else {

    # Save the summary tables without checking for changes
    jin_save()

  }

}
