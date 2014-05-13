# Structured learning
require(pmml)  # for storing the model in xml
require(class) # Load the class package that holds the knn() function
require(ggplot2)

# Load the data and keep the column headers
iris <- read.table("../data/iris.csv",sep=",", header=TRUE)

# Plot the data to get a sense of the cluster densities.
plot(iris[1:50,2:3], xlim=c(2.8, 4.5),ylim=c(1.0, 5.1), pch=1, col="red", main="Iris Data")
points(iris[51:100, 2:3], pch=1, col="darkgreen")
points(iris[101:150, 2:3], pch=1, col="blue")

# legend (#xcoord, #ycoord, col=c("colors"), pch=c("shape of points"), text.col=c("textcolor")
# legend=c("actual text you want to use")
legend(2.8, 4.9, col=c("red", "darkgreen", "blue"), pch=c(1,1), text.col=c("red", "darkgreen","blue"), legend=c("Setosa", "Versicolor","virginica" ))


# Get the number of rows loaded
sizeOfData <- nrow( iris)

# select random rows function
randomRows = function(df,n){
  return(df[sample(nrow(df),n),])
}

# Mix up the table using the random function
iris <- randomRows( iris, sizeOfData)

# Select the feature space to minimise the data set
# features <- c( "sepal.width","sepal.length", "petal.length", "petal.width")
# iris <- iris[ features ]

# Now scale the features dependent on there importance for there prediction

# Now split the dataset in to train 20%  and test 33%
indexes <- sample(1:sizeOfData, size=0.5*sizeOfData)
test <- iris[indexes,]
train <- iris[-indexes,]

library(sqldf);
sqldf("select species, count(distinct species) from test")


# Assign training labels as factors
trainingLabels <- factor( c( rep("Iris-setosa", ), rep("Iris-versicolor", ), rep("Iris-virginica", )) )

# Validate training labels as numeric values
as.numeric( trainingLabels)

# Set the number of nearest neighbours for a point
nearestNeighbours <- 5

knnModel <- knn(train, test, trainingLabels, k = nearestNeighbours, prob=TRUE, use.all=FALSE)
attributes(.Last.value)

# Now perform training and testing
summary( knnModel )

# Export the resulting model as PMML file.
# THIS IS NOT CURRENTLY SUPPORTED
# localfilename <- "../models/iris-knn-prediction.xml"
# saveXML(pmml( knnModel, model.name = "IrisPredictionKNN", app.name = "RR/PMML", dataset = dataset) , file = localfilename)



