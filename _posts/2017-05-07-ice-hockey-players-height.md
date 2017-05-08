---
title: "Evolution of ice hockey players' height: IIHF world championships 2001-2016"
layout: article
image:
  teaser: 170507-teaser.png
---

The 2017 Ice Hockey World Championship has started. Thus I want to share a small research on the height of ice hockey players that I did almost a year ago and [published in Russian][habr].   

When the TV camera shows the players returning to the changing rooms, it is difficult not to notice just how huge the players are compared to the surrounding people -- fans, journalists, coaches, or the ice arena workers. For example, here are the rising stars of the Finnish hockey -- Patrik Laine and Aleksander Barkov -- with the two fans in between.

[![fig0][f0s]][f0]  
*[Source][photo]*

So the questions arise. Are ice hockey players really taller than average people? How is the height of ice hockey players evolving over time? Are there any lasting differences between countries?

# Data

IIHF, the organization that is in charge for the ice hockey world championships, publishes detailed information on the squads, including the data on player's height and weight. The raw data files are [here][raw]. I gathered the data of all players that participated in the 16 world championships between 2001 and 2016. The formatting of the data files changes from year to year complicating the data processing. So I did the data cleaning manually which took a bit more than 3 hours. The unifies dataset is [here][data]. Let's load the data and prepare the R session.

```
# load required packages
library(tidyverse) # data manipulation and viz
library(lubridate) # easy manipulations with dates
library(ggthemes) # themes for ggplot2
library(texreg) # easy export of regression tables
library(xtable) # export a data frame into an html table
library(sysfonts) # change the font in figures


# download the IIHF data set; if there are some problems, you can download manually
# using the stable URL (https://dx.doi.org/10.6084/m9.figshare.3394735.v2)
df <- read.csv("https://ndownloader.figshare.com/files/5303173")

# color palette
brbg11 <- RColorBrewer::brewer.pal(11, "BrBG")
```

# Do the players become taller? (a crude comparison)

Let's first have a look at the pulled average height of all the players that participated.

```
# mean height by championship
df_per <- df %>% group_by(year) %>%
        summarise(height = mean(height))

gg_period_mean <- ggplot(df_per, aes(x = year, y = height))+
        geom_point(size = 3, color = brbg11[9])+
        stat_smooth(method = "lm", size = 1, color = brbg11[11])+
        ylab("height, cm")+
        xlab("year of competition")+
        scale_x_continuous(breaks = seq(2005, 2015, 5), labels = seq(2005, 2015, 5))+
        theme_few(base_size = 15, base_family = "mono")+
        theme(panel.grid = element_line(colour = "grey75", size = .25))


gg_period_jitter <- ggplot(df, aes(x = year, y = height))+
        geom_jitter(size = 2, color = brbg11[9], alpha = .25, width = .75)+
        stat_smooth(method = "lm", size = 1, se = F, color = brbg11[11])+
        ylab("height, cm")+
        xlab("year of competition")+
        scale_x_continuous(breaks = seq(2005, 2015, 5), labels = seq(2005, 2015, 5))+
        theme_few(base_size = 15, base_family = "mono")+
        theme(panel.grid = element_line(colour = "grey75", size = .25))

gg_period <- cowplot::plot_grid(gg_period_mean, gg_period_jitter)
```

[![fig1][f1s]][f1]  

**Figure 1. The dynamics of the average height of the ice hockey players at the world championships, 2001--2016**

The positive trend is evident. In the 15 years the average height of a player increased by almost 2 cm (left panel). Is that a lot? To have an idea, we will compare this growth to the dynamics in the population, later in the post.

# Cohort approach

A more correct way to study the dynamics of players' height is to do the comparison between birth cohorts. Here we face an interesting data preparation issue -- some of the players participated in more that one championships. The question is: do we need to clean the duplicate records? If the goal is to see the average height of a player  at the certain championship (as in Figure 1), it is reasonable to keep all the records. Alternatively, if the aim is to analyze the dynamics of players' height itself, I argue, it would be wrong to assign bigger weight to those players that participated in more that one championship. Thus, for the further cohort analysis, I cleaned the dataset from the duplicates.

```
dfu_h <- df %>% select(year, name, country, position, birth, cohort, height) %>%
        spread(year, height)
dfu_h$av.height <- apply(dfu_h[, 6:21], 1, mean, na.rm = T)
dfu_h$times_participated <- apply(!is.na(dfu_h[, 6:21]), 1, sum)

dfu_w <- df %>% select(year, name, country, position, birth, cohort, weight) %>%
        spread(year, weight)
dfu_w$av.weight <- apply(dfu_w[, 6:21], 1, mean, na.rm = T)


dfu <- left_join(dfu_h %>% select(name, country, position, birth, cohort, av.height, times_participated), 
                 dfu_w %>% select(name, country, position, birth, cohort, av.weight), 
                 by = c("name", "country", "position", "birth", "cohort")) %>%
        mutate(bmi = av.weight / (av.height / 100) ^ 2)
```

The total number of observations decreased from 6292 to 3333. For those who participated in more that one championship, I averaged the data on height and weight as they can change during the life-course. How many times, on average, are ice hockey players honored to represent their countries in the world championships? A bit less than 2.

```
# frequencies of participation in world championships
mean(dfu$times_participated)

df_part <- as.data.frame(table(dfu$times_participated))

gg_times_part <- ggplot(df_part, aes(y = Freq, x = Var1))+
        geom_bar(stat = "identity", fill = brbg11[8])+
        ylab("# of players")+
        xlab("times participated (out of 16 possible)")+
        theme_few(base_size = 15, base_family = "mono")+
        theme(panel.grid = element_line(colour = "grey75", size = .25))
```

[![fig2][f2s]][f2]   

**Figure 2. Histogram of the players by the number of times they participated in world championships over the period 2001-2016.**

But there are unique players that participated in a considerable number of championships. Let's have a look at those who participated at least 10 times out of 16 possible. There were just 14 such players.

```
# the leaders of participation in world championships
leaders <- dfu %>% filter(times_participated > 9)
View(leaders)
# save the table to html
print(xtable(leaders), type = "html", file = "table_leaders.html")
```

**Table 1. The most frequently participated players**  
<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:3px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:3px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}
.tg .tg-ls8f{font-family:Georgia, serif !important;}
.tg .tg-oa1s{font-weight:bold;font-family:Georgia, serif !important;}
.tg .tg-jrsh{font-family:Georgia, serif !important;;text-align:center}
.tg .tg-lyle{font-weight:bold;font-family:Georgia, serif !important;;text-align:center}
</style>
<table class="tg">
  <tr>
    <th class="tg-oa1s">name </th>
    <th class="tg-lyle"> country </th>
    <th class="tg-lyle"> position </th>
    <th class="tg-lyle"> birth date</th>
    <th class="tg-lyle"> cohort </th>
    <th class="tg-lyle"> av.height </th>
    <th class="tg-lyle"> times _participated </th>
    <th class="tg-lyle"> av.weight </th>
    <th class="tg-lyle"> bmi </th>
  </tr>
  <tr>
    <td class="tg-ls8f"> ovechkin alexander </td>
    <td class="tg-jrsh"> RUS </td>
    <td class="tg-jrsh"> F </td>
    <td class="tg-jrsh"> 1985-09-17 </td>
    <td class="tg-jrsh"> 1985 </td>
    <td class="tg-jrsh"> 188.45 </td>
    <td class="tg-jrsh">  11 </td>
    <td class="tg-jrsh"> 98.36 </td>
    <td class="tg-jrsh"> 27.70 </td>
  </tr>
  <tr>
    <td class="tg-ls8f"> nielsen daniel </td>
    <td class="tg-jrsh"> DEN </td>
    <td class="tg-jrsh"> D </td>
    <td class="tg-jrsh"> 1980-10-31 </td>
    <td class="tg-jrsh"> 1980 </td>
    <td class="tg-jrsh"> 182.27 </td>
    <td class="tg-jrsh">  11 </td>
    <td class="tg-jrsh"> 79.73 </td>
    <td class="tg-jrsh"> 24.00 </td>
  </tr>
  <tr>
    <td class="tg-ls8f"> staal kim </td>
    <td class="tg-jrsh"> DEN </td>
    <td class="tg-jrsh"> F </td>
    <td class="tg-jrsh"> 1978-03-10 </td>
    <td class="tg-jrsh"> 1978 </td>
    <td class="tg-jrsh"> 182.00 </td>
    <td class="tg-jrsh">  10 </td>
    <td class="tg-jrsh"> 87.80 </td>
    <td class="tg-jrsh"> 26.51 </td>
  </tr>
  <tr>
    <td class="tg-ls8f"> green morten </td>
    <td class="tg-jrsh"> DEN </td>
    <td class="tg-jrsh"> F </td>
    <td class="tg-jrsh"> 1981-03-19 </td>
    <td class="tg-jrsh"> 1981 </td>
    <td class="tg-jrsh"> 183.00 </td>
    <td class="tg-jrsh">  12 </td>
    <td class="tg-jrsh"> 85.83 </td>
    <td class="tg-jrsh"> 25.63 </td>
  </tr>
  <tr>
    <td class="tg-ls8f"> masalskis edgars </td>
    <td class="tg-jrsh"> LAT </td>
    <td class="tg-jrsh"> G </td>
    <td class="tg-jrsh"> 1980-03-31 </td>
    <td class="tg-jrsh"> 1980 </td>
    <td class="tg-jrsh"> 176.00 </td>
    <td class="tg-jrsh">  12 </td>
    <td class="tg-jrsh"> 79.17 </td>
    <td class="tg-jrsh"> 25.56 </td>
  </tr>
  <tr>
    <td class="tg-ls8f"> ambuhl andres </td>
    <td class="tg-jrsh"> SUI </td>
    <td class="tg-jrsh"> F </td>
    <td class="tg-jrsh"> 1983-09-14 </td>
    <td class="tg-jrsh"> 1983 </td>
    <td class="tg-jrsh"> 176.80 </td>
    <td class="tg-jrsh">  10 </td>
    <td class="tg-jrsh"> 83.70 </td>
    <td class="tg-jrsh"> 26.78 </td>
  </tr>
  <tr>
    <td class="tg-ls8f"> granak dominik </td>
    <td class="tg-jrsh"> SVK </td>
    <td class="tg-jrsh"> D </td>
    <td class="tg-jrsh"> 1983-06-11 </td>
    <td class="tg-jrsh"> 1983 </td>
    <td class="tg-jrsh"> 182.00 </td>
    <td class="tg-jrsh">  10 </td>
    <td class="tg-jrsh"> 79.50 </td>
    <td class="tg-jrsh"> 24.00 </td>
  </tr>
  <tr>
    <td class="tg-ls8f"> madsen morten </td>
    <td class="tg-jrsh"> DEN </td>
    <td class="tg-jrsh"> F </td>
    <td class="tg-jrsh"> 1987-01-16 </td>
    <td class="tg-jrsh"> 1987 </td>
    <td class="tg-jrsh"> 189.82 </td>
    <td class="tg-jrsh">  11 </td>
    <td class="tg-jrsh"> 86.00 </td>
    <td class="tg-jrsh"> 23.87 </td>
  </tr>
  <tr>
    <td class="tg-ls8f"> redlihs mikelis </td>
    <td class="tg-jrsh"> LAT </td>
    <td class="tg-jrsh"> F </td>
    <td class="tg-jrsh"> 1984-07-01 </td>
    <td class="tg-jrsh"> 1984 </td>
    <td class="tg-jrsh"> 180.00 </td>
    <td class="tg-jrsh">  10 </td>
    <td class="tg-jrsh"> 80.40 </td>
    <td class="tg-jrsh"> 24.81 </td>
  </tr>
  <tr>
    <td class="tg-ls8f"> cipulis martins </td>
    <td class="tg-jrsh"> LAT </td>
    <td class="tg-jrsh"> F </td>
    <td class="tg-jrsh"> 1980-11-29 </td>
    <td class="tg-jrsh"> 1980 </td>
    <td class="tg-jrsh"> 180.70 </td>
    <td class="tg-jrsh">  10 </td>
    <td class="tg-jrsh"> 82.10 </td>
    <td class="tg-jrsh"> 25.14 </td>
  </tr>
  <tr>
    <td class="tg-ls8f"> holos jonas </td>
    <td class="tg-jrsh"> NOR </td>
    <td class="tg-jrsh"> D </td>
    <td class="tg-jrsh"> 1987-08-27 </td>
    <td class="tg-jrsh"> 1987 </td>
    <td class="tg-jrsh"> 180.18 </td>
    <td class="tg-jrsh">  11 </td>
    <td class="tg-jrsh"> 91.36 </td>
    <td class="tg-jrsh"> 28.14 </td>
  </tr>
  <tr>
    <td class="tg-ls8f"> bastiansen anders </td>
    <td class="tg-jrsh"> NOR </td>
    <td class="tg-jrsh"> F </td>
    <td class="tg-jrsh"> 1980-10-31 </td>
    <td class="tg-jrsh"> 1980 </td>
    <td class="tg-jrsh"> 190.00 </td>
    <td class="tg-jrsh">  11 </td>
    <td class="tg-jrsh"> 93.64 </td>
    <td class="tg-jrsh"> 25.94 </td>
  </tr>
  <tr>
    <td class="tg-ls8f"> ask morten </td>
    <td class="tg-jrsh"> NOR </td>
    <td class="tg-jrsh"> F </td>
    <td class="tg-jrsh"> 1980-05-14 </td>
    <td class="tg-jrsh"> 1980 </td>
    <td class="tg-jrsh"> 185.00 </td>
    <td class="tg-jrsh">  10 </td>
    <td class="tg-jrsh"> 88.30 </td>
    <td class="tg-jrsh"> 25.80 </td>
  </tr>
  <tr>
    <td class="tg-ls8f"> forsberg kristian </td>
    <td class="tg-jrsh"> NOR </td>
    <td class="tg-jrsh"> F </td>
    <td class="tg-jrsh"> 1986-05-05 </td>
    <td class="tg-jrsh"> 1986 </td>
    <td class="tg-jrsh"> 184.50 </td>
    <td class="tg-jrsh">  10 </td>
    <td class="tg-jrsh"> 87.50 </td>
    <td class="tg-jrsh"> 25.70 </td>
  </tr>
</table>

Alexander Ovechkin -- 11 times! But it has to be noted that not every player had a possibility to participate in all the 16 championships between 2001 and 2016. That depends on a numder of factors:  
 - the birth cohort of the player; 
 - whether his national team regularly qualified for the championship (Figure 3); 
 - whether the player was good enough for the national team; 
 - whether he was free from the NHL play-offs that often keep the best players off the world championships.

```
# countries times participated
df_cnt_part <- df %>% select(year, country, no) %>%
        mutate(country = factor(paste(country))) %>%
        group_by(country, year) %>%
        summarise(value = sum(as.numeric(no))) %>%
        mutate(value = 1) %>%
        ungroup() %>%
        mutate(country = factor(country, levels = rev(levels(country))), 
               year = factor(year))

d_cnt_n <- df_cnt_part %>% group_by(country) %>%
        summarise(n = sum(value))

gg_cnt_part <- ggplot(data = df_cnt_part, aes(x = year, y = country))+
        geom_point(color = brbg11[11], size = 7)+
        geom_text(data = d_cnt_n, aes(y = country, x = 17.5, label = n, color = n), size = 7, fontface = 2)+
        geom_text(data = d_cnt_n, aes(y = country, x = 18.5, label = " "), size = 7)+
        scale_color_gradientn(colours = brbg11[7:11])+
        xlab(NULL)+
        ylab(NULL)+
        theme_bw(base_size = 25, base_family = "mono")+
        theme(legend.position = "none", 
              axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
```

[![fig3][f3s]][f3]  

**Figure 3. Stats of the national teams participation in the world championships**

# Do the ice hochey players become taller? (regression analysis)

The regression analysis allows to address the research question -- the association between player's height and birth cohort -- accounting for the cross-national differences and player's position. I use OLS regressions, that are quite sensitive to outliers. I removed the birth cohorts for which there are less than 10 players -- 1963, 1997, and 1998.

```
# remove small cohorts
table(dfu$cohort)
dfuc <- dfu %>% filter(cohort < 1997, cohort > 1963)
```

So, the results. I add the variables one by one.

**Dependent variable**: player's height.  
**Explaining variables**: 1) birth cohort; 2) position (compared to defenders); 3) country (compared to Russia).

```
# relevel counrty variable to compare with Russia
dfuc$country <- relevel(dfuc$country, ref = "RUS")

# regression models
m1 <- lm(data = dfuc, av.height~cohort)
m2 <- lm(data = dfuc, av.height~cohort+position)
m3 <- lm(data = dfuc, av.height~cohort+position+country)

# export the models to html
htmlreg(list(m1, m2, m3), file = "models_height.html", single.row = T)
```

**Table2. The models**  
<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:3px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:3px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}
.tg .tg-ls8f{font-family:Georgia, serif !important;}
.tg .tg-t6te{font-style:italic;font-family:Georgia, serif !important;;text-align:center}
.tg .tg-oa1s{font-weight:bold;font-family:Georgia, serif !important;}
.tg .tg-jrsh{font-family:Georgia, serif !important;;text-align:center}
.tg .tg-lyle{font-weight:bold;font-family:Georgia, serif !important;;text-align:center}
.tg .tg-mmdc{font-style:italic;font-family:Georgia, serif !important;}
</style>
<table class="tg">
  <tr>
    <th class="tg-oa1s"></th>
    <th class="tg-lyle">Model 1</th>
    <th class="tg-lyle">Model 2</th>
    <th class="tg-lyle">Model 3</th>
  </tr>
  <tr>
    <td class="tg-ls8f">(Intercept)</td>
    <td class="tg-jrsh">-10.17 (27.67)</td>
    <td class="tg-jrsh">-18.64 (27.01)</td>
    <td class="tg-jrsh">32.59 (27.00)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">cohort</td>
    <td class="tg-jrsh">0.10 (0.01)***</td>
    <td class="tg-jrsh">0.10 (0.01)***</td>
    <td class="tg-jrsh">0.08 (0.01)***</td>
  </tr>
  <tr>
    <td class="tg-ls8f">positionF</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-2.59 (0.20)***</td>
    <td class="tg-jrsh">-2.59 (0.20)***</td>
  </tr>
  <tr>
    <td class="tg-ls8f">positionG</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-1.96 (0.31)***</td>
    <td class="tg-jrsh">-1.93 (0.30)***</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryAUT</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-0.94 (0.55)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryBLR</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-0.95 (0.53)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryCAN</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">1.13 (0.46)*</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryCZE</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">0.56 (0.49)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryDEN</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-0.10 (0.56)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryFIN</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">0.20 (0.50)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryFRA</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-2.19 (0.69)**</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryGER</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-0.61 (0.51)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryHUN</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-0.61 (0.86)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryITA</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-3.58 (0.61)***</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryJPN</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-5.24 (0.71)***</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryKAZ</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-1.16 (0.57)*</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryLAT</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-1.38 (0.55)*</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryNOR</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-1.61 (0.62)**</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryPOL</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">0.06 (1.12)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countrySLO</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-1.55 (0.58)**</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countrySUI</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-1.80 (0.53)***</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countrySVK</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">1.44 (0.50)**</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countrySWE</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">1.18 (0.48)*</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryUKR</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">-1.82 (0.59)**</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryUSA</td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh"></td>
    <td class="tg-jrsh">0.54 (0.45)</td>
  </tr>
  <tr>
    <td class="tg-mmdc">R2</td>
    <td class="tg-t6te">0.01</td>
    <td class="tg-t6te">0.06</td>
    <td class="tg-t6te">0.13</td>
  </tr>
  <tr>
    <td class="tg-mmdc">Adj. R2</td>
    <td class="tg-t6te">0.01</td>
    <td class="tg-t6te">0.06</td>
    <td class="tg-t6te">0.12</td>
  </tr>
  <tr>
    <td class="tg-mmdc">Num. obs.</td>
    <td class="tg-t6te">3319</td>
    <td class="tg-t6te">3319</td>
    <td class="tg-t6te">3319</td>
  </tr>
  <tr>
    <td class="tg-mmdc">RMSE</td>
    <td class="tg-t6te">5.40</td>
    <td class="tg-t6te">5.27</td>
    <td class="tg-t6te">5.10</td>
  </tr>
</table>

**Model 1**. One year change in the birth cohort year is associated with an increase of 0.1 cm in height. The coefficient is statistically significant, yet the variable explains only 1% of the variance. That's not a big problem since the aim of the modeling is to document the differences, rather than predict based on the model. Nevertheless, the low coefficient of determination means that there are other variables that explain the differences in players' height better than just the birth cohort.

**Model 2.** Defenders are the tallest ice hockey players: goalkeepers are 2 cm shorter, forwards are 2.6 cm shorter. All the coefficients are significant; R squared rose to 6%. It is worth noting that the coefficient for the birth cohort did not change when we added the new variable.

**Model 3**. It is interesting to control for countries for two reasons. First, some of the differences are significant themselves.  For example, Swedes, Slovaks, and Canadians are higher than Russians. In contrast, Japanese are 5.2 cm shorter, Italians -- 3.6 cm, French -- 2.2 cm (figure 4). Second, once the country controls are introduced, the coefficient for birth cohort decreased slightly meaning that some of the differences in height are explained by persisting cross-country differences. R squared rose to 13%.

```
# players' height by country
gg_av.h_country <- ggplot(dfuc , aes(x = factor(cohort), y = av.height))+
        geom_point(color = "grey50", alpha = .25)+
        stat_summary(aes(group = country), geom = "line", fun.y = mean, size = .5, color = "grey50")+
        stat_smooth(aes(group = country, color = country), geom = "line", size = 1)+
        facet_wrap(~country, ncol = 4)+
        coord_cartesian(ylim = c(170, 195))+
        scale_x_discrete(labels = paste(seq(1970, 1990, 10)), breaks = paste(seq(1970, 1990, 10)))+
        labs(x = "birth cohort", y = "height, cm")+
        theme_few(base_size = 15, base_family = "mono")+
        theme(legend.position = "none", 
              panel.grid = element_line(colour = "grey75", size = .25))
```

[![fig4][f4s]][f4]  

**Figure 4. The height of ice hockey players by nations**

The last model indicates that from one birth cohort cohort to the other the height of ice hockey players increases 0.08 cm. That means an increase of 0.8 cm in a decade or a growth of 2.56 cm in the 32 years between 1964 and 1996. It is worth mentioning that once we run the analysis in cohorts and controlling for positions and nations, the speed of the player's height increase becomes much humbler than in the crude pulled analysis (Figure 1): 0.8 cm per decade compared to 1.2 cm per decade.

Before we go further and compare the growth in player's height to that of the population, let's do the modeling separately for defenders, goalkeepers, and forwards. The exploratory plot (Figure 5) suggests that the correlation is stronger for goalkeepers and weaker for defenders.

```
dfuc_pos <- dfuc
levels(dfuc_pos$position) <- c("Defenders", "Forwards", "Goalkeeprs")

gg_pos <- ggplot(dfuc_pos , aes(x = cohort, y = av.height))+
        geom_jitter(aes(color = position), alpha = .5, size = 2)+
        stat_smooth(method = "lm", se = T, color = brbg11[11], size = 1)+
        scale_x_continuous(labels = seq(1970, 1990, 10), breaks = seq(1970, 1990, 10))+
        scale_color_manual(values = brbg11[c(8, 9, 10)])+
        facet_wrap(~position, ncol = 3)+
        xlab("birth cohort")+
        ylab("height, cm")+
        theme_few(base_size = 15, base_family = "mono")+
        theme(legend.position = "none", 
              panel.grid = element_line(colour = "grey75", size = .25))
```
[![fig5][f5s]][f5]  

**Figure 5. Correlation between height and birth cohort by position**

```
# separate models for positions
m3d <- lm(data = dfuc %>% filter(position == "D"), av.height~cohort+country)
m3f <- lm(data = dfuc %>% filter(position == "F"), av.height~cohort+country)
m3g <- lm(data = dfuc %>% filter(position == "G"), av.height~cohort+country)
htmlreg(list(m3d, m3f, m3g), file = "models_height_pos.html", single.row = T, 
        custom.model.names = c("Model 3 D", "Model 3 F", "Model 3 G"))
```

**Table 3. Model 3 -- separately for defenders, forwards, and goalkeepers**  
<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:3px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:3px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}
.tg .tg-ls8f{font-family:Georgia, serif !important;}
.tg .tg-t6te{font-style:italic;font-family:Georgia, serif !important;;text-align:center}
.tg .tg-oa1s{font-weight:bold;font-family:Georgia, serif !important;}
.tg .tg-jrsh{font-family:Georgia, serif !important;;text-align:center}
.tg .tg-lyle{font-weight:bold;font-family:Georgia, serif !important;;text-align:center}
.tg .tg-mmdc{font-style:italic;font-family:Georgia, serif !important;}
</style>
<table class="tg">
  <tr>
    <th class="tg-oa1s"></th>
    <th class="tg-lyle">Model 3 D</th>
    <th class="tg-lyle">Model 3 F</th>
    <th class="tg-lyle">Model 3 G</th>
  </tr>
  <tr>
    <td class="tg-ls8f">(Intercept)</td>
    <td class="tg-jrsh">108.45 (46.46)*</td>
    <td class="tg-jrsh">49.32 (36.73)</td>
    <td class="tg-jrsh">-295.76 (74.61)***</td>
  </tr>
  <tr>
    <td class="tg-ls8f">cohort</td>
    <td class="tg-jrsh">0.04 (0.02)</td>
    <td class="tg-jrsh">0.07 (0.02)***</td>
    <td class="tg-jrsh">0.24 (0.04)***</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryAUT</td>
    <td class="tg-jrsh">0.14 (0.96)</td>
    <td class="tg-jrsh">-2.01 (0.75)**</td>
    <td class="tg-jrsh">0.47 (1.47)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryBLR</td>
    <td class="tg-jrsh">0.30 (0.87)</td>
    <td class="tg-jrsh">-1.53 (0.73)*</td>
    <td class="tg-jrsh">-2.73 (1.55)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryCAN</td>
    <td class="tg-jrsh">1.55 (0.78)*</td>
    <td class="tg-jrsh">0.39 (0.62)</td>
    <td class="tg-jrsh">3.45 (1.26)**</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryCZE</td>
    <td class="tg-jrsh">0.87 (0.84)</td>
    <td class="tg-jrsh">0.30 (0.67)</td>
    <td class="tg-jrsh">0.63 (1.36)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryDEN</td>
    <td class="tg-jrsh">-0.60 (0.95)</td>
    <td class="tg-jrsh">0.10 (0.75)</td>
    <td class="tg-jrsh">-0.19 (1.62)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryFIN</td>
    <td class="tg-jrsh">-0.55 (0.89)</td>
    <td class="tg-jrsh">-0.04 (0.67)</td>
    <td class="tg-jrsh">2.40 (1.32)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryFRA</td>
    <td class="tg-jrsh">-3.34 (1.15)**</td>
    <td class="tg-jrsh">-2.06 (0.93)*</td>
    <td class="tg-jrsh">1.39 (2.07)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryGER</td>
    <td class="tg-jrsh">0.48 (0.85)</td>
    <td class="tg-jrsh">-1.40 (0.72)</td>
    <td class="tg-jrsh">-0.65 (1.33)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryHUN</td>
    <td class="tg-jrsh">-1.32 (1.47)</td>
    <td class="tg-jrsh">-0.70 (1.16)</td>
    <td class="tg-jrsh">0.65 (2.39)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryITA</td>
    <td class="tg-jrsh">-2.08 (1.08)</td>
    <td class="tg-jrsh">-4.78 (0.82)***</td>
    <td class="tg-jrsh">-2.02 (1.62)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryJPN</td>
    <td class="tg-jrsh">-4.13 (1.26)**</td>
    <td class="tg-jrsh">-6.52 (0.94)***</td>
    <td class="tg-jrsh">-2.27 (1.98)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryKAZ</td>
    <td class="tg-jrsh">-1.23 (0.95)</td>
    <td class="tg-jrsh">-1.82 (0.79)*</td>
    <td class="tg-jrsh">1.79 (1.58)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryLAT</td>
    <td class="tg-jrsh">-0.73 (0.95)</td>
    <td class="tg-jrsh">-1.39 (0.75)</td>
    <td class="tg-jrsh">-3.42 (1.49)*</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryNOR</td>
    <td class="tg-jrsh">-3.25 (1.07)**</td>
    <td class="tg-jrsh">-1.06 (0.85)</td>
    <td class="tg-jrsh">-0.10 (1.66)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryPOL</td>
    <td class="tg-jrsh">0.82 (1.89)</td>
    <td class="tg-jrsh">-0.58 (1.55)</td>
    <td class="tg-jrsh">0.37 (2.97)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countrySLO</td>
    <td class="tg-jrsh">-1.57 (0.99)</td>
    <td class="tg-jrsh">-1.54 (0.79)</td>
    <td class="tg-jrsh">-2.25 (1.66)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countrySUI</td>
    <td class="tg-jrsh">-1.98 (0.91)*</td>
    <td class="tg-jrsh">-2.36 (0.71)***</td>
    <td class="tg-jrsh">1.12 (1.47)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countrySVK</td>
    <td class="tg-jrsh">2.94 (0.87)***</td>
    <td class="tg-jrsh">0.81 (0.67)</td>
    <td class="tg-jrsh">-0.70 (1.50)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countrySWE</td>
    <td class="tg-jrsh">0.75 (0.81)</td>
    <td class="tg-jrsh">1.24 (0.65)</td>
    <td class="tg-jrsh">1.37 (1.33)</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryUKR</td>
    <td class="tg-jrsh">-1.37 (1.01)</td>
    <td class="tg-jrsh">-1.77 (0.80)*</td>
    <td class="tg-jrsh">-3.71 (1.66)*</td>
  </tr>
  <tr>
    <td class="tg-ls8f">countryUSA</td>
    <td class="tg-jrsh">0.76 (0.78)</td>
    <td class="tg-jrsh">-0.08 (0.62)</td>
    <td class="tg-jrsh">2.58 (1.26)*</td>
  </tr>
  <tr>
    <td class="tg-mmdc">R2</td>
    <td class="tg-t6te">0.09</td>
    <td class="tg-t6te">0.10</td>
    <td class="tg-t6te">0.24</td>
  </tr>
  <tr>
    <td class="tg-mmdc">Adj. R2</td>
    <td class="tg-t6te">0.07</td>
    <td class="tg-t6te">0.09</td>
    <td class="tg-t6te">0.20</td>
  </tr>
  <tr>
    <td class="tg-mmdc">Num. obs.</td>
    <td class="tg-t6te">1094</td>
    <td class="tg-t6te">1824</td>
    <td class="tg-t6te">401</td>
  </tr>
  <tr>
    <td class="tg-mmdc">RMSE</td>
    <td class="tg-t6te">5.08</td>
    <td class="tg-t6te">5.08</td>
    <td class="tg-t6te">4.87</td>
  </tr>
</table>

The separate modeling shows that the average height of ice hockey players, that were born in 1964-1996 and participated in the world championships in 2001--2016, increased with the speed of 0.4 cm per decade for defenders, 0.7 cm -- for forwards, and (!) 2.4 cm -- for goalies. In three decades the average height of the goalkeepers increased by 7 cm!

Finally, let's compare these dynamics with those in the population.


# Compare to population

Our previous results expose significant height differences between players of various nations. Thus, it is reasonable to compare ice hockey players' height to the corresponding male population of their countries.

For the data on the height of males in population in the corresponding nations I used the [relevant scientific paper][hat]. I grabbed the data from the paper PDF using a nice little tool -- [tabula][tab] -- and also [deposited on figshare][cnt].

```
# download the data from Hatton, T. J., & Bray, B. E. (2010).
# Long run trends in the heights of European men, 19th–20th centuries.
# Economics & Human Biology, 8(3), 405–413.
# http://doi.org/10.1016/j.ehb.2010.03.001
# stable URL, copied data (https://dx.doi.org/10.6084/m9.figshare.3394795.v1)

df_hb <- read.csv("https://ndownloader.figshare.com/files/5303878") 

df_hb <- df_hb %>%
        gather("country", "h_pop", 2:16) %>%
        mutate(period = paste(period)) %>%
        separate(period, c("t1", "t2"), sep = "/")%>%
        transmute(cohort = (as.numeric(t1)+as.numeric(t2))/2, country, h_pop)

# calculate hockey players' cohort height averages for each country
df_hoc <- dfu %>% group_by(country, cohort) %>%
        summarise(h_hp = mean(av.height)) %>%
        ungroup()
```

Unfortunately, our dataset on ice hockey players intersects with the data on population only for 8 countries: Austria, Denmark, Finland, France, Germany, Italy, Norway, and Sweden.

```
# countries in both data sets
both_cnt <- levels(factor(df_hb$country))[which(levels(factor(df_hb$country)) %in% levels(df_hoc$country))]
both_cnt
```

```
gg_hoc_vs_pop <- ggplot()+
        geom_path(data = df_hb %>% filter(country %in% both_cnt), 
                  aes(x = cohort, y = h_pop), 
                  color = brbg11[9], size = 1)+
        geom_point(data = df_hb %>% filter(country %in% both_cnt), 
                   aes(x = cohort, y = h_pop), 
                   color = brbg11[9], size = 2)+
        geom_point(data = df_hb %>% filter(country %in% both_cnt), 
                   aes(x = cohort, y = h_pop), 
                   color = "white", size = 1.5)+
        geom_point(data = df_hoc %>% filter(country %in% both_cnt), 
                   aes(x = cohort, y = h_hp), 
                   color = brbg11[3], size = 2, pch = 18)+
        stat_smooth(data = df_hoc %>% filter(country %in% both_cnt), 
                    aes(x = cohort, y = h_hp), 
                    method = "lm", se = F, color = brbg11[1], size = 1)+
        facet_wrap(~country, ncol = 2)+
        labs(y = "height, cm", x = "birth cohort")+
        theme_few(base_size = 20, base_family = "mono")+
        theme(panel.grid = element_line(colour = "grey75", size = .25))
```

[![fig6][f6s]][f6]  

**Figure 6. The comparison of height dynamics in ice hockey players (brown) and the corresponding male populations (green)**

In all the analyzed countries, ice hockey players are 2-5 cm higher that the nation's average. This is not very surprising since we expect some selection in sport. What is more interesting, in the developed countries the rapid increase in the height of males mostly leveled off in the birth cohorts of 1960s. Unlike the population trend, the height of ice hockey players continued to increase with roughly the same pace in all the analyzed countries except for Denmark.  

For the cohorts of Europeans that were born in first half of 20-th century, the height of males increased by 1.18--1.74 cm per decade (Figure 7, middle panel). Starting from the birth cohorts of 1960s, the pace decreased to 0.15--0.80 per decade.


```
# growth in population

df_hb_w <- df_hb %>% spread(cohort, h_pop) 
names(df_hb_w)[2:26] <- paste("y", names(df_hb_w)[2:26])

diffs <- df_hb_w[, 3:26]-df_hb_w[, 2:25]

df_hb_gr<- df_hb_w %>%
        transmute(country, 
                  gr_1961_1980 = unname(apply(diffs[, 22:24], 1, mean, na.rm = T))*2, 
                  gr_1901_1960 = unname(apply(diffs[, 9:21], 1, mean, na.rm = T))*2, 
                  gr_1856_1900 = unname(apply(diffs[, 1:8], 1, mean, na.rm = T))*2) %>%
        gather("period", "average_growth", 2:4) %>%
        filter(country %in% both_cnt) %>%
        mutate(country = factor(country, levels = rev(levels(factor(country)))), 
               period = factor(period, labels = c("1856-1900", "1901-1960", "1961-1980")))


gg_hb_growth <- ggplot(df_hb_gr, aes(x = average_growth, y = country))+
        geom_point(aes(color = period), size = 3)+
        scale_color_manual(values = brbg11[c(8, 3, 10)])+
        scale_x_continuous(limits = c(0, 2.15))+
        facet_wrap(~period)+
        theme_few()+
        xlab("average growth in men's height over 10 years, cm")+
        ylab(NULL)+
        theme_few(base_size = 20, base_family = "mono")+
        theme(legend.position = "none", 
              panel.grid = element_line(colour = "grey75", size = .25))
```

[![fig7][f7s]][f7]  

**Figure 7. Average changes in male population**

The height increase for ice hockey players seems quite impressive if we compare it to the stagnating dynamics in the corresponding male populations. And the acceleration of goalkeepers' height is outright amazing.

The diverging trends in the height of ice hockey players and normal population is likely to be driven by the strengthening selection in sport.


# Selection in ice hockey

Looking through the literature on the selection in sport, I saw [the finding][sel] that showed a notable disproportion of professional sportsmen by the month of birth. There are much more sportsmen that were born in the first half of the year. They have a lasting advantage since the kids teams are usually formed by birth cohorts. Thus, those born earlier in the year always have a bit more time lived compared to their later born team mates, which means that they are physically more mature. It is easy to test the finding on our ice hockey players dataset.

```
# check if there are more players born in earlier months
df_month <- df %>% mutate(month = month(birth)) %>%
        mutate(month = factor(month))

gg_month <- ggplot(df_month, aes(x = factor(month)))+
        geom_bar(stat = "count", fill = brbg11[8])+
        scale_x_discrete(breaks = 1:12, labels = month.abb)+
        labs(x = "month of birth", y = "# of players")+
        theme_few(base_size = 20, base_family = "mono")+
        theme(legend.position = "none", 
              panel.grid = element_line(colour = "grey75", size = .25))
```

[![fig8][f8s]][f8]  

**Figure 8. The distribution of ice hockey players by month of birth**

True, the distribution is notably skewed -- there are much more players born in earlier months. When I further split the dataset by the decades of birth, it becomes clear that the effect becomes more evident with time (Figure 9). Indirectly, that means that the selection in ice hockey becomes tougher.

```
# facet by decades
df_month_dec <- df_month %>%
        mutate(dec = substr(paste(cohort), 3, 3) %>% 
                       factor(labels = paste("born in", c("1960s", "1970s", "1980s", "1990s"))))

gg_month_dec <- ggplot(df_month_dec, aes(x = factor(month)))+
        geom_bar(stat = "count", fill = brbg11[8])+
        scale_x_discrete(breaks = 1:12, labels = month.abb)+
        labs(x = "month of birth", y = "# of players")+
        facet_wrap(~dec, ncol = 2, scales = "free")+
        theme_few(base_size = 20, base_family = "mono")+
        theme(legend.position = "none", 
              panel.grid = element_line(colour = "grey75", size = .25))
```

[![fig9][f9s]][f9]  

**Figure 9. The distribution of ice hockey players by month of birth -- separately by decades of birth**


# Reproducibility
The full R script can be downloaded [here][code].  


[habr]: https://habrahabr.ru/post/301340/
[photo]: https://www.instagram.com/p/BFjNdn7zORh
[raw]: http://www.iihf.com/iihf-home/history/past-tournaments/
[data]: https://dx.doi.org/10.6084/m9.figshare.3394735.v2
[hat]: https://dx.doi.org/10.1016/j.ehb.2010.03.001
[tab]: http://tabula.technology/
[cnt]: https://dx.doi.org/10.6084/m9.figshare.3394795.v1
[sel]: https://dx.doi.org/10.1080/02640410600908001
[code]: https://dx.doi.org/10.6084/m9.figshare.3395983.v2

[f0]: https://ikashnitsky.github.io/images/170507/fig-00-laine-barkov.jpg
[f1]: https://ikashnitsky.github.io/images/170507/fig-01-period-height.png
[f2]: https://ikashnitsky.github.io/images/170507/fig-02-times-part.png
[f3]: https://ikashnitsky.github.io/images/170507/fig-03-countries-part.png
[f4]: https://ikashnitsky.github.io/images/170507/fig-04-height-by-country.png
[f5]: https://ikashnitsky.github.io/images/170507/fig-05-corr-by-pos.png
[f6]: https://ikashnitsky.github.io/images/170507/fig-06-players-vs-population.png
[f7]: https://ikashnitsky.github.io/images/170507/fig-07-av-growth-pop.png
[f8]: https://ikashnitsky.github.io/images/170507/fig-08-month-selectivity.png
[f9]: https://ikashnitsky.github.io/images/170507/fig-09-month-selectivity-decades.png

[f0s]: https://ikashnitsky.github.io/images/170507/s-fig-00.jpg
[f1s]: https://ikashnitsky.github.io/images/170507/s-fig-01.png
[f2s]: https://ikashnitsky.github.io/images/170507/s-fig-02.png
[f3s]: https://ikashnitsky.github.io/images/170507/s-fig-03.png
[f4s]: https://ikashnitsky.github.io/images/170507/s-fig-04.png
[f5s]: https://ikashnitsky.github.io/images/170507/s-fig-05.png
[f6s]: https://ikashnitsky.github.io/images/170507/s-fig-06.png
[f7s]: https://ikashnitsky.github.io/images/170507/s-fig-07.png
[f8s]: https://ikashnitsky.github.io/images/170507/s-fig-08.png
[f9s]: https://ikashnitsky.github.io/images/170507/s-fig-09.png
