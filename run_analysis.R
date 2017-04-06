if (!require("plyr")) {
  install.packages("plyr")
}
library("plyr")

#Set Working Directory
setwd("./R/data/UCI HAR Dataset/")

#1. Merge the train and the test data.

#Load features (considering only the second column)
features        <- read.table("./features.txt",header=FALSE)[,2]

#Load train data
subjectTrain    <-read.table("./train/subject_train.txt", header=FALSE)
xTrain          <- read.table("./train/X_train.txt", header=FALSE)
yTrain          <- read.table("./train/y_train.txt", header=FALSE)

#Assign column names to the data above
colnames(subjectTrain) <- "subjectId"
colnames(xTrain) <- features
colnames(yTrain) <- "activityId"

#Merging train Data
trainData <- cbind(yTrain,subjectTrain,xTrain)

#Load test Data
subjectTest    <-read.table("./test/subject_test.txt", header=FALSE)
xTest         <- read.table("./test/X_test.txt", header=FALSE)
yTest         <- read.table("./test/y_test.txt", header=FALSE)

# Assign column names.. same as for training data..
colnames(subjectTest) <- "subjectId"
colnames(xTest) <- features
colnames(yTest) <- "activityId"

# merging test Data
testData <- cbind(yTest,subjectTest,xTest)

#final merged data
finalData <- rbind(trainData,testData)

# 2. Extract only the measurements on the mean and standard deviation for each measurement
data_mean_std <-finalData[,grepl("mean|std|subjectId|activityId",colnames(finalData))]

#3. #Uses descriptive activity names to name the activities in the data set
#Load & Assign column names to activityLabel table 
activityLabel   <- read.table("./activity_labels.txt",header=FALSE)
colnames(activityLabel)<-c("activityId","activityType")
#Join  activityLabel to data_mean_std by activityId (so we can see the activityType column)
data_mean_std <- join(data_mean_std, activityLabel, by = "activityId", match = "first")
#Remove the column activityId from data_mean_std table
data_mean_std <-data_mean_std[,-1]

# #CODE BOOK Part1: creating a vector for the original column names
# OriginalColNames <- colnames(data_mean_std);

#4. Appropriately labels the data set with descriptive variable names.
#Remove parentheses
names(data_mean_std) <- gsub("\\(|\\)", "", names(data_mean_std), perl  = TRUE)
#correct syntax in names
names(data_mean_std) <- make.names(names(data_mean_std))

#add descriptive names
names(data_mean_std) <- gsub("Acc", "Acceleration", names(data_mean_std))
names(data_mean_std) <- gsub("^t", "Time", names(data_mean_std))
names(data_mean_std) <- gsub("^f", "Frequency", names(data_mean_std))
names(data_mean_std) <- gsub("BodyBody", "Body", names(data_mean_std))
names(data_mean_std) <- gsub("mean", "Mean", names(data_mean_std))
names(data_mean_std) <- gsub("std", "Std", names(data_mean_std))
names(data_mean_std) <- gsub("MeanFreq", "MeanFrequency", names(data_mean_std))
names(data_mean_std) <- gsub("Mag", "Magnitude", names(data_mean_std))

#5. Creates a second tidy data set with the average of each variable for each activity and each subject.
averaged_tidydata<- ddply(data_mean_std, c("subjectId","activityType"), numcolwise(mean))
#Export to tidyData.txt file
write.table(averaged_tidydata,file="tidyData.txt", row.names = FALSE)
# 
# #CODE BOOK Part2: creating a vector for the description names
# describedColNames <- colnames(data_mean_std
# describedColNames[1]="Subject identifier who performed the measured activities"
# describedColNames[81]="Activity name performed by the volunteers"
# write.table(cbind(OriginalColNames,describedColNames),file="codeBook.md")
