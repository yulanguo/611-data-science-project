FROM rocker/rstudio:latest
RUN R -e 'install.packages("tidyverse")'
