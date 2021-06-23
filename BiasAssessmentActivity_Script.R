####EVALUATING ML MODELS FOR INTERSECTIONAL BIAS####

#using this script, we will train a binary logistic classifier to predict a diagnosis of schizophrenia (1) or affective disorder (AD) (0) using simulated data, and we will evaluate model performance informed by findings that suggest Black men with affective disorder may be more likely misdiagnosed with schizophrenia (SZ) as compared to White men with affective disorder (e.g., Olbert, Nagendra & Buck, 2018)

####TRAINING THE CLASSIFIER####

#install/load necessary packages
install.packages('plyr') #install data analysis package if needed
load('plyr') #load data analysis package

install.packages('caret') #install ML package if needed
library(caret) #load ML package

install.packages('fairness') #install fairness package if needed
library(fairness) #load fairness package

#read in train and test sets
train <- read.csv("train.csv", stringsAsFactors = T) 
test <- read.csv("test.csv", stringsAsFactors = T)

#ensure that outcomes are treated as factors
train$Diagnosis <- as.factor(train$Diagnosis)
test$Diagnosis <- as.factor(test$Diagnosis)

#examine the data
count(train$Diagnosis) # 4964 AD patients, #5036 SZ patients
count(test$Diagnosis) # 412 AD patients, 588 SZ patients

count(train$Sex) #5535 females, 4465 males
count(test$Sex) #528 females, 472 males

count(train$Race) #1528 Asian, 3421 Black, 1413 Hispanic, 3638 White
count(test$Race) #115 Asian, 357 Black, 140 Hispanic, 388 White

#training the model with all available features to predict diagnosis of AD or SZ
model1 <- train(Diagnosis~., 
                  method = 'glmnet', #use elastic net for regularization
                  family = 'binomial', 
                  data = train)

max(model1$results$Accuracy)
#accuracy at training should be high (>0.95)

####TESTING THE CLASSIFIER######

mod1_preds <- predict(model1, test) #generate 1000 predictions for 1000 test individuals
test$preds <- mod1_preds #add the predictions to the test set

#generate confusion matrix
confusionMatrix(data = test$preds, reference = test$Diagnosis, positive = "1") 
#what is our sensitivity and specificity? 
#how many individuals with AD overall have been misclassified as having SZ?
#how is our model doing so far?

####FAIRNESS ASSESSMENT########

#there are many fairness metrics available, but we cannot satisfy all of them, so we must select those that best address our concern of misdiagnosing individuals with AD as having SZ
#some potential candidates are: 

#demographic parity (TP + FP) (the absolute number of positive predictions)
#proportional parity (TP + FP) / (TP + FP + TN + FN) (positive predictions divided by total predictions) 
#which one is most appropriate for our data? (hint: do we have similar sample sizes for the groups of interest?)

#these metrics consider all positive predictions, but we are interested in false SZ predictions, so false positive rate parity is probably of utmost relevance:
#false positive rate parity: FP / (FP + TN) (total number of negative cases)

#for a guide on evaluating other performance metrics using the fairness package, see https://cran.r-project.org/web/packages/fairness/fairness.pdf

####BIAS BASED ON RACE#####
res_fpr_race <- fpr_parity(data    = test, 
                      outcome      = 'Diagnosis', 
                      outcome_base = '0', 
                      group        = 'Race',
                      preds        = 'preds', 
                      base         = 'White') #we use White as the reference group
res_fpr_race$Metric
#first row shows the metric (false positive rates)
#second row shows parity (the ratio of the metric between specified group and reference)
#third row shows group size

#false positive rates for each group are low (e.g., 0.6% for white, 4% for black, and 3% for Hispanic), but we can already see that there is a disparity in performance for some groups (e.g., Black and Hispanic individuals with AD being ~7 and ~5 times more likely to be misdiagnosed with SZ

####BIAS BASED ON SEX + RACE####
#however, we suspect this bias might only extend to identities defined by the intersecting features of sex and race (i.e., Black men; Gara et al., 2012; 2019), so we repeat this analysis for these subgroups

#we create an intersectional identity group column named "intersect"
test$intersect <- "NA"
for (i in 1:length(test$Sex)){
  if (test$Sex[i]=="Male" && test$Race[i]=="White"){
    test$intersect[i] <- "Whi_M"
  } else if (test$Sex[i]=="Male" && test$Race[i]=="Black"){
    test$intersect[i] <- "Bla_M"
}   else if (test$Sex[i]=="Male" && test$Race[i]=="Hispanic"){
  test$intersect[i] <- "His_M"
}   else if (test$Sex[i]=="Male" && test$Race[i]=="Asian"){
  test$intersect[i] <- "Asi_M"
} else if (test$Sex[i]=="Female" && test$Race[i]=="White"){
  test$intersect[i] <- "Whi_F"
} else if (test$Sex[i]=="Female" && test$Race[i]=="Black"){
  test$intersect[i] <- "Bla_F"
}   else if (test$Sex[i]=="Female" && test$Race[i]=="Hispanic"){
  test$intersect[i] <- "His_F"
}   else if (test$Sex[i]=="Female" && test$Race[i]=="Asian"){
  test$intersect[i] <- "Asi_F"
}
}

res_fpr_inter <- fpr_parity(data   = test, 
                      outcome      = 'Diagnosis', 
                      outcome_base = '0', 
                      group        = 'intersect',
                      preds        = 'preds', 
                      base         = 'Whi_M') #now, we will use White males as the reference
res_fpr_inter$Metric
#white males and black females have a false positive rate ~1%, hispanic females have a false positive rate ~5%, black males have a false positive rate ~12%, and we have not generated any false positives for other groups
#Black males are almost 9 times more likely to be misdiagnosed with SZ than white males
#Hispanic females are 4 times more likely to be misdiagnosed with SZ schizophrenia than White males
#how is our model doing now?

####MODEL WITHOUT RACE TRAINING AND EVALUATION####

#we re-train our model removing the race feature
model2 <- train(Diagnosis~.-Race, 
                method = 'glmnet',
                family = 'binomial', 
                data = train)

max(model2$results$Accuracy)

mod2_preds <- predict(model2, test)
test$preds2 <- mod2_preds

confusionMatrix(data = test$preds2, reference = test$Diagnosis, positive = "1") 
#how is our new model doing overall?
#how many individuals with AD has it misclassified as having SZ?

res_fpr2_intersect <- fpr_parity(data        = test, 
                                outcome      = 'Diagnosis', 
                                outcome_base = '0', 
                                group        = 'intersect',
                                preds        = 'preds2', 
                                base         = 'Whi_M')
res_fpr2_intersect$Metric
#did removing race fix our problem?

####FEATURE EVALUATION####
#the tendency for Black men to be misdiagnosed with SZ is not simply a result of clinician bias, but likely reflects systemic factors (e.g., barriers to care leading to severe illness at assessment, expression of emotional and cognitive symptoms of depression, experiences of racialization leading to greater paranoia or distrust)
#these factors may be reflected in other features in the simulated data, which are related to the race/ethnicity variable, and contribute to bias
#we can explore relations among the features in different ways, but one option is to see how features are related to SZ in the training set, and then explore these features in groups with AD in the test set

#ensure the intersectional group variable is treated as a factor
test$intersect <- as.factor(test$intersect)

#sociodemographic factors (delay in seeking care and housing status)

plot(train$Diagnosis, train$Delay, main= "Delay by diagnosis", xlab="Group", ylab="Delay") #patients with SZ are more delayed in seeking care than patients with AD
plot(test$intersect[test$Diagnosis==0], test$Delay[test$Diagnosis==0], main="Delay across groups with AD", xlab="Group", ylab="Delay") #black males with AD are likely to delay in seeking treatment, as compared to other groups

plot(train$Diagnosis, train$Housing, main= "Housing by diagnosis", xlab="Group", ylab="Housing") #any trends here?
plot(test$intersect[test$Diagnosis==0], test$Housing[test$Diagnosis==0], main="Housing across groups with AD", xlab="Group", ylab="Housing") #and here?

#can we hypothesize about sociodemographic factors potentially contributing to model bias?

#clinical factors in AD (emotional and cognitive symptoms)

plot(train$Diagnosis, train$Dep_Mood, main= "Depressed mood by diagnosis", xlab="Group", ylab="Depressed mood score") #patients with AD report a higher severity of depressed mood, as compared to those with SZ
plot(test$intersect[test$Diagnosis==0], test$Dep_Mood[test$Diagnosis==0], main="Depressed mood across groups with AD", xlab="Group", ylab="Depressed mood score") #black males with AD are likely to delay in seeking treatment, as compared to other groups

plot(train$Diagnosis, train$Rumination, main= "Rumination by diagnosis", xlab="Group", ylab="Rumination score") #any trends here?
plot(test$intersect[test$Diagnosis==0], test$Rumination[test$Diagnosis==0], main="Rumination across groups with AD", xlab="Group", ylab="Depressed mood score") #and here?

#clinical factors in SZ (suspiciousness and tension)
plot(train$Diagnosis, train$Suspicious, main= "Suspiciousness by diagnosis", xlab="Group", ylab="Suspiciousness score") #how about here?
plot(test$intersect[test$Diagnosis==0], test$Suspicious[test$Diagnosis==0], main="Suspiciousness across groups with AD", xlab="Group", ylab="Suspiciousness score") #and here?

plot(train$Diagnosis, train$Tension, main= "Tension by diagnosis", xlab="Group", ylab="Tension score") #any trends here?
plot(test$intersect[test$Diagnosis==0], test$Tension[test$Diagnosis==0], main="Tension across groups with AD", xlab="Group", ylab="Tension score") #and here?

#can we hypothesize about clinical factors potentially contributing to model bias?