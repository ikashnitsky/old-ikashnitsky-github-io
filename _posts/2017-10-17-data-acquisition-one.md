---
layout: article
title: "Data acquisition in R (1/4)"
image:
  teaser: 171017-teaser-one.png
---

R is an incredible tool for reproducible research. In the present series of blog posts I want to show how one can easily acquire data within an R session, documenting every step in a fully reproducible way. There are numerous data acquisition options for R users. Of course, I do not attempt to show all the data possibilities and tend to focus mostly on demographic data. If your prime interest lies outside human population statistics, it's worth checking the amazing [Open Data Task View][odata]. 

The series consists of four posts:
 - **Loading prepared datasets**
 - [Accessing popular statistical databases][two]
 - [Demographic data sources][three]
 - Getting spatial data
 
For each of the data acquisition options I provide a small visualization use case.

# Built-in datasets

For illustration purposes, many R packages include data samples. Base R comes with a `datasets` package that offers a wide range of simple, sometimes very famous, datasets. Quite a detailed list of built-in datasets from various packages is [maintained by Vincent Arel-Bundock][list]. 

The nice feature of the datasets form `datasets` package is that they are "always there". The unique names of the datasets may be referred as the objects from Global Environment. Let's have a look at a beautiful small dataset calls `swiss` - Swiss Fertility and Socioeconomic Indicators (1888) Data. I am going to check visually the difference in fertility based of rurality and domination of Catholic population. 

```
library(tidyverse)

swiss %>% 
        ggplot(aes(x = Agriculture, y = Fertility, 
                   color = Catholic > 50))+
        geom_point()+
        stat_ellipse()+
        theme_minimal(base_family = "mono")
```

[![fig1][f1]][f1]  

# Gapminder

Some packages are created specifically to disseminate datasets in a ready to use format. One of the nice examples is a package `gapminder` that contains a neat dataset widely used by Hans Rosling in his Gapminder project.

```
library(tidyverse)
library(gapminder)

gapminder %>% 
        ggplot(aes(x = year, y = lifeExp, 
                   color = continent))+
        geom_jitter(size = 1, alpha = .2, width = .75)+
        stat_summary(geom = "path", fun.y = mean, size = 1)+
        theme_minimal(base_family = "mono")
```

[![fig2][f2]][f2]  


# Grab a dataset by URL

If a dataset is hosted online and has a direct link to the file, it can be easily imported into the R session just specifying the URL. For illustration, I will access `Galton` dataset from `HistData` package using a direct link from [Vincent Arel-Bundock's list][list]. 

```
library(tidyverse)

galton <- read_csv("https://raw.githubusercontent.com/vincentarelbundock/Rdatasets/master/csv/HistData/Galton.csv")

galton %>% 
        ggplot(aes(x = father, y = height))+
        geom_point(alpha = .2)+
        stat_smooth(method = "lm")+
        theme_minimal(base_family = "mono")
```

[![fig3][f3]][f3]  


# Download and unzip an archive

Quite often datasets are stored in archived from. With R it is very simple to download and unzip the desired data archives. As an example, I will download [Historical New York City Crime Data][ny] provided by the Government of the Sate of New York and hosted at data.gov portal. The logic of the process is: first, we create a directory for the unzipped data; second, we download the archive; finally, unzip the archive and read the data.

```
library(tidyverse)
library(readxl)

# create a directory for the unzipped data
ifelse(!dir.exists("unzipped"), dir.create("unzipped"), "Directory already exists")

# specify the URL of the archive
url_zip <- "http://www.nyc.gov/html/nypd/downloads/zip/analysis_and_planning/citywide_historical_crime_data_archive.zip"

# storing the archive in a temporary file
f <- tempfile()
download.file(url_zip, destfile = f)
unzip(f, exdir = "unzipped/.")
```

If the zipped file is rather big and we don't want to download it again the next time we run the code, it might be useful to keep the archived data.

```
# if we want to keep the .zip file
path_unzip <- "unzipped/data_archive.zip"
ifelse(!file.exists(path_unzip), 
       download.file(url_zip, path_unzip, mode="wb"), 
       'file alredy exists')
unzip(path_unzip, exdir = "unzipped/.")

```

Finally, let's read and plot some of the downloaded data.

```
murder <- read_xls("unzipped/Web Data 2010-2011/Seven Major Felony Offenses 2000 - 2011.xls",
                   sheet = 1, range = "A5:M13") %>% 
        filter(OFFENSE %>% substr(1, 6) == "MURDER") %>% 
        gather("year", "value", 2:13) %>% 
        mutate(year = year %>% as.numeric())

murder %>% 
        ggplot(aes(year, value))+
        geom_point()+
        stat_smooth(method = "lm")+
        theme_minimal(base_family = "mono")+
        labs(title = "Murders in New York")
```

[![fig4][f4]][f4]  


# Figshare

In Academia it is becoming more and more popular to store the datasets accompanying papers in the specialized repositories. Figshare is one of the most popular free repositories. There is an R package `rfigshare` to access the datasets from this portal. As an example I will grab [the dataset on ice-hockey playes height][figshare] that I assembled manually for [my blog post][ice]. Please note that at the first run the package will ask to enter your Figshare login details to access API - a web page will be opened in browser. 

There is a search function `fs_search`, though my experience shows that it is easier to search for a dataset in a browser and then use the id of a file to download it. The function `fs_download` turns an id number into a direct URL to download the file.

```
library(tidyverse)
library(rfigshare)

url <- fs_download(article_id = "3394735")

hockey <- read_csv(url)

hockey %>% 
        ggplot(aes(x = year, y = height))+
        geom_jitter(size = 2, color = "#35978f", alpha = .1, width = .25)+
        stat_smooth(method = "lm", size = 1)+
        ylab("height, cm")+
        xlab("year of competition")+
        scale_x_continuous(breaks = seq(2005, 2015, 5), labels = seq(2005, 2015, 5))+
        theme_minimal(base_family = "mono")
```

[![fig5][f5]][f5]  


# Full reproducibility
All the code chunks can be found in [this gist][gist].



[f1]: https://ikashnitsky.github.io/images/171017/swiss.png
[f2]: https://ikashnitsky.github.io/images/171017/gapminder.png
[f3]: https://ikashnitsky.github.io/images/171017/galton.png
[f4]: https://ikashnitsky.github.io/images/171017/new-york.png
[f5]: https://ikashnitsky.github.io/images/171017/ice-hockey.png

[two]: https://ikashnitsky.github.io/2017/data-acquisition-two
[three]: https://ikashnitsky.github.io/2017/data-acquisition-three
[odata]: https://github.com/ropensci/opendata
[list]: https://vincentarelbundock.github.io/Rdatasets/datasets.html
[ny]: https://catalog.data.gov/dataset/historical-new-york-city-crime-data-ad47e
[figshare]: https://dx.doi.org/10.6084/m9.figshare.3394735.v2
[ice]: https://ikashnitsky.github.io/2017/ice-hockey-players-height/
[gist]: https://gist.github.com/ikashnitsky/e1d93a51fe5e2b5ba770096060bacd8a