library('jsonlite')
library('ggplot2')
library('shiny')
library('plotly')
library("DT")
library(httr)
library(dplyr)

source("key.R")
source("functions.R")

server <- function(input, output){
  dataTable <- reactive({
    yelp <- "https://api.yelp.com"
    location <- "4060 George Washington Lane Northeast, Seattle, WA 98195"
    limit <- 50
    radius <- input$range
    url <- modify_url(yelp, path = c("v3", "businesses", "search"),
                      query = list(location = location,
                                   limit = limit,
                                   radius = radius))
    res <- GET(url, add_headers('Authorization' = paste("bearer", apikey)))
    results <- content(res)
    
    results_list <- lapply(results$businesses, FUN = yelp_httr_parse)
    payload <- do.call("rbind", results_list)
    return(payload)
  })
  
  output$yelp <- renderDataTable({
    return(dataTable())
  })
}
