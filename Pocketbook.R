library(jsonlite)
library(officer)
library(magrittr)
library(rvest)
library(qrcode)
library(a11ycharts)
library(ggplot2)
library(stringr)
library(dplyr)

## Once Justice in Numbers goes live, change to reflect URL rather than folder structure

rootpath <- "https://data.justice.gov.uk"
ext <- ""

#rootpath <- "."
#ext <- ".json"

jindata <- jsonlite::read_json(paste0(rootpath,"/api/justice-in-numbers",ext))

pubdata <- jsonlite::read_json(paste0(rootpath,"/api/publications",ext))

validrows <- function (element) {
  !sapply(element,is.null)
}

source("scripts/define_sections.R")
source("scripts/cover_page.R")
source("scripts/contents.R")
source("scripts/guidance.R")
source("scripts/summary_tables.R")
source("scripts/cjs_flowchart.R")
source("scripts/JiN_measures.R")

doc <- read_docx("inst/templates/jin_pocketbook_template.docx")


read_docx(system.file("templates/jin_pocketbook_template.docx", package = "jinPocketbook")) %>%
  cover_page() %>%
  contents() %>%
  officer::body_add_break() %>%
  guidance() %>%
  officer::body_add_break() %>%
  summary_tables() %>%
  officer::body_add_break() %>%
  cjs_flowchart() %>%
  JiN_measures() %>%
  print(target=paste0("outputs/JiN_Pocketbook_",Sys.Date(),".docx"))


contents()
body_add_break(doc)
guidance()
body_add_break(doc)
summary_tables()
body_add_break(doc)
cjs_flowchart()
JiN_measures()

print(d2, target=paste0("outputs/JiN_Pocketbook_",Sys.Date(),".docx"))
