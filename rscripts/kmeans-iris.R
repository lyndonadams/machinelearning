require(pmml)  # for storing the model in pmml
require(class) # Load the class package that holds the kmeans() function
require(ggplot2)

# Load the data and keep the column headers
iris <- read.table("../data/iris.csv",sep=",", header=TRUE)

# Get the number of rows loaded
sizeOfData <- nrow( iris)

# Remove the species label from the data set 
iris.use = subset(iris,select=-species)

# Function o iterate over the number clusters to find the best fit of clusters.
wssplot <- function(data, nc=25, seed=1234){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i)$withinss)
  }
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")
}

# Plot how well the fitting for the number of clusters 
wssplot(data=iris.use, nc=5, seed=23423)

km <- kmeans( iris.use,centers=3, iter.max=1000,nstart=25)
ct.km<- table(iris$species, km$cluster)

# Display number of members per cluster
print(km$size)

# Display the clustering result by label
print(ct.km)

# Now can we see if we can do any better with the clustering?
require(flexclust)
randIndex(ct.km)

# Compute distance matric between rows 
d = dist(iris.use, method='euclidean')

require(cluster)

# Compute pairwise 
d1 = daisy(iris.use)

sum(abs(d - d1))

dd = dist(iris.use,method='euclidean') 
sum(abs(as.matrix(dd) - as.matrix(d1)))

# Compute the Hierarchical Clustering
z = agnes(d)

# Display table of results
table(cutree(z,3),iris$species)

splom(~iris,groups=iris$species,auto.key=TRUE)


