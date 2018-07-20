---
layout: article
title: "Regional population structures at a glance"
image:
  teaser: 180721-teaser.png
---

[![fig0][f0]][f0]  

I am happy to announce that our paper is [published today in _The Lancet_][doi]. 

> Kashnitsky, I., & Schöley, J. (2018). Regional population structures at a glance. _The Lancet_, 392(10143), 209–210. [https://doi.org/10.1016/S0140-6736(18)31194-2][doi]

# At a glance

Demographic history of a population is imprinted in its age structure. A meaningful representation of regional population age structures can tell numerous demographic stories – at a glance. To produce such a snapshot of regional populations, we use an innovative approach of _ternary colour coding_. 

Here is the map:

[![fig1][f1]][f1]  

# We let the data speak colours

With ternary colour coding, each element of a three-dimensional array of compositional data is represented with a unique colour. The resulting colours show direction and magnitude of deviations from the centrepoint, which represents the average age of the European population, and is dark grey. The hue component of a colour encodes the direction of deviation: yellow indicates an elderly population (>65 years), cyan indicates people of working age (15–64 years), and magenta indicates children (0–14 years).

The method is very flexible, and one can easily produce these meaningful colours using our [R package `tricolore`][tric]. Just explore the capabilities of the package in a built-in shiny app using the following lines of code:

```
install.packages("ticolore")
library(tricolore)
DemoTricolore()
```

# Replication materials [at github][repo]

# Folow us on Twitter: [@ikahhnitsky][ik], [@jschoeley][js].

## SEE ALSO
 - [**My PhD project -- Regional demographic convergence in Europe**][proj]
 - [Blog post on the first version of the map presented at Rostock Retreat Visualization in June 2017][post]
 - [Paper (Schöley & Willekens 2017) with the initial ideas for tricolore package][dr17]
 - [An example of ternary colorcoding used to visualize cause-of-death data][dr18]
 - [My other paper , which explores regional differences in population age structures][genus]




[f0]: https://ikashnitsky.github.io/images/180721/full-text.png
[f1]: https://ikashnitsky.github.io/images/180721/the-map.png

[doi]: https://doi.org/10.1016/S0140-6736(18)31194-2
[tric]: https://github.com/jschoeley/tricolore
[repo]: https://github.com/ikashnitsky/the-lancet-2018
[ik]: https://twitter.com/ikashnitsky
[js]: https://twitter.com/jschoeley

[genus]: https://doi.org/10.1186/s41118-017-0018-2
[proj]: https://osf.io/d4hjx/
[post]: https://ikashnitsky.github.io/2017/colorcoded-map/
[dr17]: https://doi.org/10.4054/DemRes.2017.36.21
[dr18]: https://github.com/ikashnitsky/demres-2018-geofacet