require(randomForest)
require(pmml)  # for storing the model in xml

source( 'lib/rforestHelperFunctions.R')


# Load the data and keep the column headers
creditapps <- read.table("../data/creditcard_applications.txt",sep=",", header=FALSE)

# Get the number of rows loaded
sizeOfData <- nrow( creditapps )

# Type the columns
creditapps$V2 <- as.numeric( creditapps$V2)
creditapps$V3 <- as.numeric( creditapps$V3)
creditapps$V8 <- as.numeric( creditapps$V8)
creditapps$V11 <- as.numeric( creditapps$V11)
creditapps$V15 <- as.numeric( creditapps$V15)
creditapps$V14 <- as.numeric( creditapps$V14)

# ENUM
creditapps$V1 <- as.factor( creditapps$V1)
creditapps$V16 <- ifelse(creditapps$V16 == "+", "YES", "NO")
creditapps$V16 <- as.factor( creditapps$V16)

# Mix up the table using the random function
creditapps <- randomRows( creditapps, sizeOfData)

# Now split the dataset in to test 60%  and train 40%
indexes <- sample(1:sizeOfData, size=0.6*sizeOfData)
testingSet <- creditapps[-indexes,]
trainingSet <- creditapps[indexes,]

# Set target variable 
target <- trainingSet[["V16"]] 


formula <- "V16 ~." 
attrThreshold <- 4
iterations <- 10
initTreeCount <- 35
treeCountStep <- 5

bestFittingTree <- sqBestFeatureModel.rf( formula,  trainingSet, "V16", iterations, initTreeCount, treeCountStep, attrThreshold )

tree <- bestFittingTree$tree
errors <- bestFittingTree$errors
# Output error plot
plot( errors)

# importance of each predictor
print(bestFittingTree)
importance(bestFittingTree$tree )
varImpPlot(bestFittingTree$tree)

plot( predict(bestFittingTree$tree), target)

# Write the model to pmml file
localfilename <- "../models/creditapp-randomforest-prediction.xml"
pmmlDoc <- pmml( bestTree, model.name = "CreditAppPredictionRForest", app.name = "RR/PMML", dataset = dataset)

# Print out the resulting XML for debugging
#cat(toString(pmmlDoc))

#saveXML( pmmlDoc,  file = localfilename)




