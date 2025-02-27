#  
# The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. 
# The goal is to prepare tidy data that can be used for later analysis. 
# You will be graded by your peers on a series of yes/no questions related to the project. 
# You will be required to submit: 
#  1) a tidy data set as described below, 
#  2) a link to a Github repository with your script for performing the analysis, and
#  3) a code book that describes the variables, the data, and any transformations or work that you performed 
#     to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts.
#     This repo explains how all of the scripts work and how they are connected.  
#  
# One of the most exciting areas in all of data science right now is wearable computing 
# - see for example this article 
# (http://www.insideactivitytracking.com/data-science-activity-tracking-and-the-battle-for-the-worlds-top-sports-brand/).
# Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users.
# The data linked to from the course website represent data collected from the accelerometers 
# from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
#  
# Here are the data for the project: 
#  
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
#
# You should create one R script called run_analysis.R that does the following. 
# 1) Merges the training and the test sets to create one data set.
# 2) Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3) Uses descriptive activity names to name the activities in the data set
# 4) Appropriately labels the data set with descriptive variable names. 
# 5) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#

# Install needed packages
install.packages("data.table")
install.packages("reshape2")

require("data.table")
require("reshape2")

# Import activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Import data column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Get measurements on mean/stddev
extract_features <- grepl("mean|std", features)

# Import and process X_test data.
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
names(X_test) = features
head(X_test)
# Get mean/stddev for each measurement.
X_test2 = X_test[,extract_features]

# Import and clean Y_test data.
y_test<- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
# Import activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Combine data
test_data <- cbind(as.data.table(subject_test), y_test, X_test2)

# Import and clean X_train & y_train data.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

# Get mean/stddev for each measurement.
X_train2 = X_train[,extract_features]

# Get activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Combine data
train_data <- cbind(as.data.table(subject_train), y_train, X_train2)

# Merge test and train data
data = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt")
