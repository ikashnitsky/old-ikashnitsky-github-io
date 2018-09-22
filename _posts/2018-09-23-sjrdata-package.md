---
layout: article
title: "sjrdata: all SCImago Journal & Country Rank data, ready for R"
image:
  teaser: 180923-teaser.png
---


[![][logo]][logo]


SCImago Journal & Country Rank provides valuable estimates of academic journals' prestige. The data is freely available at https://www.scimagojr.com and is distributed for deeper analysis in forms of .csv and .xlsx files. I downloaded all the files and pooled them together, ready to be used in R. 

Basically, all the package gives you three easily accessible data frames: `sjr_journals` (Journal Rank), `sjr_countries` (Country Rank, year-by-year), and `sjr_countries_1996_2017` (Country Rank, all years together).

The whole process of data acquisition can be foun in the [github repo][repo] (`dev` directory) or this [gist][gist]. 


# How to use `sjrdata`

Install the package from github, load it and use the data. 

The instalation will take a while since the main dataset `sjr_journals` is pretty heavy (15.7MB compressed).

```
# install
devtools::install_github("ikashnitsky/sjrdata")

# load
library(sjrdata)

# use
View(sjr_countries)
```


# A couple of examples

Let's compare _Nature_ and _Science_.

```
library(tidyverse)
library(sjrdata)

sjr_journals %>%
    filter(title %in% c("Nature", "Science")) %>%
    ggplot(aes(cites_doc_2years, sjr, color = title))+
    geom_path(size = 1, alpha = .5)+
    geom_label(aes(label = year %>% str_sub(3, 4)),
              size = 3, label.padding = unit(.15, "line"))
```

[![][f1]][f1]


Several demographic journals.

```
sjr_journals %>%
    filter(title %in% c(
        "Demography",
        "Population and Development Review",
        "European Journal of Population",
        "Population Studies",
        "Demographic Research",
        "Genus"
    )) %>%
    ggplot(aes(cites_doc_2years, sjr, color = title))+
    geom_point()+
    stat_ellipse()+
    scale_color_brewer(palette = "Dark2")+
    coord_cartesian(expand = F)
```

[![][f2]][f2]


[logo]: https://ikashnitsky.github.io/images/180923/sjrdata-logo.png
[f1]: https://ikashnitsky.github.io/images/180923/nature-science.png
[f2]: https://ikashnitsky.github.io/images/180923/demographic-journals.png

[repo]: https://github.com/ikashnitsky/sjrdata 
[gist]: https://gist.github.com/ikashnitsky/3133422ef85ff3f3d65be9926d6bd990
