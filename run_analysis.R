#run_analysis.R
#Rachel Esterkes
#Getting and Cleaning Data
#August 2018

#install.packages("dplyr")
#install.packages("data.table")
#Load packages
library(data.table)
library(dplyr)

#Setting The Working Directory
setwd("C:/Users/resterkes/Desktop/Data Source/Getting & Cleaning Data")

#Downloading Data
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "CourseDataset.zip"
if (!file.exists(destFile)){
  download.file(URL, destfile = destFile, mode='wb')
}
if (!file.exists("./UCI_HAR_Dataset")){
  unzip(destFile)
}
dateDownloaded <- date()

#Start Reading Files
setwd("./UCI_HAR_Dataset")

###Reading Activity files
ActivityTest <- read.table("./test/y_test.txt", header = FALSE)
ActivityTrain <- read.table("./train/y_train.txt", header = FALSE)

###Reading Features Files
FeaturesTest <- read.table("./test/X_test.txt", header = FALSE)
FeaturesTrain <- read.table("./train/X_train.txt", header = FALSE)

#Reading Subject Files
SubjectTest <- read.table("./test/subject_test.txt", header = FALSE)
SubjectTrain <- read.table("./train/subject_train.txt", header = FALSE)

####Reading Activity Labels
ActivityLabels <- read.table("./activity_labels.txt", header = FALSE)

####Reading Feature Names
FeaturesNames <- read.table("./features.txt", header = FALSE)

####Merging Data: Features Test&Train,Activity Test&Train, Subject Test&Train
FeaturesData <- rbind(FeaturesTest, FeaturesTrain)
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)

####Renaming Columns in ActivityData & ActivityLabels Data
names(ActivityData) <- "ActivityN"
names(ActivityLabels) <- c("ActivityN", "Activity")

####Getting Factor of Activity Name
Activity <- left_join(ActivityData, ActivityLabels, "ActivityN")[, 2]

####Renaming SubjectData Columns
names(SubjectData) <- "Subject"
#Rename FeaturesData columns using columns from FeaturesNames
names(FeaturesData) <- FeaturesNames$V2

###Creating One Dataset With Only Variables: SubjectData,  Activity,  FeaturesData
DataSet <- cbind(SubjectData, Activity)
DataSet <- cbind(DataSet, FeaturesData)

###Creating New Data By Extracting Measurements Mean & Standard Deviation
subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
DataNames <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSet <- subset(DataSet, select=DataNames)

####Renaming Columns of Large Data Using Descriptive Activity Name
names(DataSet)<-gsub("^t", "time", names(DataSet))
names(DataSet)<-gsub("^f", "frequency", names(DataSet))
names(DataSet)<-gsub("Accel", "Accelerometer", names(DataSet))
names(DataSet)<-gsub("Gv", "Gravity", names(DataSet))
names(DataSet)<-gsub("Magn", "Magnitude", names(DataSet))
names(DataSet)<-gsub("Bdbd", "Body", names(DataSet))

####Creating A Second Tidy Dataset With Average Variable For Independent Activity and Indepdnent Subject
SecondDataSet<-aggregate(. ~Subject + Activity, DataSet, mean)
SecondDataSet<-SecondDataSet[order(SecondDataSet$Subject,SecondDataSet$Activity),]

