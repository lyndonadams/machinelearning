# Structured learning
require(pmml)  # for storing the model in xml
library(randomForest)

# Load the data and keep the column headers
iris <- read.table("../data/iris.csv",sep=",", header=TRUE)

# Get the number of rows loaded
sizeOfData <- nrow( iris)

# select random rows function
randomRows = function(df,n){
  return(df[sample(nrow(df),n),])
}

# Mix up the table using the random function
iris <- randomRows( iris, sizeOfData)

# Now split the dataset in to train 20%  and test 33%
indexes <- sample(1:sizeOfData, size=0.2*sizeOfData)
test <- iris[indexes,]
train <- iris[-indexes,]

# Remove the species label from the data set 
iris.use = subset( train,select=-species)


fit <- randomForest(species ~ sepal.length + sepal.width + petal.length + petal.width ,   data=train, ntree=22)
print(fit) # view results 
importance(fit) # importance of each predictor

fit$confusion

# Predict
p <- predict( fit, iris.use[1,] )
summary( p)

# Actual
print(iris[1,])

localfilename <- "../models/iris-randomforest-prediction.xml"
saveXML(pmml( fit, model.name = "IrisPredictionRForest", app.name = "RR/PMML", dataset = dataset) , file = localfilename)

# Write test file to csv
write.table( test, file="../models/test_iris.csv", sep=",", row.names=FALSE)
