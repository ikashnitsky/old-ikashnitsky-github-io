---
layout: article
title: "The easiest way to radically improve map aesthetics"
image:
  teaser: 211119-teaser.png
---

Since R community developed brilliant tools to deal with spatial data, producing maps is no longer the privilege of a narrow group of people with very specific knowledge, skillset, and often super expensive software. With #rspatial packages, maps (at least the relatively simple ones) became just another type of dataviz. Just a few lines of code can reveal the eye-catching and visually pleasant spatial dimension of the data. Similarly, a few more lines of code can radically improve the pleasantness of a simple map -- add borders as lines in a separate spatial layer. 

An often "quick and dirty" solution when composing a simple choropleth map is to use polygons outline as the borders. While this works okay to distinguish the polygons, the map looks overloaded if the non-bordering outline, which is most often the coastal line, is complicated. If there are islands, the polygon outlines around them look ugly. 


## Replication 
https://gist.github.com/ikashnitsky/cf2c29a29d39f79bb1c857a4fefc2cd4

## Twitter thread
This post is based on my previous Twitter thread. 
https://twitter.com/ikashnitsky/status/1247875600305598464