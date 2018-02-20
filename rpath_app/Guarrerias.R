results <- data.frame(matrix(c(NA),nrow=1,ncol=2)) 
results


colnames(results) <- c("a","b") 

catalysis.df <- data.frame(matrix(c(NA),nrow=1,ncol=3)) 
catalysis.df[1,2] <- "hola"

sifx <- toSifnx("www/file24ac2ede5404.owl")

for (neighbors in neighbor_of){
  catalysis.df <- rbind(catalysis.df, c(NA,neighbors,NA))
}
colnames(catalysis.df) <- c("imput","protein","output")
rbind(catalysis.df, c(2,2,3))
catalysis.df <- rbind(catalysis.df,c("hola","don","pepito"))
sif <- rbind(sif,c("SmallMoleculeB","consumption-controlled-by", "ProteinB"))

x <- list(a=1,b=2,c=3)
list.append(x,c(4,5),c(4,5))
list.append(x,d=4,f=c(2,3))

list.catalysis <- list()
list.imput <- list()
list.output <-list

length(interactions$PARTICIPANT_A)
interaction.new <- interactions[8]
interaction.new$INTERACTION_TYPE <- "controls-phosphorylation-of"
interactions[8]<-interaction.new
