
staging_table <- function(username,password) {

rootpath <- "https://justicedata-staging.apps.live-1.cloud-platform.service.justice.gov.uk/"
ext <- ""

sections <- c(
              "cjs-statistics",
              "prisons",
              "probation",
              "contracts",
              "courts",
              "legalaid")

for (h in 1:length(sections)) {

jindata <- jsonlite::read_json(paste0(rootpath, "/api/",sections[h], ext))

#jin_json <- httr::GET(paste0(rootpath, "/api/",sections[h], ext),httr::authenticate(username,password))
#jindata <- jsonlite::parse_json(rawToChar(jin_json$content))

Level_1 <- jindata$name

  for (i in 1:length(jindata$children)) {

    Level_2 <- jindata$children[[i]]$name

    for (j in 1:length(jindata$children[[i]]$children)) {

      name <- jindata$children[[i]]$children[[j]]$name
      id <- jindata$children[[i]]$children[[j]]$id
      URL <- paste0("https://data.justice.gov.uk",jindata$children[[i]]$children[[j]]$permalink)
      publicationId <- jindata$children[[i]]$children[[j]]$dataPublicationId

      #measure_data <- jsonlite::read_json(paste0(rootpath,jindata$children[[i]]$children[[j]]$apiUrl))
      measure_json <- httr::GET(paste0(rootpath,jindata$children[[i]]$children[[j]]$apiUrl),httr::authenticate(username,password))
      measure_data <- jsonlite::parse_json(rawToChar(measure_json$content))

      measure_df <- dplyr::bind_rows(measure_data$summaryData)

      newrow <- dplyr::bind_cols(Level_1,Level_2,name,URL,id,publicationId,measure_df)

      if (h == 1 & i == 1 & j == 1) {
        table <- newrow
      } else {
        table <- dplyr::bind_rows(table,newrow)
      }

    }

  }

}

names(table) <- c("Section","Subsection","Measure","URL","measure_id","publication_id",names(measure_df))

return(table)

}
