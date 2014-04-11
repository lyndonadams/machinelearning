require(pmml)  # for storing the model in xml
require(ggplot2)  # for visualization
require(cluster)
require( fpc)
require( car)
#require(graphics)

abalone <- read.table("../data/abalone.csv",sep=",", header=TRUE)
abaloneNames <- c("sex","length","diameter","height","whole_weight","shucked_weight","viscera_weight","shell_weight","rings")
colnames(abalone) <- abaloneNames

# This will convert Sex from M,F,I to a digit
#as.factor(abalone$sex)

abalone[,1] <- as.character( abalone[,1])
abalone[abalone$sex == "M",1] <- "1"
abalone[abalone$sex == "F",1] <- "2"
abalone[abalone$sex == "I",1] <- "0"

# Remove Sex
abalone$Sex <- NULL

# Select the feature space
features <- c("whole_weight", "diameter", "rings", "length", "height")
abalone <- abalone[ features ]


# Move features in to log space since lm works better when all features are equally scaled.
abalone <- scale( abalone )

# Now split the dataset in to train 80%  and test 20%
indexes <- sample(1:nrow(abalone), size=0.2*nrow(abalone))
test <- abalone[indexes,]
train <- abalone[-indexes,]

# Now train only using a single feature
ringsmodel <- lm(formula = rings ~ diameter, data = train)

# Make sure the p-value is less than 5%
summary( ringsmodel)

# Get a sense how the prediction performed
qplot(x = diameter, 
      y = rings,
      data = train,
      alpha = I(0.2), # alpha makes the points semitransparent so you can see stacked points
      geom = "jitter") + # jitter helps spread the points so they don't stack so much
  geom_smooth(method = lm)

rings_predicted <- 10^(fitted( ringsmodel))

p <- predict.lm( ringsmodel, test, se.fit=TRUE )
pred.w.plim <- predict( ringsmodel, test, interval="prediction")
pred.w.clim <- predict( ringsmodel, test, interval="confidence")
matplot(test$diameter,cbind(pred.w.clim, pred.w.plim[,-1]),
        lty=c(1,2,2,3,3), type="l", ylab="predicted y")

# Look at the actual vs predicted rings
prediction<- data.frame(actual = test$rings,  predicted = p$fit, error = test$rings - p$fit )

plot(abalone$rings, abalone$diameter )

# Look at the mean squared error
mse = mean( residuals( ringsmodel)^2 )

# Export the resulting model as PMML file.
localfilename <- "../models/abalone-height-lm-prediction.xml"
saveXML(pmml( ringsmodel, model.name = "AbaloneRingsPredictionLM", app.name = "RR/PMML", dataset = dataset) , file = localfilename)
