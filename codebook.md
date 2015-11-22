---
title: codebook for Coursera Getting and Cleaning Data course project
author: by CicPou
date: Nov 21 2015
output:
  html_document:
    keep_md: yes
---

## Brief Project Description
This project takes raw data collected from the accelerometers of the Samsung Galaxy S smartphone, and using an R script called run_analysis.R, creates a tidy data set that can be used for further analysis. For more information on the original study and data collection process, see the .zip file and and website references in the 'Source of data' section below.

## Obtaining the raw data set
### Source of data
The raw data was collected by downloading a zip file located at the following URL: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip   
This in turn was obtained from the website of the Human Activity Recognition Using Smartphone Data Set, located at UC Irvine's Machine Learning Repository, here: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

### Initial observations of the raw data set
Once downloaded, the raw data set obtained via the above zip file presents as a directory named 'UCI HAR Dataset'. Within it are contained various files and subdirectories as follows:

* activity_labels.txt
* features_info.txt
* features.txt
* README.txt
* test (directory), which contains
    + Inertial Signals (directory)
    + subject_test.txt
    + X_test.txt
    + y_test.txt
* train (directory), which contains
    + Inertial Signals (directory)
    + subject_train.txt
    + X_train.txt
    + y_train.txt
    
Upon reviewing the above files and directories, including reading some into R, it was observed that:

* The README.txt and features_info.txt files contain information about the data set and therefore can be regarded as the codebook for the raw dataset
* subject_test.txt and subject_train.txt contain integers that code each of the 30 subjects for whom data was collected. This was checked by reading by files into R and running the following code:

Read data into R
```{r}
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
```
Create lists of unique values in subject_test and subject_train
```{r}
unique_test <- unique(subject_test)
unique_train <- unique(subject_train)
```
Combine the 2 lists and sort numerically
```{r}
combined <- rbind(unique_test, unique_train)
combined <- sort(combined$V1)
```
Compare the result to a sequence vector 1:30
```[r]
identical(1:30, combined)
```
* X_test.txt and X_train.txt each contain 561 variables that have been estimated from the signals data collected in the original study.
* The data in the Inertial Signals directories can be ignored as the other files in 'test' and 'train' directories contain the required estimated variables. This can be seen by visually inspecting the data; for example, the values in X_test.txt and X-train.txt have been normalized and bounded within [-1,1], whereas the values in the Interial Signals files have not.
* features.txt contains labels for the data in X_test.txt and X_train.txt
* y_test.txt and y_train contain integers that code each of the 6 activites undertaken by each of the subjects in the original study. Like subject_test.txt and subject_train.txt, unique() can be used to see that they contain only integers 1 to 6 (and we have 6 activities undertaken by participants in the original study)
* activity_labels.txt contains labels for the activities in y_test.txt and y_train.txt

It was apparent from the dimensions of the files (see list below) that their values corresponded and could form two data frames (one each for 'test' and 'train' data) that could be assembled using column binding (cbind()). Providing the columns were combined in the same order, this would produce two data frames with the same column ordering that could be combined to form one single data frame.

* subject_test contains 2947 observations of 1 variable
* y_test contains 2947 observations of 1 variable
* X_test contains 2947 observations of 561 variables

* subject_train contains 7352 observations of 1 variable
* y_train contains 7352 observations of 1 variable
* X_train contains 7352 observations of 561 variables

## Construction of the run_analysis.R script
### The steps of the script
Once these observations had been made, a run_analysis.R script was constructed. The run_analysis.R script takes the raw data and does the following:

1.  Merges the training and the test sets to create one data set.
2.  Extracts only the measurements on the mean and standard deviation for each measurement. 
3.  Uses descriptive activity names to name the activities in the data set
4.  Appropriately labels the data set with descriptive variable names.
5.  From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

In the script itself, the steps are not carried out in the exact order above i.e. steps 1. and 2. are reversed. This is because features.txt (which contains labels for the variable data) maps directly onto the columns in X_train and X_test. Therefore it is easier and more efficient to create an index and extract the mean and standard deviation measurements before combining the data.

### How the script transforms the data
The script transforms the data by the following steps:   
Load the required packages: reshape 2 is required for the use of colsplit() and dplyr is required for the use of group_by() and summarise()
```{r}
library(reshape2)
library(dplyr)
```
Read the six .txt files containing the data into R. Their location is based on the assumption that the .zip file containing the original data set was saved to the working directory. See the README.md in this Github repo (gettingCleaningDataProject) for further instructions.
```{r}
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
```
Load the list of features contained in features.txt (also located in the in the working directory). Split it up so that we can easily extract the variables which relate to mean and standard deviation estimates.
```{r}
features <- read.table("./UCI HAR Dataset/features.txt", row.names = 1)
splitFeatures <- colsplit(features$V2, "\\-", names = c("signal", "estimate",
                                                        "direction"))
```
Combine all back into a 'features' data frame.
```{r}
features <- cbind(features, splitFeatures)
```
Create an index of values of features$estimate which are either equal to mean or standard deviation. We know from features_info.txt that:

mean(): Mean value   
std(): Standard deviation
```{r}
meanIndex <- rownames(features[which(features$estimate=="mean()"),])
stdIndex <- rownames(features[which(features$estimate=="std()"),])
```
Combine these character vectors as integer vectors and sort
```{r}
X_Index <- sort(as.integer(c(meanIndex, stdIndex)))
```
Use this index to extract only the columns in X_test and X_train that contain mean or standard deviation estimates
```{r}
X_test <- X_test[,X_Index]
X_train <- X_train[,X_Index]
```
Also use X_Index to extract only the values in features that relate to mean and standard deviation estimates. Clean it up by removing '()' and also removing duplicate string 'Body' from six of the variables names. We will use these cleaned up variable names later for column naming.
```{r}
features <- as.character(features$V2[X_Index])
features <- gsub("()", "", features, fixed = TRUE)
features <- gsub("BodyBody", "Body", features)
```
Combine subject_test, y_test, and X_test into a single data frame.
```{r}
testdf <- cbind(subject_test, y_test, X_test)
```
Combine subject_train, y_train and X_train into a single data frame.
```{r}
traindf <- cbind(subject_train, y_train, X_train)
```
Combine these two data frames together
```{r}
combineddf <- rbind(testdf, traindf)
```
Ensure all variables are named
```{r}
colnames(combineddf) <- c("subject", "activity", features)
```
Turn the the activity variable values into named activites based on labels in activity_labels.txt. Also factorise it.
```{r}
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt",
                             row.names = 1)

combineddf$activity <- factor(combineddf$activity, labels = activityLabels$V2)
```
Factorise the subject variable also
```{r}
combineddf$subject <- factor(combineddf$subject)
```
Create a second, independent tidy data set with the average of each variable for each activity and each subject
```{r}
tidyData <- combineddf %>% group_by(subject, activity) %>%
    summarise_each(funs(mean))
```
Output tidyData as a file called tidyData.txt in the working directory
```{r}
write.table(tidyData, file = "tidyData.txt", row.name = FALSE)
```
Remove objects from the workspace that are no longer required
```{r}
rm("activityLabels", "combineddf", "splitFeatures", "subject_test",
   "subject_train", "testdf", "traindf", "X_test", "X_train", "y_test",
   "y_train", "features", "meanIndex", "stdIndex", "X_Index", "tidyData")
```
## The output: The tidy data set
run_analysis.R will output a file in the working directory called tidyData.txt which contains a cleaned, summarised version of the raw data.

tidyData.txt consists of 180 observations of 68 variables. The 68 variables consist of two columns which identify the subject and the activity, then the 66 columns that contain the mean and standard deviation variables.

In the process of summarising the data, the data was grouped by subject and activity, and then the mean was taken for each of the 66 mean and standard deviation variables. There were 30 participants and 6 activities hence 180 observations (one activity per participant).

The table below provides further details on the variables, including a summary of how they relate to the original raw data. Note that the variables in columns 3 to 68 have been normalized and bounded within [-1,1] (as per README.txt accompanying the raw data set), so they are dimensionless and therefore do require any units.

| Variable in tidyData.txt | Class | Source file in raw data set | Treatment by run_analysis.R script |
|--------------------------|---------------------|----------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| subject | factor of 30 levels | subject_test.txt and subject_train.txt | factorised |
| activity | factor of 6 levels | y_test.txt and y_train.txt | converted integer codes to the corresponding activity: 1 WALKING, 2 WALKING_UPSTAIRS, 3 WALKING_DOWNSTAIRS, 4 SITTING, 5 STANDING, 6 LAYING |
| tBodyAcc-mean-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAcc-mean-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAcc-mean-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAcc-std-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAcc-std-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAcc-std-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tGravityAcc-mean-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tGravityAcc-mean-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tGravityAcc-mean-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tGravityAcc-std-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tGravityAcc-std-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tGravityAcc-std-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAccJerk-mean-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAccJerk-mean-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAccJerk-mean-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAccJerk-std-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAccJerk-std-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAccJerk-std-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyro-mean-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyro-mean-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyro-mean-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyro-std-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyro-std-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyro-std-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyroJerk-mean-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyroJerk-mean-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyroJerk-mean-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyroJerk-std-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyroJerk-std-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyroJerk-std-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAccMag-mean | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAccMag-std | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tGravityAccMag-mean | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tGravityAccMag-std | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAccJerkMag-mean | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyAccJerkMag-std | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyroMag-mean | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyroMag-std | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyroJerkMag-mean | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| tBodyGyroJerkMag-std | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAcc-mean-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAcc-mean-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAcc-mean-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAcc-std-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAcc-std-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAcc-std-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAccJerk-mean-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAccJerk-mean-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAccJerk-mean-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAccJerk-std-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAccJerk-std-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAccJerk-std-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyGyro-mean-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyGyro-mean-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyGyro-mean-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyGyro-std-X | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyGyro-std-Y | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyGyro-std-Z | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAccMag-mean | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAccMag-std | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAccJerkMag-mean | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyAccJerkMag-std | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyGyroMag-mean | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyGyroMag-std | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyGyroJerkMag-mean | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |
| fBodyGyroJerkMag-std | numeric | X_test.txt and X_train.txt | mean of variable by subject and activity |