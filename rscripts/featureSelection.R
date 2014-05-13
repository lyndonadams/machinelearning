require(randomForest)
require(pmml)  # for storing the model in xml

# Load the data and keep the column headers
creditapps <- read.table("../data/creditcard_applications.txt",sep=",", header=FALSE)

# Get the number of rows loaded
sizeOfData <- nrow( creditapps )

# select random rows function
randomRows = function(df,n){
  return(df[sample(nrow(df),n),])
}

# Type the columns
creditapps$V2 <- as.numeric( creditapps$V2)
creditapps$V3 <- as.numeric( creditapps$V3)
creditapps$V8 <- as.numeric( creditapps$V8)
creditapps$V11 <- as.numeric( creditapps$V11)
creditapps$V15 <- as.numeric( creditapps$V15)
creditapps$V14 <- as.numeric( creditapps$V14)

# ENUM
creditapps$V1 <- as.factor( creditapps$V1)
creditapps$V16 <- as.factor( creditapps$V16)
creditapps$V16 <- ifelse(creditapps$V16 == "+", "YES", "NO")

# Mix up the table using the random function
creditapps <- randomRows( creditapps, sizeOfData)

# Now split the dataset in to test 60%  and train 40%
indexes <- sample(1:sizeOfData, size=0.6*sizeOfData)
test <- creditapps[-indexes,]
train <- creditapps[indexes,]

# Set features and target variable 
features <- c( "V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10", "V11", "V12", "V13", "V14", "V15")
features <- as.vector( features )
target=as.factor( train[["V16"]] )


bestFeatures <- c()
bestFeatureErr <- 1
bestRandomForestTrees <- 0

errMeasure <- c()
attrThreshold <- 2

# Loop through all features we have
for (n in 1:15 ){
  
  # Set training features
  X <- train[ features ]
  trees <- 5
  prevErr <- 100
  for(i in 1:500){
    # Train the RF using selected set of features for N interal random trees
    fit <- randomForest(x=X, y=target, ntree=35, scale=FALSE)
    
    currErr <- sum( data.frame(fit$confusion)["class.error"] )/2
    if(  currErr < prevErr ){
      bestTree <- fit
    }
    
    prevErr <- currErr
    trees <- trees + 10
  }
  
  # Get error of training and track
  featureErr <- sum( data.frame(bestTree$confusion)["class.error"] )/2
  errMeasure <- append(errMeasure, featureErr, 1)
  
  # Save the best performing forest and feature set
  if( featureErr < bestFeatureErr ){
    bestFit <- bestTree  
    bestFeatures <- features
    bestFeatureErr <- featureErr

    imp <- data.frame( bestFit$importance )
    keepAttr <- ifelse( imp$MeanDecreaseGini > attrThreshold, TRUE, FALSE)
    features <- features[ keepAttr ]

    print("Have a new best model")
    print(bestFit)
  }
  
  # Increase threshold
  attrThreshold <- attrThreshold + 1
}

# Output error plot
plot(errMeasure)

# importance of each predictor
print(bestFit)
importance(bestFit)
varImpPlot(bestFit)

#plot( predict(bestFit), target)

# Write the model to pmml file
#localfilename <- "../models/creditapp-randomforest-prediction.xml"
#saveXML(pmml( fit, model.name = "CreditAppPredictionRForest", app.name = "RR/PMML", dataset = dataset) , file = localfilename)