

scraper_table <- function(PAT) {

  h <- curl::new_handle(verbose = TRUE)
  curl::handle_setheaders(h,
                    "Authorization" = paste0("token ",PAT)
  )
  con <- curl::curl("https://raw.githubusercontent.com/ministryofjustice/justice-data/main/JusticeDataTools/PublicationConverters/ConverterCore/appSettings.json", handle = h)
  scraper <- jsonlite::parse_json(con)

  for (i in 1:length(scraper$PublicationSettings$ConverterDefinitions)) {

    for (j in 1:length(scraper$PublicationSettings$ConverterDefinitions[[i]]$Measures)) {

      id <- scraper$PublicationSettings$ConverterDefinitions[[i]]$Measures[[j]]$MeasureID

      SheetName <- coalesce(c(scraper$PublicationSettings$ConverterDefinitions[[i]]$MeasureDefaults$SheetName,scraper$PublicationSettings$ConverterDefinitions[[i]]$Measures[[j]]$SheetName))


      StartColumn <- coalesce(c(scraper$PublicationSettings$ConverterDefinitions[[i]]$MeasureDefaults$StartColumn,scraper$PublicationSettings$ConverterDefinitions[[i]]$Measures[[j]]$StartColumn))

      EndColumn <- coalesce(c(scraper$PublicationSettings$ConverterDefinitions[[i]]$MeasureDefaults$EndColumn,scraper$PublicationSettings$ConverterDefinitions[[i]]$Measures[[j]]$EndColumn))

      StartRow <- coalesce(c(scraper$PublicationSettings$ConverterDefinitions[[i]]$MeasureDefaults$StartRow,scraper$PublicationSettings$ConverterDefinitions[[i]]$Measures[[j]]$StartRow))

      EndRow <- coalesce(c(scraper$PublicationSettings$ConverterDefinitions[[i]]$MeasureDefaults$EndRow,scraper$PublicationSettings$ConverterDefinitions[[i]]$Measures[[j]]$EndRow))

      newrow <- bind_cols(id,SheetName,StartColumn,EndColumn,StartRow,EndRow)

      if (i == 1 & j == 1) {
        table_scraper <- newrow
      } else {
        table_scraper <- bind_rows(table_scraper,newrow)
      }

    }

  }

  names(table_scraper) <- c("measure_id","SheetName","StarColumn","EndColumn","StartRow","EndRow")

  return(table_scraper)

}
