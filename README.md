# Model-Evaluation-Activity

This folder contains three files: 
1) the training data, a simulated dataset used to train our model
2) the testing data, a simulated dataset used to perform an intersectional bias assessment
3) R script, containing code to train and evaluate the model and examine the model features

https://mybinder.org/v2/gh/edickie/Model-Evaluation-Activity.git/HEAD?urlpath=rstudio

Rstudio [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/edickie/Model-Evaluation-Activity.git/HEAD?urlpath=rstudio)

Note - if running on Binder - rstudio is version 1.2.5 and R is version

## for testing with R versions
docker run --rm -p 127.0.0.1:8787:8787 -e DISABLE_AUTH=true rocker/tidyverse

## notes for things I tried to test
 - r binder with the conda-forge r install doesn't work for 4.1
 - r binder with timestamp for r installs with 4.0 at highest (but 1.2.5 rstudio)
 - rocker/binder container for 4.1 fails to launch
 - 