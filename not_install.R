# installing for marta
install.packages('caret')
install.packages('fairness')
install.packages('glmnet')

# intstalling knitting needs
install.packages('rmarkdown')

docker run --rm -p 127.0.0.1:8787:8787 -e DISABLE_AUTH=true rocker/tidyverse