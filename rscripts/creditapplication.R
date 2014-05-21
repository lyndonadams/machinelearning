require(randomForest)
require(pmml)  # for storing the model in xml

# Load the data and keep the column headers
creditapps <- read.table("../data/creditcard_applications.txt",sep=",", header=FALSE)

# Get the number of rows loaded
sizeOfData <- nrow( creditapps )

creditapps$V16 <- ifelse(creditapps$V16 == "+", "YES", "NO")

# Type the columns
creditapps$V2 <- as.numeric( creditapps$V2)
creditapps$V3 <- as.numeric( creditapps$V3)
creditapps$V8 <- as.numeric( creditapps$V8)
creditapps$V11 <- as.numeric( creditapps$V11)
creditapps$V15 <- as.numeric( creditapps$V15)

creditapps$V14 <- as.character( creditapps$V14)

creditapps$V16 <- as.factor( creditapps$V16)

# select random rows function
randomRows = function(df,n){
  return(df[sample(nrow(df),n),])
}

# Mix up the table using the random function
creditapps <- randomRows( creditapps, sizeOfData)

# Now split the dataset in to test 60%  and train 40%
indexes <- sample(1:sizeOfData, size=0.6*sizeOfData)
test <- creditapps[indexes,]
train <- creditapps[-indexes,]

# Train the RF using selected set of features for 35 interal trees to grow
fit <- randomForest(V16 ~ V6 +V8 +V9 +V10 +V11 +V15, data=train, ntree=35 )
test <- subset(test, select = -c(V1,V2,V3, V4, V5, V7, V12, V13, V14 ) )

# view results 
print(fit) 

# importance of each predictor
importance(fit) 

# Variable importance plot
varImpPlot(fit)


# Predict
p <- predict( fit, test )
summary( p)
print( test[1,])

#traceback()

# Write the model to pmml file
localfilename <- "../models/creditapp-randomforest-prediction.xml"
saveXML( pmml( fit, model.name = "CreditAppPredictionRForest", app.name = "RR/PMML", dataset = dataset),  file = localfilename)

# Write test file to csv
write.table( test, file="../data/test_creditapp.csv", sep=",", row.names=FALSE)
