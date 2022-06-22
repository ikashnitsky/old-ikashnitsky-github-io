#===============================================================================
# 2022-06-22 -- ikashnistky.github.io
# Get URLs of all tweets in a thread
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com, @ikashnitsky
#===============================================================================

# Solution from
# https://gist.github.com/gadenbuie/33c350458305f4423f30c1274be63b34

library(tidyverse)
library(magrittr)
library(rtweet)

# gather from last tweet to first tweet in the thread,
lookup_thread <- function(status_id, tweets = NULL) {
  tweet <- rtweet::lookup_tweets(status_id)
  tweets <- dplyr::bind_rows(tweet, tweets)
  if (is.na(tweet$reply_to_status_id)) {
    return(tweets)
  } else {
    lookup_thread(tweet$reply_to_status_id, tweets)
  }
}

# build URL paths
build_url_paths <- function(twdf) {
  twdf %>% 
    pull(status_id) %>% 
    paste0("https://twitter.com/ikashnitsky/status/", .)
}

# Life expectancy thread 2021-03-05
thread210305 <- lookup_thread("1367856057226301446")
thread210305 %>% build_url_paths %>% clipr::write_clip()
