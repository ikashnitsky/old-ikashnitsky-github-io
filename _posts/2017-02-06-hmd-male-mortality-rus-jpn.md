---
layout: article
title: "Male mortality in Russia and Japan"
image:
  teaser: 170206-teaser.png
comments: true
---

Russia is sadly notorious for its ridiculously high adult male mortality. According to [Human Mortality Database data (2010)](http://www.mortality.org), the probability for a Russian men to survive from 20 to 60 was just 0.64 [^1]. For women the probability is 0.87. This huge gender disproportion in mortality results in a peculiar sex ratio profile (see [my old DemoTrends post](https://demotrends.wordpress.com/2015/01/14/the-land-of-babushka/) and [the previous blog post](https://ikashnitsky.github.io/2017/hmd-sex-all-ratio)).  

Now let's compare age-specific mortality rates of Russian men to that of the Japanese. For years and years Japan performs best in reducing mortality. It became standard to compare mortality schedules of other countries to the Japanese one [^2]. 

First, I need to get HMD data for both Russian and Japanese males. Again, I am using the amazing `R` package `HMDHFDplus` of [Tim Riffe](https://sites.google.com/site/timriffepersonal/) to download HMD data with just a couple of lines of `R` code. 


```
# load required packages
library(tidyverse) # version 1.0.0
library(HMDHFDplus) # version 1.1.8

# load life tables for men, RUS and JPN
rus <- readHMDweb('RUS', "mltper_1x1", ik_user_hmd, ik_pass_hmd)
jpn <- readHMDweb('JPN', "mltper_1x1", ik_user_hmd, ik_pass_hmd)
```

*Please note, the arguments `ik_user_hmd` and `ik_pass_hmd` are my login credidantials at the website of [Human Mortality Database](http://www.mortality.org), which are stored locally at my computer. In order to access the data, one needs to create an account at http://www.mortality.org/ and provide his own credidantials to the `readHMDweb()` function.*

Next, I select the most recent year for comparison, 2014, and compute the rate ratio of age specific mortality rates. 

```
# compare mortality rates for 2014
ru <- rus %>% filter(Year == 2014) %>% transmute(age = Age, rus = mx)
jp <- jpn %>% filter(Year == 2014) %>% transmute(age = Age, jpn = mx)
df <- left_join(jp, ru, 'age') %>% mutate(ru_rate = rus / jpn)
```

Finally, I plot the resulting rate ratio of male mortality in Russia and Japan.

```
# get nice font
library(extrafont)
myfont <- "Roboto Condensed"

# plot
gg <- ggplot(df, aes(age, ru_rate)) + 
        geom_hline(yintercept = 1, color = 'red') +
        geom_line(aes(group=1)) + 
        scale_y_continuous('mortality rate ratio',
                           breaks = 0:10, labels = 0:10, limits = c(0, 10)) +
        annotate('text',x=c(0, 55), y = c(1.75,5), 
                 color = c('red','black'), hjust = 0, vjust = 1, size = 7,
                 label = c('Japan','Russia'), family = myfont) +
        ggtitle('Compare age-specific mortality of males',
                subtitle = "Russia and Japan, 2014, HMD")+
        theme_bw(base_size = 15, base_family = myfont)
```

[![gg][f1]][f1]



In the middle ages, male mortality in Russian is up to 10 times higher than in Japan!

*This post is based on my earlier [tweet](https://twitter.com/ikashnitsky/status/792305556132331520) and [gist](https://gist.github.com/ikashnitsky/8df43c9a5dcd1798116ba09b336cdcf2).*

***

[f1]: /images/170206/male-mortality-compare.png

[^1]: To compare, the same probabilities for males in some developed countries are: France (0.89), Japan (0.92), US (0.87), UK (0.91). 
[^2]: See for example the recent [NIDI working paper of Balachandran et. al (2017)](http://www.nidi.nl/shared/content/output/papers/nidi-wp-2017-01.pdf).