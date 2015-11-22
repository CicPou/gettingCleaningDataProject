library(reshape2) ## reshape2 package is required for use of colsplit()
library(dplyr) ## dplyr is required for use of group_by() and summarise()

## Read the six .txt files containing the data into R
## Their location is based on the assumption that the .zip file containing
## the original data set was saved to the working directory.

subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

## Load the list of features contained in features.txt (also located in the UCI
## HAR Dataset in the working directory). Split it up so that we can easily
## extract the variables which relate to mean and standard deviation estimates.
## Combine all back into the 'features' data frame.

features <- read.table("./UCI HAR Dataset/features.txt", row.names = 1)
splitFeatures <- colsplit(features$V2, "\\-", names = c("signal", "estimate",
                                                        "direction"))
features <- cbind(features, splitFeatures)

## create an index of values of features$estimate which are either equal to
## mean or standard deviation. We know from features_info.txt that:

## mean(): Mean value
## std(): Standard deviation

meanIndex <- rownames(features[which(features$estimate=="mean()"),])
stdIndex <- rownames(features[which(features$estimate=="std()"),])

## combine these character vectors as integer vectors and sort

X_Index <- sort(as.integer(c(meanIndex, stdIndex)))

## Use this index to extract only the columns in X_test and X_train that contain
## mean or standard deviation estimates

X_test <- X_test[,X_Index]
X_train <- X_train[,X_Index]

## Use X_Index to extract only the values in features$V2 that relate to mean
## and standard deviation estimates. Clean it up by removing '()' and also
## removing duplicate string 'Body' from six of the variables names. We will
## use these cleaned up variable names later for column naming.

features <- as.character(features$V2[X_Index])
features <- gsub("()", "", features, fixed = TRUE)
features <- gsub("BodyBody", "Body", features)

## Combine subject_test, y_test, and X_test into a single data frame.

testdf <- cbind(subject_test, y_test, X_test)

## Combine subject_train, y_train and X_train into a single data frame.

traindf <- cbind(subject_train, y_train, X_train)

## Combine these two data frames together

combineddf <- rbind(testdf, traindf)

## Ensure all variables are named

colnames(combineddf) <- c("subject", "activity", features)

## turn the the activity variable values into named activites based on labels in
## activity_labels.txt. Also factorise it.

activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt",
                             row.names = 1)

combineddf$activity <- factor(combineddf$activity, labels = activityLabels$V2)

## Factorise the subject variable also

combineddf$subject <- factor(combineddf$subject)

## create a second, independent tidy data set with the average of each
## variable for each activity and each subject

tidyData <- combineddf %>% group_by(subject, activity) %>%
    summarise_each(funs(mean))

## Output tidyData as a file called tidyData.txt in the working directory

write.table(tidyData, file = "tidyData.txt", row.name = FALSE)

## Remove objects from the workspace that are no longer required
rm("activityLabels", "combineddf", "splitFeatures", "subject_test",
   "subject_train", "testdf", "traindf", "X_test", "X_train", "y_test",
   "y_train", "features", "meanIndex", "stdIndex", "X_Index", "tidyData")