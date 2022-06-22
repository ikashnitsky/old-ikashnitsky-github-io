#===============================================================================
# 2022-06-22 -- ikashnistky.github.io
# Purify md
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com, @ikashnitsky
#===============================================================================


library(tidyverse)
library(magrittr)
library(fs)

dir

raw <- read_lines("~/github/ikashnitsky.github.io/twitter/2021-03-05-life-expectancy-101.md")
yaml <- read_lines("~/github/ikashnitsky.github.io/twitter/2021-03-05-life-expectancy-101.rmd", n = 10)

# append YAML
md <- c(yaml, raw)

# remove twitter clutter
out <- md %>% 
  str_remove_all("</p>&mdash.*</a>")

# write new md
write_lines(out, "~/github/ikashnitsky.github.io/twitter/2021-03-05-life-expectancy-101.md")

# save the ouput to posts
file_copy(
  path = "2021-03-05-life-expectancy-101.md", 
  new_path = "~/github/ikashnitsky.github.io/_posts/2021-03-05-life-expectancy-101.md", overwrite = TRUE
)

