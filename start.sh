docker build . -t b611 --platform=linux/arm64
docker run --platform=linux/arm64 -v $(pwd):/home/rstudio/work -p 8787:8787 -it b611
