wd<-getwd()
setwd(paste(wd, "/UCI HAR Dataset/train", sep=""))

#read data files X_train.txt, y_train.txt and subject_train.txt

X_train <- read.table("X_train.txt", header = FALSE)
Subject_train <- read.table( "subject_train.txt", header= FALSE)
Y_train <- read.table("y_train.txt", header= FALSE)

# Bind subject ID and activity labels to X_train

X_train<- cbind( Subject_train, Y_train, X_train)
rm(Subject_train, Y_train)

setwd(paste(wd, "/UCI HAR Dataset/test", sep=""))

#read data files X_test.txt, y_test.txt and subject_test.txt

X_test <- read.table("X_test.txt", header = FALSE)
Subject_test <- read.table( "subject_test.txt", header= FALSE)
Y_test <- read.table("y_test.txt", header= FALSE)

# Bind subject ID and activity labels to X_test

X_test<- cbind( Subject_test, Y_test, X_test)

rm(Subject_test, Y_test)

#Merge the test and training data into one file
Merged_data<- rbind(X_test, X_train)
rm(X_test, X_train)

#label the columns of the Merged data with descriptive names
setwd(paste(wd, "/UCI HAR Dataset", sep=""))
Features<- read.table("features.txt", header =  FALSE)
labels<-c("Subject_ID", "Activity_label", as.character(Features[,2]))
colnames(Merged_data) <- labels
rm(labels, Features)

#extract the mean and SD of the measurements and merge them in new DF

mean_data<-Merged_data[grep("mean", colnames(Merged_data))]
sd_data<-Merged_data[grep("std", colnames(Merged_data))]
Merged_mean_std<- cbind(mean_data,sd_data)
Merged_mean_std<- cbind( Merged_data[,1:2], Merged_mean_std)
rm(mean_data, sd_data)

#Give the activities descriptive names

Merged_mean_std$Activity_label[Merged_mean_std$Activity_label == 1] <- "Walking"
Merged_mean_std$Activity_label[Merged_mean_std$Activity_label == 2] <- "Walking upstairs"
Merged_mean_std$Activity_label[Merged_mean_std$Activity_label == 3] <- "Walking downstairs"
Merged_mean_std$Activity_label[Merged_mean_std$Activity_label == 4] <- "Sitting"
Merged_mean_std$Activity_label[Merged_mean_std$Activity_label == 5] <- "Standing"
Merged_mean_std$Activity_label[Merged_mean_std$Activity_label == 6] <- "Laying"

#Get the average of the variables for each activity and subject

library(data.table)
setDT(Merged_mean_std)
averaged_data<- Merged_mean_std[, lapply(.SD,mean), .SDcols=3:81, by=c("Subject_ID", "Activity_label")]
averaged_data<-averaged_data[order(Subject_ID)]

write.table(averaged_data, file="Tidy_UCI_HAR_data.txt", row.name= FALSE)