require(pmml)  # for storing the model in xml
require(class) # Load the class package that holds the knn() function
library(ggplot2)

# Load the data and keep the column headers
iris <- read.table("../data/iris.csv",sep=",", header=TRUE)

# Get the number of rows loaded
sizeOfData <- nrow( iris)

iris.use = subset(iris,select=-species)


# Plot 
wssplot <- function(data, nc=25, seed=1234){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i)$withinss)
  }
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")
}


wssplot(data=iris.use, nc=10, seed=91892)

km <- kmeans(test,centers=3, iter.max=10,nstart=25)
ct.km<- table(iris$species, km$cluster)

km$size
ct.km

library(flexclust)
randIndex(ct.km)



d = dist(iris.use)
library(cluster)
d1 = daisy(iris.use)
sum(abs(d - d1))

dd = dist(iris.use,method='manhattan')
sum(abs(as.matrix(dd) - as.matrix(d1)))

z = agnes(d)

table(cutree(z,3),iris$species)
splom(~iris,groups=iris$species,auto.key=TRUE)
