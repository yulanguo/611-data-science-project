FROM rocker/rstudio:latest
RUN R -e 'install.packages("tidyverse")'
RUN R -e 'install.packages("scales")'
RUN R -e 'install.packages("rmarkdown")'
RUN R -e 'install.packages("knitr")'
