rm(list = ls())

library(tidyverse)
library(RCurl)
library(jsonlite)
library(httr)
library(stringr)

#base URL for API - do not change
base_url = "https://api.sketchengine.eu/bonito/run.cgi/"

#username and API key - input your own details
my_username = "YOUR_USERNAME_HERE"
my_auth = "YOUR_AUTH_HERE"

#create variable with authentication details - will pass using GET later
auth <- authenticate(my_username, my_auth)

#parameters for the search (e.g., basic freq. search) - adapt as needed
#see Sketch Engine's API documentation for details
format = "json" #output format (e.g., json, csv)
corpname = "preloaded/ententen21_tt31" #corpus name (either predefined or your own)
method = "wordlist" #method (e.g., wordlist, wsketch etc.)
params = str_c("wltype=simple", "wlattr=word", "wlpat=", sep = "&") #set of parameters

#build URL from above variables
url = paste0(base_url, 
             method, "?", 
             str_c("corpname=", corpname, "&", "format=", format), 
             "&", params)

#load the dataset that we're taking data from (and potentially adding to)
initial_data <- read_csv("YOUR_DATA.csv")

#initialise an empty list to store API results
sketch_data <- tibble()

#words to search - can be just a list or point to column in dataset
#here, we'll use a column in initial_data
sketch_list <- unique(initial_data$COLUMN_NAME)

#loop over words in list
for (word in sketch_list) { #'for each word in list...'
  output <- GET(str_c(url, word), auth) %>% #add word as search term to url, 
                                            #fire off to SketchEngine along with 
                                            #my authentication info
    content() #pull out the content
  
  sketch_list <- c(sketch_list, list(output))  #append data from each loop run to list 
}
