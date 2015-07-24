# Practical Machine Learning - Prediction Assignment

##Libraries

I analyzed the dataset to predict what activity an individual perform. To do this I used the caret and randomForest. The analysis consists of training a prediction algorithm to generate answers of each of the 20 test data cases of this assignment.

```
library(Hmisc)
library(caret)
library(randomForest)
library(foreach)
library(doParallel)

```
## Loading Training and test Data

First, I loaded the data from the provided sources. I saw some values containing "#DIV/0!" so I replaced them by NA value.

```
training_data <- read.csv("pml-training.csv", na.strings=c("#DIV/0!") )
testcases_data <- read.csv("pml-testing.csv", na.strings=c("#DIV/0!") )
```
Formatting so that all cells were numbers:

```
for(i in c(8:ncol(training_data)-1)) {training_data[,i] = as.numeric(as.character(training_data[,i]))}

for(i in c(8:ncol(evaluation_data)-1)) {evaluation_data[,i] = as.numeric(as.character(evaluation_data[,i]))}
```

## Cleaning Data

To clean the data, any columns containing 'NA' are removed from both downloaded data sets.

```
training_data <-training_data[,colSums(is.na(training_data)) == 0]
testcases_data <-testcases_data[,colSums(is.na(testcases_data)) == 0]
```

The first seven(7) columns user_name raw_timestamp_part_1 raw_timestamp_part_2   cvtd_timestamp new_window num_window are not related to calculations and are removed form the downloaded data.

```
training_data   <-training_data[,-c(1:7)]
testcases_data <-testcases_data[,-c(1:7)]
```

##Create a stratified random sample of the data into training and test 
I used a seed value for consistent results.

sets.seed(998)
```
inTraining.matrix    <- createDataPartition(training_data$classe, p = 0.75, list = FALSE)
training.data.df <- training_data[inTraining.matrix, ]
testing.data.df  <- training_data[-inTraining.matrix, ]
```


## Use Random Forests 

We then fit the model with random forests algorithm, model of size 1000, with 4 cores of 250 trees each. We used parallel processing to build it.

```
registerDoParallel()
classe <- training.data.df$classe
variables <- training.data.df[-ncol(training.data.df)]

rf <- foreach(ntree=rep(250, 4), .combine=randomForest::combine, .packages='randomForest') %dopar% {
randomForest(variables, classe, ntree=ntree) 
}

```

##Confusion Matrix for both data sets
Predict and generate the Accuracy and confusion matrix for the training and test sets (75% of the training data and 25% of the testing data). Did the data overfit the training data?

```
training.predictions <- predict(rf, newdata=training.data.df)
confusionMatrix(training.predictions,training.data.df$classe)

testing.predictions <- predict(rf, newdata=testing.data.df)
confusionMatrix(testing.predictions,testing.data.df$classe)
```

##Conclusions and Submission
We can see from the confusion matrix that this model has a very high accuracy.


Setting the `R` values from previous code to clean data to match submission code.

```
feature_set <- colnames(training_data)
newdata     <- testcases_data

```

Coursera method to write answers to separate `.txt` files


```
pml_write_files = function(x){
  n = length(x)
  for(i in 1:n){
    filename = paste0("problem_id_",i,".txt")
    write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
  }
}

```

Predict the `answers` to the 20 questions.
```
x <- testcases_data
x <- x[feature_set[feature_set!='classe']]
answers <- predict(rf, newdata=x)
```

Now check

```
answers

pml_write_files(answers)
```





#Total code to be copy-pasted



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

