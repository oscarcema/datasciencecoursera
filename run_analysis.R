#1. Install and load packages required
if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

#2. Set work directory
setwd("R/data/UCI HAR Dataset/")



#3. Load: data column names of each measure processed
features <- read.table("./features.txt",header=FALSE)[,2]
# Extract only the measurements on the mean and standard deviation for each measurement.
meanANDstd_features <- grepl("mean|std", features)

#4. Load: activity labels(name of the activities performed by the volunteers)
activitylabels <- read.table("./activity_labels.txt",header=FALSE)[,2]

#***Load and process test data**

#5.1. Load and process X_test data.
X_test <- read.table("./test/X_test.txt")
#5.1.1. Load the subject who performed the tests
subject_test <- read.table("./test/subject_test.txt")

#5.1.2 Set the variable names to X_test dataset based on the features
names(X_test) = features

# 5.1.3. Extract only the measurements on the mean and standard deviation for each measurement.
X_test <- X_test[,meanANDstd_features]

#5.2. Load and process y_test data.
y_test <- read.table("./test/y_test.txt")
#5.2.1 Add the label name related to the y_test column position
y_test[,2] = activitylabels[y_test[,1]]
#5.2.2 Set the column names to y_test
names(y_test) = c("Activity_ID", "Activity_Label")

#5.3. Set the column name to subject_test
names(subject_test) = "subject"

#5.4  Bind data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)


# *** Load and process train data ***
#6.1 Load and process X_train & y_train data.
X_train <- read.table("./train/X_train.txt")

#6.1.1. Load the subject who performed the tests
subject_train <- read.table("./train/subject_train.txt")

#6.1.2 Set the variable names to X_test dataset based on the features
names(X_train) = features

#6.1.3. Extract only the measurements on the mean and standard deviation for each measurement.
X_train = X_train[,meanANDstd_features]

#6.2. Load and process y_train data.
y_train <- read.table("./train/y_train.txt")
#6.2.1 Add the label name related to the y_train column position
y_train[,2] = activitylabels[y_train[,1]]
#6.2.2 Set the column names to y_test
names(y_train) = c("Activity_ID", "Activity_Label")

#6.3. Set the column name to subject_tran
names(subject_train) = "subject"

#6.4 Bind data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)


#7. Merge test and train data
data = rbind(test_data, train_data)

#.8 Melt the data (5 columns: subject,Activity_ID,Activity_Label,variable & value)
id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

#9. Get the mean of each variable
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

#10. Export the tidy data
write.table(tidy_data, file = "./tidy_data.txt")






