
overview_table <- function() {

rootpath <- "https://data.justice.gov.uk"
ext <- ""

sections <- c("justice-in-numbers",
              "cjs-statistics",
              "prisons",
              "probation",
              "contracts",
              "courts",
              "legalaid")

for (h in 1:length(sections)) {

jindata <- jsonlite::read_json(paste0(rootpath, "/api/",sections[h], ext))

Level_1 <- jindata$name

  for (i in 1:length(jindata$children)) {

    Level_2 <- jindata$children[[i]]$name

    for (j in 1:length(jindata$children[[i]]$children)) {

      name <- jindata$children[[i]]$children[[j]]$name
      id <- jindata$children[[i]]$children[[j]]$id
      URL <- paste0("https://data.justice.gov.uk",jindata$children[[i]]$children[[j]]$permalink)
      publicationId <- jindata$children[[i]]$children[[j]]$dataPublicationId

      newrow <- dplyr::bind_cols(Level_1,Level_2,name,URL,id,publicationId)

      if (h == 1 & i == 1 & j == 1) {
        table <- newrow
      } else {
        table <- dplyr::bind_rows(table,newrow)
      }

    }

  }

}

names(table) <- c("Section","Subsection","Measure","URL","measure_id","publication_id")

return(table)

}
