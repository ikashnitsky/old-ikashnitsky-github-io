---
layout: article
title: "Compare population age structures of Europe NUTS-3 regions and the US counties using ternary color-coding"
image:
  teaser: 181203-teaser.png
---

On 28 November 2018 I presented a poster at [Dutch Demography Day][nvd] in Utrecht. Here it is:

[![fig1][f1]][f1]  

The poster compares population age structures, represented as ternary compositions in three broad age groups, of European NUTS-3 regions and the United States counties. I used ternary color-coding, a dataviz approach that [Jonas Schöley][js] and me recently brought to R in [tricolore][tric] package. 

In these maps, each region's population age composition is uniquely color-coded. Colors show direction and magnitude of deviation from the center point, which represents the average age composition. Hue component of a color encodes the direction of deviation: towards yellow – more elderly population (65+); cyan – more people at working ages (15–64); magenta–more kids (<15).

Of course, NUTS-3 regions and the US counties are not perfect to compare; on average, NUTS-3 regions are roughly ten times bigger. That's why the colors for European regions look quite muted, they are closer to the grey average composition.


The poster won [NVD][nvd] Poster Award via online voting of the conference participants.

[![fig2][f2]][f2] 


# Replication

This time I layouted the poster in [Inkscape][ink] rather than arranging everything with hundreds of R code lines. But all the elements of the posted are reproducible with code from [this github repo][repo].


## SEE ALSO
 - [Kashnitsky, I., & Schöley, J. (2018). Regional population structures at a glance. _The Lancet_, 392(10143), 209–210.][tl]
 - [My PhD project -- Regional demographic convergence in Europe][proj]
 - [Paper (Schöley & Willekens 2017) with the initial ideas for tricolore package][demres17]
 - [An example of ternary colorcoding used to visualize cause-of-death data][dr18]



[nvd]: http://www.nvdemografie.nl/en/activities/dutch-demography-day/dutch-demography-day-2018
[js]: https://twitter.com/jschoeley
[tric]: https://cran.r-project.org/web/packages/tricolore/index.html
[ink]: https://inkscape.org
[repo]: https://github.com/ikashnitsky/compare-pop-eu-us

[tl]: https://doi.org/10.1186/s41118-017-0018-2
[proj]: https://osf.io/d4hjx/
[demres17]: https://doi.org/10.4054/DemRes.2017.36.21
[dr18]: https://github.com/ikashnitsky/demres-2018-geofacet




[f1]: https://ikashnitsky.github.io/images/181203/compare-poster.png
[f2]: https://ikashnitsky.github.io/images/181203/poster-award.png