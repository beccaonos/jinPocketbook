#' Build the Justice in Numbers Pocketbook
#'
#' This function builds the Justice in Numbers Pocketbook
#'
#' @export

build_pocketbook <- function(rootpath = "https://data.justice.gov.uk",
                             ext = "",
                             targetpath = "alpha-jin-pocketbook/Pocketbook",
                             S3target = TRUE,
                             change_check = FALSE) {

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

  jin_save <- function() {

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

  if (change_check == TRUE) {

    bucket_files <- Rs3tools::list_files_in_buckets(
      stringr::str_split(targetpath,"/", simplify = TRUE)[1])

    temp <- tempfile(fileext = ".docx")

    Rs3tools::download_file_from_s3(max(bucket_files$path), temp, overwrite = TRUE)

    old_doc <- officer::read_docx(temp) %>%
                  officer::docx_summary()

    new_doc <- officer::docx_summary(doc)

    if (isTRUE(all.equal(old_doc,new_doc))) {

      message("No changes detected. File will not be updated.")

    } else {

      message("Changes detected. New file will be created.")

      jin_save()

    }

  } else {

    jin_save()

  }



}
