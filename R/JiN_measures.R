#' Build the Justice in Numbers Pocketbook Measures pages
#'
#' This function builds the Justice in Numbers Measures Pages, covering charts and tables for each JiN measure.
#'
#' @param doc A Word document object
#' @param rootpath Root path to the JIN API files (only required if testing on downloaded JSON files)
#' @param ext File extenstion for API files (only required if testing on downloaded JSON files)
#' @return The doc object with summary tables added
#' @export

JiN_measures <- function(doc, rootpath = "https://data.justice.gov.uk", ext = "") {

  jindata <- jsonlite::read_json(paste0(rootpath,"/api/justice-in-numbers",ext))
  pubdata <- jsonlite::read_json(paste0(rootpath,"/api/publications",ext))

  for (i in 1:length(jindata$children)) {

    section_name <- jindata$children[[i]]$name

    chartdata <- jsonlite::read_json(paste0(rootpath,jindata$children[[i]]$apiUrl,"/chartdata",ext))

    officer::body_add_par(doc,section_name, style = "heading 2")

    for (j in 1:length(chartdata)) {

      jin_root <- jindata$children[[i]]$children[sapply(jindata$children[[i]]$children,
                                                        function(x){x$id == chartdata[[j]]$id})][[1]]

      child_api <- jsonlite::read_json(paste0(rootpath,jin_root$apiUrl,ext))

      child_date <- child_api$latestPeriodLong

      child_change <- paste(tolower(child_api$trend$trendFromPreviousPeriod),
                            child_api$trend$formattedDelta)

      valid <- validrows(chartdata[[j]]$data)

      chart_df <- dplyr::bind_cols(label = unlist(chartdata[[j]]$labels[valid]),
                                   value = unlist(chartdata[[j]]$data[valid]))

      ## Manual edit to probation caseload data.

      if(chartdata[[j]]$id == "caseload-total") {
        chart_df <- chart_df[-c(1:7),]
      }

      table_df <- dplyr::bind_cols(description = unlist(chartdata[[j]]$descriptions[valid]),
                                   value = unlist(chartdata[[j]]$formattedValues[valid]))

      description <- jindata$children[[i]]$children[sapply(
        jindata$children[[i]]$children,
        function(x){x$id == chartdata[[j]]$id})][[1]]$description

      description <- stringr::str_replace_all(description,"li>","p>")

      if (description == "") {} else {

        description <- description %>%
          rvest::read_html() %>%
          rvest::html_elements("p") %>%
          rvest::html_text()

        if (chartdata[[j]]$id == "rotl") {
          description <- description[1]
        }

        description <- paste(description,collapse=" ")
      }

      URL <- paste0("https://data.justice.gov.uk",chartdata[[j]]$relativeUrl)

   #   grDevices::png("images/QR/QR.png")
  #    qrcode::qrcode_gen(URL)
  #    grDevices::dev.off()

      latest_figure <- tail(table_df,1)[,2]
      latest_period <- tail(chart_df,1)[,1]

      if (is.null(child_api$partialUpdate)) {
        emphasis_text <- paste0("The figure for ",latest_period," is ",latest_figure,
                                ", ",child_change)
      } else {
        update_txt <- child_api$partialUpdate$body %>%
          rvest::read_html() %>%
          rvest::html_elements("p") %>%
          rvest::html_text()

        emphasis_text <- paste0("Latest published data: ",update_txt)
      }

      publication <- pubdata[sapply(pubdata,function(x){x$id == child_api$dataPublicationId})][[1]]

      if (chartdata[[j]]$chartDefs$type %in% c("line","bar")) {
        chartheading <- chartdata[[j]]$name
      } else {
        chartheading <- paste0(chartdata[[j]]$name,": ",child_date)
      }

      officer::body_add_par(doc,chartheading, style = "heading 3")
      for (k in 1:length(description)){
        officer::body_add_par(doc,description[k],style = "Description text")
      }
      if (chartdata[[j]]$chartDefs$type %in% c("line","bar")) {
        officer::body_add_par(doc,emphasis_text,
                     style = "Emphasis Text")
        table_length <- 8
      } else {
        table_length <- nrow(table_df)
      }
      officer::body_add_gg(doc,a11ycharts::a11ychart(chart_df,"label","value",
                                chartdata[[j]]$chartDefs$type,
                                yscale=chartdata[[j]]$chartDefs$dataType,
                                breakwidth=NULL)+ggplot2::theme(text = element_text(size = 10)),
                  width=4.2,height=2)
      officer::body_add_par(doc,"",style = "Table Text")
      officer::body_end_block_section(doc, value =   block_section(
        prop_section(
          type = "nextPage"
        )
      ))
      officer::body_add_table(doc,tail(table_df,table_length),
                     style = "Table Grid",alignment = c("l","r"),align_table = "center",
                     stylenames = table_stylenames(stylenames = list("Table Text" = c("description","value"))),
                     header=FALSE,
                     first_row = FALSE)
      officer::body_add(doc,officer::fpar(officer::run_columnbreak()))
      officer::slip_in_text(doc,paste("Last published:",publication$currentPublishDate),
                   style = "Description text Char")
      if (is.null(publication$nextPublishDate)) {officer::body_add(doc,officer::fpar(officer::ftext("")))}
      else {officer::body_add_par(doc,paste("Next release:",stringr::str_replace(publication$nextPublishDate," 9:30am","")),
                         style = "Description text")}
      officer::body_add_fpar(doc,officer::fpar(officer::ftext("Source: ",
                                   prop = officer::fp_text(font.size = 9)),

                             officer::hyperlink_ftext(
                               href = publication$indexUri,
                               text = publication$name,
                               prop = fp_text(font.size = 9)),
                             officer::run_linebreak()))
      officer::body_add(doc,officer::fpar(officer::hyperlink_ftext(
        href = URL,
        text = "Click here to view on Justice Data",
        prop = officer::fp_text(font.size = 9))))
      officer::slip_in_text(doc, " or use the QR code below:", style = "Description text Char")
    #  officer::body_add_img(doc,"images/QR/QR.png",width=0.5,height=0.5)
      officer::body_end_block_section(doc, value =   block_section(
        prop_section(
          type = "continuous",
          section_columns = section_columns(widths = c(1.88, 1.88), space = 0.5, sep = FALSE)
        )
      ))

    }

  }

  return(doc)
}

if (!requireNamespace("a11ycharts", quietly = TRUE)) {
  remotes::install_github("moj-analytical-services/a11ycharts")
}
