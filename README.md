# Model-Evaluation-Activity

This folder contains three files: 
1. `train.csv`: the training data, a simulated dataset used to train our model
2. `test.csv` the testing data, a simulated dataset used to perform an intersectional bias assessment
3. `BiasAssessmentActivity_Script.R`: R script, containing code to train and evaluate the model and examine the model features
4. `BiasAssessmentActivity_baser.Rmd`: R markdown file, containing same code as above, to train and evaluate the model and examine the model features
5. `BiasAssessmentActivity_tidy.Rmd`: R markdown file, containing similar code to above, to train and evaluate the model and examine the model features. But with some tidyverse syntax.

## To run these scripts in binder

Rstudio [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/edickie/Model-Evaluation-Activity.git/master?urlpath=rstudio)

Click on the images above or the link below to run in a binder instance: 
https://mybinder.org/v2/gh/edickie/Model-Evaluation-Activity.git/master?urlpath=rstudio

Rstudio [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/edickie/Model-Evaluation-Activity.git/master?urlpath=rstudio)

Note - if running on Binder - rstudio is version 1.2.5 and R is version 4.1.0

## To run this in a local docker install

If docker desktop is installed on your computer. Clone this repo locally, navigate to the folder that contains this repo and type:

```sh
# cd Model-Evaluation-Activity
docker compose up rstudio
```

The docker version is in R 4.1.0 and rstudio 1.4

