
This Github repo (gettingCleaningDataProject) contains submissions for the Coursera Getting and Cleaning Data course project. In it you will find 2 files in addition to this README:

# run_analysis.R

run_analysis.R is the R script that takes the original data set of measurements collected from the accelerometers from the Samsung Galaxy S smartphone, and transforms it into a new tidy data set that can be used for further analysis.

In order to run run_analysis.R, you will need the following:

1.  The original data set, which can be obtained as a zip file from here:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Unzip this zip file to your working directory i.e.you should have the top-level directory of the dataset (called 'UCI HAR Dataset') directly in your working directory.

2.  The R packages 'reshape2' and 'dplyr'. If you do not already have these installed, please install them by running the following in the R console:
```{r}
install.packages("reshape2")   
install.packages("dplyr")
```
3.  The run_analysis.R script in this Github repo saved to your working directory.

Once you have completed the above 3 steps, you are ready to run run_analysis.R. Do so by running the following in the R console:
```{r}
source("run_analysis.R")
```
The output of run_analysis.R is a text file called tidyData.txt, which will be written to your working directory.

The process of transforming the original UCI HAR data set into tidyData.txt is described in more detail in codebook.md, but run_analysis.R is also commented so that you can see at a glance what each line of the script does.

# codebook.md

This is the codebook that accompanies run_analysis.R. It describes the variables, the data, and any transformations or work that were performed to clean up the data.