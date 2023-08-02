#' Build the Justice in Numbers Pocketbook Measures pages
#'
#' This internal function builds the Justice in Numbers Measures Pages, covering charts and tables for each JiN measure.
#'
#' @param doc A Word document object.
#' @param rootpath Root path to the JIN API files (default is "https://data.justice.gov.uk". This should only be changed if testing on downloaded JSON files or the location of the API changes).
#' @param ext File extension for API files (default is an empty string. This should only be changed if testing on downloaded JSON files or the format of the API changes).
#'
#' @return The modified doc object with summary tables and charts added.
#'
#' @examples
#' # This function is not intended to be called directly by the user.

JiN_measures <- function(doc, rootpath = "https://data.justice.gov.uk", ext = "") {

  # Read the Justice in Numbers API data and publication data from JSON files
  jindata <- jsonlite::read_json(paste0(rootpath, "/api/justice-in-numbers", ext))
  pubdata <- jsonlite::read_json(paste0(rootpath, "/api/publications", ext))

  # Loop through each section of Justice in Numbers data
  for (i in 1:length(jindata$children)) {

    message("...", appendLF = FALSE)

    # Get the name of the current section
    section_name <- jindata$children[[i]]$name

    # Read chart data for the current section from the API
    chartdata <- jsonlite::read_json(paste0(rootpath, jindata$children[[i]]$apiUrl, "/chartdata", ext))

    # Add the section name as a heading to the document
    officer::body_add_par(doc, section_name, style = "heading 2")

    # Loop through each chart within the current section
    for (j in 1:length(chartdata)) {

      # Get the root data for the current chart
      jin_root <- jindata$children[[i]]$children[sapply(jindata$children[[i]]$children,
                                                        function(x) { x$id == chartdata[[j]]$id })][[1]]

      # Read additional data for the current chart from the API
      child_api <- jsonlite::read_json(paste0(rootpath, jin_root$apiUrl, ext))

      # Extract date and change information for the current chart
      child_date <- child_api$latestPeriodLong
      child_change <- paste(tolower(child_api$trend$trendFromPreviousPeriod),
                            child_api$trend$formattedDelta)

      # Filter out invalid rows from the chart data
      valid <- validrows(chartdata[[j]]$data)

      # Create data frames for chart and table data
      chart_df <- dplyr::bind_cols(label = unlist(chartdata[[j]]$labels[valid]),
                                   value = unlist(chartdata[[j]]$data[valid]))

      table_df <- dplyr::bind_cols(description = unlist(chartdata[[j]]$descriptions[valid]),
                                   value = unlist(chartdata[[j]]$formattedValues[valid]))

      # Process description text for the current chart
      description <- jindata$children[[i]]$children[sapply(jindata$children[[i]]$children,
                                                           function(x) { x$id == chartdata[[j]]$id })][[1]]$description

      description <- stringr::str_replace_all(description, "li>", "p>")

      if (description == "") {} else {

        # Extract paragraphs from the description HTML content
        description <- description %>%
          rvest::read_html() %>%
          rvest::html_elements("p") %>%
          rvest::html_text()

        if (chartdata[[j]]$id == "rotl") {
          description <- description[1]
        }

        description <- paste(description, collapse = " ")
      }

      # Generate a URL for the chart's data source link
      URL <- paste0("https://data.justice.gov.uk", chartdata[[j]]$relativeUrl)

      # Generate a QR code for the chart's data source link
      QRpath <- htmltools::capturePlot(
        qrcode::qrcode_gen(URL),
        tempfile(fileext = ".png"),
        grDevices::png
      )

      # Extract latest figure and period for the chart from the table data
      latest_figure <- tail(table_df, 1)[, 2]
      latest_period <- tail(chart_df, 1)[, 1]

      # Determine the emphasis text based on whether partial update is available
      if (is.null(child_api$partialUpdate)) {
        emphasis_text <- paste0("The figure for ", latest_period, " is ", latest_figure,
                                ", ", child_change)
      } else {
        update_txt <- child_api$partialUpdate$body %>%
          rvest::read_html() %>%
          rvest::html_elements("p") %>%
          rvest::html_text()

        emphasis_text <- paste0("Latest published data: ", update_txt)
      }

      # Get the publication information for the chart data
      publication <- pubdata[sapply(pubdata, function(x) { x$id == child_api$dataPublicationId })][[1]]

      # Generate a heading for the chart
      if (chartdata[[j]]$chartDefs$type %in% c("line", "bar")) {
        chartheading <- chartdata[[j]]$name
      } else {
        chartheading <- paste0(chartdata[[j]]$name, ": ", child_date)
      }

      # Add the chart heading and description to the document
      officer::body_add_par(doc, chartheading, style = "heading 3")
      for (k in 1:length(description)) {
        officer::body_add_par(doc, description[k], style = "Description text")
      }

      # Determine the table length based on chart type
      if (chartdata[[j]]$chartDefs$type %in% c("line", "bar")) {
        officer::body_add_par(doc, emphasis_text, style = "Emphasis Text")
        table_length <- 8
      } else {
        table_length <- nrow(table_df)
      }

      # Add the chart to the document
      officer::body_add_gg(
        doc,
        a11ycharts::a11ychart(chart_df, "label", "value",
                              chartdata[[j]]$chartDefs$type,
                              yscale = chartdata[[j]]$chartDefs$dataType,
                              breakwidth = NULL) + ggplot2::theme(text = ggplot2::element_text(size = 10)),
        width = 4.2, height = 2
      )

      officer::body_add_par(doc, "", style = "Table Text")

      # Add a section break to ensure the chart and table are on separate pages
      officer::body_end_block_section(doc, value = officer::block_section(
        officer::prop_section(
          type = "nextPage"
        )
      ))

      # Add the table to the document
      officer::body_add_table(
        doc, tail(table_df, table_length),
        style = "Table Grid", alignment = c("l", "r"), align_table = "center",
        stylenames = officer::table_stylenames(stylenames = list("Table Text" = c("description", "value"))),
        header = FALSE,
        first_row = FALSE
      )

      officer::body_add(doc, officer::fpar(officer::run_columnbreak()))
      officer::slip_in_text(doc, paste("Last published:", publication$currentPublishDate),
                            style = "Description text Char")

      # Add the "Next release" information if available
      if (is.null(publication$nextPublishDate)) {
        officer::body_add(doc, officer::fpar(officer::ftext("")))
      } else {
        officer::body_add_par(doc, paste("Next release:", stringr::str_replace(publication$nextPublishDate, " 9:30am", "")),
                              style = "Description text")
      }

      # Add the publication source information
      officer::body_add_fpar(doc, officer::fpar(officer::ftext("Source: ",
                                                               prop = officer::fp_text(font.size = 9)),
                                                officer::hyperlink_ftext(
                                                  href = publication$indexUri,
                                                  text = publication$name,
                                                  prop = officer::fp_text(font.size = 9)),
                                                officer::run_linebreak()))

      # Add the URL link to the chart's data source
      officer::body_add(doc, officer::fpar(officer::hyperlink_ftext(
        href = URL,
        text = "Click here to view on Justice Data",
        prop = officer::fp_text(font.size = 9))))

      # Add the QR code for the chart's data source
      officer::slip_in_text(doc, " or use the QR code below:", style = "Description text Char")
      officer::body_add_img(doc, QRpath, width = 0.5, height = 0.5)

      # End the current block section to ensure the next chart starts on a new page
      officer::body_end_block_section(doc, value = officer::block_section(
        officer::prop_section(
          type = "continuous",
          section_columns = officer::section_columns(widths = c(1.88, 1.88), space = 0.5, sep = FALSE)
        )
      ))

    }

  }

  return(doc)
}
