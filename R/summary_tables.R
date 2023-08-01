#' Build the Justice in Numbers Pocketbook Summary Tables pages
#'
#' This function builds the Justice in Numbers Pocketbook Summary Tables Pages.
#'
#' @param doc A Word document object
#' @param rootpath Root path to the JIN API files (only required if testing on downloaded JSON files)
#' @param ext File extenstion for API files (only required if testing on downloaded JSON files)
#' @return The doc object with summary tables added
#' @export

summary_tables <- function(doc, rootpath = "https://data.justice.gov.uk", ext = "") {

  # Add heading for whole summary tables section

  officer::slip_in_text(doc,"Summary Tables", style = "Heading 2 Char")

  jindata <- jsonlite::read_json(paste0(rootpath,"/api/justice-in-numbers",ext))
  pubdata <- jsonlite::read_json(paste0(rootpath,"/api/publications",ext))

  # Loop through each section of Justice in Numbers to add the table

  for (i in 1:length(jindata$children)) {

    chartdata <- jsonlite::read_json(paste0(rootpath, jindata$children[[i]]$apiUrl, "/chartdata", ext))

    section_name <- jindata$children[[i]]$name

    officer::body_add_par(doc, section_name, style = "heading 3")

    rowcount <- 0

    for (j in 1:length(chartdata)) {

      message(".", appendLF = FALSE)

      jin_root <- jindata$children[[i]]$children[sapply(jindata$children[[i]]$children,
                                                        function(x){x$id == chartdata[[j]]$id})][[1]]

      child_api <- jsonlite::read_json(paste0(rootpath, jin_root$apiUrl, ext))

      publication <- pubdata[sapply(pubdata,function(x){x$id == child_api$dataPublicationId})][[1]]

      if (is.null(child_api$partialUpdate) | is.null(child_api$partialUpdate$title))  {
        child_date <- ""
      } else {
        child_date <- child_api$partialUpdate$title
      }

      if (chartdata[[j]]$chartDefs$type %in% c("line","bar")) {

        valid <- validrows(chartdata[[j]]$data)

        table_df <- dplyr::bind_cols(description = unlist(chartdata[[j]]$descriptions[valid]),
                                     value = unlist(chartdata[[j]]$formattedValues[valid]))

        make_summaryrow <- function() { dplyr::bind_cols(chartdata[[j]]$name,
                                       tail(table_df,1),
                                       tail(table_df,2)[1,],
                                       child_date,
                                       publication$currentPublishDate,
                                       publication$nextPublishDate) }

        summaryrow <- suppressMessages(make_summaryrow())

        if (rowcount==0) {
          summarytable <- summaryrow
        } else {
          summarytable <- dplyr::bind_rows(summarytable,summaryrow)
        }

        rowcount <- rowcount + 1
      }

    }

    ## Manual step for economic costs of crime because this doesn't fit the structure of other measures - doesn't have a chart.

    if (i==1) {
      economic_costs_row <- c("Estimated total cost of crime in England and Wales",
                              "2015/16",
                              "£58.9bn","","","","23 July 2018","")

      summarytable <- rbind(summarytable[1:2,],economic_costs_row,summarytable[-(1:2),])
    }

    summarytable[is.na(summarytable)] <- ""

    names(summarytable) <-  c("Description",
                              "Latest trend period",
                              "Latest trend value",
                              "Previous trend period",
                              "Previous trend value",
                              "Latest published data point",
                              "Last published",
                              "Next published")

    officer::body_add_table(doc,
                            summarytable,
                            style = "Table Grid",
                            alignment = c("l","l","r","l","r","l","l","l"),
                            align_table = "left",
                            stylenames = officer::table_stylenames(stylenames = list("Summary Table" = names(summarytable))),
                            header=TRUE,
                            first_row = TRUE)

    officer::body_add_par(doc,"",style = "Summary Table")

  }

  return(doc)

}
