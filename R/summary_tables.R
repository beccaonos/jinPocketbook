#' Build the Justice in Numbers Pocketbook Summary Tables pages
#'
#' This internal function builds the Justice in Numbers Pocketbook Summary Tables Pages.
#'
#' @param doc A Word document object.
#' @param rootpath Root path to the JIN API files (default is "https://data.justice.gov.uk". This should only be changed if testing on downloaded JSON files or the location of the API changes).
#' @param ext File extension for API files (default is an empty string. This should only be changed if testing on downloaded JSON files or the format of the API changes).
#'
#' @return The modified doc object with summary tables added.
#'
#' @examples
#' # This function is not intended to be called directly by the user.

summary_tables <- function(doc, rootpath = "https://data.justice.gov.uk", ext = "") {

  # Add a heading for the whole summary tables section
  officer::slip_in_text(doc, "Summary Tables", style = "Heading 2 Char")

  # Read Justice in Numbers API data and publication data from JSON files
  jindata <- jsonlite::read_json(paste0(rootpath, "/api/justice-in-numbers", ext))
  pubdata <- jsonlite::read_json(paste0(rootpath, "/api/publications", ext))

  # Loop through each section of Justice in Numbers to add the table
  for (i in 1:length(jindata$children)) {

    # Read chart data for the current section from the API
    chartdata <- jsonlite::read_json(paste0(rootpath, jindata$children[[i]]$apiUrl, "/chartdata", ext))

    section_name <- jindata$children[[i]]$name

    # Add the section name as a heading to the document
    officer::body_add_par(doc, section_name, style = "heading 3")

    rowcount <- 0

    for (j in 1:length(chartdata)) {

      message(".", appendLF = FALSE)

      # Get the root data for the current chart
      jin_root <- jindata$children[[i]]$children[sapply(jindata$children[[i]]$children,
                                                        function(x) { x$id == chartdata[[j]]$id })][[1]]

      # Read additional data for the current chart from the API
      child_api <- jsonlite::read_json(paste0(rootpath, jin_root$apiUrl, ext))

      # Get the publication information for the chart data
      publication <- pubdata[sapply(pubdata, function(x) { x$id == child_api$dataPublicationId })][[1]]

      # Determine the date for the current chart
      if (is.null(child_api$partialUpdate) | is.null(child_api$partialUpdate$title)) {
        child_date <- ""
      } else {
        child_date <- child_api$partialUpdate$title
      }

      if (chartdata[[j]]$chartDefs$type %in% c("line", "bar")) {

        # Filter out invalid rows from the chart data
        valid <- validrows(chartdata[[j]]$data)

        # Create a data frame for the summary row
        table_df <- dplyr::bind_cols(description = unlist(chartdata[[j]]$descriptions[valid]),
                                     value = unlist(chartdata[[j]]$formattedValues[valid]))

        make_summaryrow <- function() {
          dplyr::bind_cols(
            chartdata[[j]]$name,
            tail(table_df, 1),
            tail(table_df, 2)[1, ],
            child_date,
            publication$currentPublishDate,
            publication$nextPublishDate
          )
        }

        summaryrow <- suppressMessages(make_summaryrow())

        if (rowcount == 0) {
          summarytable <- summaryrow
        } else {
          summarytable <- dplyr::bind_rows(summarytable, summaryrow)
        }

        rowcount <- rowcount + 1
      }

    }

    # Manual step for economic costs of crime because this doesn't fit the structure of other measures - doesn't have a chart.
    if (i == 1) {
      economic_costs_row <- c(
        "Estimated total cost of crime in England and Wales",
        "2015/16",
        "£58.9bn", "", "", "", "23 July 2018", ""
      )

      summarytable <- rbind(summarytable[1:2, ], economic_costs_row, summarytable[-(1:2), ])
    }

    # Replace NA with empty strings in the summary table
    summarytable[is.na(summarytable)] <- ""

    names(summarytable) <- c(
      "Description",
      "Latest trend period",
      "Latest trend value",
      "Previous trend period",
      "Previous trend value",
      "Latest published data point",
      "Last published",
      "Next published"
    )

    # Add the summary table to the document
    officer::body_add_table(
      doc,
      summarytable,
      style = "Table Grid",
      alignment = c("l", "l", "r", "l", "r", "l", "l", "l"),
      align_table = "left",
      stylenames = officer::table_stylenames(stylenames = list("Summary Table" = names(summarytable))),
      header = TRUE,
      first_row = TRUE
    )

    officer::body_add_par(doc, "", style = "Summary Table")

  }

  return(doc)

}
