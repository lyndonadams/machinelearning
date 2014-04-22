library(randomForest)

# Load the data and keep the column headers
iris <- read.table("../data/iris.csv",sep=",", header=TRUE)

# Get the number of rows loaded
sizeOfData <- nrow( iris)

# Remove the species label from the data set 
iris.use = subset(iris,select=-species)


fit <- randomForest(species ~ sepal.length + sepal.width + petal.length + petal.width ,   data=iris, ntree=680)
print(fit) # view results 
importance(fit) # importance of each predictor


