getwd()

setwd("C:/Users/user/Dropbox/2 - STUDY/2 - Coursera - Stats/7 - Machine learning/Quizzez - Assignments/Data")

library(Hmisc)
library(caret)
library(randomForest)
library(foreach)
library(doParallel)
set.seed(123)

training_data <- read.csv("pml-training.csv", na.strings=c("#DIV/0!") )
testcases_data <- read.csv("pml-testing.csv", na.strings=c("#DIV/0!") )

for(i in c(8:ncol(training_data)-1)) {training_data[,i] = as.numeric(as.character(training_data[,i]))}

for(i in c(8:ncol(testcases_data)-1)) {testcases_data[,i] = as.numeric(as.character(testcases_data[,i]))}

training_data <-training_data[,colSums(is.na(training_data)) == 0]
testcases_data <-testcases_data[,colSums(is.na(testcases_data)) == 0]

training_data   <-training_data[,-c(1:7)]
testcases_data <-testcases_data[,-c(1:7)]


inTraining.matrix    <- createDataPartition(training_data$classe, p = 0.75, list = FALSE)
training.data.df <- training_data[inTraining.matrix, ]
testing.data.df  <- training_data[-inTraining.matrix, ]

registerDoParallel()
classe <- training.data.df$classe
variables <- training.data.df[-ncol(training.data.df)]

rf <- foreach (ntree=rep(250, 4), .combine=randomForest::combine, .packages='randomForest') %dopar% {randomForest(variables, classe, ntree=ntree)}


training.predictions <- predict(rf, newdata=training.data.df)
confusionMatrix(training.predictions,training.data.df$classe)

testing.predictions <- predict(rf, newdata=testing.data.df)
confusionMatrix(testing.predictions,testing.data.df$classe)


feature_set <- colnames(training_data)
newdata     <- testcases_data

pml_write_files = function(x){
        n = length(x)
        for(i in 1:n){
                filename = paste0("problem_id_",i,".txt")
                write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
        }
}


x <- testcases_data
x <- x[feature_set[feature_set!='classe']]
answers <- predict(rf, newdata=x)


answers

pml_write_files(answers)
