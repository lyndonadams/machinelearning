require(randomForest)

# select random rows function
randomRows = function(df,n){
  return(df[sample(nrow(df),n),])
}

optimalTreeSize.rf <- function( modelFormula, trainingData, iterations, initNumTree, treeStep ){
  bestTree <- c()
  prevErr <- 100
  for(i in 1:iterations){
    # Train the RF using selected set of features for N interal random trees
    fit <- randomForest( as.formula(modelFormula), data=trainingData, ntree=initNumTree)
    currErr <- sum( data.frame(fit$confusion)["class.error"] )/2
    if(  currErr < prevErr ){
      bestTree <- fit
    }
    prevErr <- currErr
    initNumTree <- initNumTree + treeStep
  }
  return(bestTree)
}

sqBestFeatureModel.rf <- function(modelFormula, data, targetVar, maxIterations, numStartTrees, treeStepCount, attrThreshold ){
  
  features <- colnames(trainingSet, do.NULL = TRUE, prefix = "col")
  errMeasure <- c()
  bestFit <- c()
  bestFeatureErr <- 2000
  
  # Loop through all features we have
  for (n in 1:maxIterations){
    
    X <- data[ features ]
    
    bestTree <- optimalTreeSize.rf( modelFormula, X, maxIterations, numStartTrees, treeStepCount)
    
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
      print(bestFit)
      print( features)
    }
    
    # Add back in the target variable
    if( ! targetVar %in% features){
      features <- append( features, targetVar)
    } 
    
    # Increase threshold  
    attrThreshold <- attrThreshold + 1
  }
  
  return( list(tree=bestFit, errors=c(errMeasure)))
}