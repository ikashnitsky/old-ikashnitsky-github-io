#===============================================================================
# 2022-06-22 -- ikashnistky.github.io
# Purify md
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com, @ikashnitsky
#===============================================================================


library(tidyverse)
library(magrittr)
library(fs)
library(glue)


# function to purify md ---------------------------------------------------

# th only input is the date of the thread as 6 digist, just like the folder
purify_md <- function(date_of_thread) {
  
  base_path <- here::here()
  post_path <- dir_ls("twitter/{date_of_thread}/" %>% glue)
  
  raw <- read_lines("{base_path}/{post_path[1]}" %>% glue)
  yaml <- read_lines("{base_path}/{post_path[2]}" %>% glue, n_max = 10)
  
  # append YAML and remove twitter clutter
  md <- c(yaml, raw) %>% 
    str_remove_all("&mdash.*</a>")
  
  md_name <- post_path[1] %>% str_remove_all(".*/")
  
  # write new md
  write_lines(out, "{base_path}/_posts/{md_name}" %>% glue)
  
}



# use on threads ----------------------------------------------------------

# 210305
purify_md(210305)
