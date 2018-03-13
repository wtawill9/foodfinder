source(key.R)

yelp <- "https://api.yelp.com"
term <- "restaurants"
location <- "University of Washington Seattle, WA"
longitude <- 47.656397
latitude <- -122.310410
categories <- NULL
limit <- 50
radius <- 600
url <- modify_url(yelp, path = c("v3", "businesses", "search"),
                  query = list(term = term, 
                               location = location,
                               limit = limit,
                               radius = radius))
res <- GET(url, add_headers('Authorization' = paste("bearer", apikey)))

results <- content(res)

yelp_httr_parse <- function(x) {
  parse_list <- list(id = x$id, 
                     name = x$name, 
                     rating = x$rating, 
                     review_count = x$review_count, 
                     latitude = x$coordinates$latitude, 
                     longitude = x$coordinates$longitude, 
                     address1 = x$location$address1, 
                     city = x$location$city, 
                     state = x$location$state, 
                     distance = x$distance)
  
  parse_list <- lapply(parse_list, FUN = function(x) ifelse(is.null(x), "", x))
  
  df <- data_frame(id=parse_list$id,
                   name=parse_list$name, 
                   rating = parse_list$rating, 
                   review_count = parse_list$review_count, 
                   latitude=parse_list$latitude, 
                   longitude = parse_list$longitude, 
                   address1 = parse_list$address1, 
                   city = parse_list$city, 
                   state = parse_list$state, 
                   distance= parse_list$distance)
  df
}

results_list <- lapply(results$businesses, FUN = yelp_httr_parse)

payload <- do.call("rbind", results_list)
