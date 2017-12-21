sif<-toSif("www/file251c7b0510f5.owl")
sif<-toSif("www/prueba3.owl")
library("rlist")

usedToProduceFunction(){
  #Añadir moléculas de used-to-produce
  #existUTPB <- match(unlist(usedToProducePB), unlist(FinalsmallB))
  #existUTPB <- existUTPB[!is.na(existUTPB)]
  existUTPB <- intersect(usedToProducePB,unlist(FinalsmallB))
  #existUTPA <- match(unlist(usedToProducePA), unlist(FinalsmallA))
  #existUTPA <- existUTPA[!is.na(existUTPA)]
  existUTPA <- intersect(usedToProducePA,unlist(FinalsmallA))
  PusedToProducePB <- usedToProducePB
  PusedToProducePA <- usedToProducePA
  for(i in c(1:length(PusedToProducePA))){
    if(any(existUTPA==PusedToProducePA[i])){
      posToDelete <- c()
      for (j in c(1:length(PusedToProducePB[[i]]))){
        PUTPB <- PusedToProducePB[[i]]
        if(!any(existUTPB==PUTPB[j])){
          posToDelete <- c(posToDelete,j)
        }
      }
      print(posToDelete)
      if(length(posToDelete)!=0 && !is.null(posToDelete)){
        if(length(usedToProducePB[[i]][-posToDelete])==0){
          usedToProducePB[i] <- NA
          usedToProducePA[i] <- NA
        }else{
          usedToProducePB[i]<-PusedToProducePB[[i]][-posToDelete]
        }
      }
    }else{
      print("hola")
      usedToProducePA[i] <- NA
      usedToProducePB[i] <- NA
    }
  }
  #usedToProducePA<-usedToProducePA[!is.na(usedToProducePA)]
  #usedToProducePB<-usedToProducePB[!is.na(usedToProducePB)]
  
  for(i in c(1:length(usedToProducePA))){ #Eliminamos aquellos used to produce que ya tenemos por proteinas y los que no existen de entrada
    for(j in c(1:length(FinalsmallA))){
      
      if(any(FinalsmallA[[j]]==usedToProducePA[i])){
        produced <- usedToProducePB[[i]]
        FSB<-FinalsmallB[[j]]
        coincidence <- match(FSB, produced)
        coincidence<-coincidence[!is.na(coincidence)]
        if(length(coincidence) != 0){
          usedToProducePB[[i]] <- produced[-coincidence]
        }
      }
    }
  }
}

parseSifToDataModel <- function(sif){
  proteins <- c()
  smallA <- list()
  smallB <- list()
  participProteinA <- c()
  participProteinB <- c()
  usedToProducePA <- c()
  usedToProducePB <- list()
  reactWithPA<-c()
  reactWithPB<-list()
  neighbor_of<-list()
  
  #Lectura del sif y sus relaciones
  for(i in c(1:length(sif$INTERACTION_TYPE))){
    switch(sif$INTERACTION_TYPE[i],
           "consumption-controlled-by"={
             
             SM <- sif$PARTICIPANT_A[i]
             posP <- grep(sif$PARTICIPANT_B[i], proteins)
             if (!any(proteins==sif$PARTICIPANT_B[i])){
               proteins <- c(proteins, sif$PARTICIPANT_B[i])
               smallA <- c(smallA,SM)
               
             }else{
               smallA[[posP]] <- c(smallA[[posP]],SM)
             }
             length(smallB)<-length(proteins)
           },
           "controls-production-of"={
             SM <- sif$PARTICIPANT_B[i]
             posP <- grep(sif$PARTICIPANT_A[i], proteins)
             if (!any(proteins==sif$PARTICIPANT_A[i])){
               proteins <- c(proteins, sif$PARTICIPANT_A[i])
               smallB <- c(smallB,SM)
               
             }else{
               
               smallB[[posP]] <- c(smallB[[posP]],SM)
             }
             length(smallA)<-length(proteins)
             
           },
           
           "catalysis-precedes" ={
             
             participProteinA <- c(participProteinA, sif$PARTICIPANT_A[i])
             participProteinB <- c(participProteinB, sif$PARTICIPANT_B[i])
           },
           
           "used-to-produce" ={
             PA <- sif$PARTICIPANT_A[i]
             PB <- sif$PARTICIPANT_B[i]
             
             if(any(usedToProducePA == PA)){
               posPA<-grep(PA, usedToProducePA, fixed = T)
               
               usedToProducePB[[max(posPA)]] <- c(usedToProducePB[[max(posPA)]],PB)
             }else{
               usedToProducePA<-c(usedToProducePA,PA)
               usedToProducePB<-c(usedToProducePB,PB)
               length(usedToProducePB)<-length(usedToProducePA)
             }
             
           },
           "reacts-with" ={
             PA <- sif$PARTICIPANT_A[i]
             PB <- sif$PARTICIPANT_B[i]
             
             if(any(reactWithPA == PA)){
               posPA<-grep(PA, reactWithPA, fixed = T)
               
               reactWithPB[[max(posPA)]] <- c(reactWithPB[[max(posPA)]],PB)
             }else{
               reactWithPA<-c(reactWithPA,PA)
               reactWithPB<-c(reactWithPB,PB)
               length(reactWithPB)<-length(reactWithPB)
             }
           }
      )
  }
  
  length(neighbor_of) <- length(proteins)
  for(i in c(1:length(sif$INTERACTION_TYPE))){
    switch(sif$INTERACTION_TYPE[i],
           "neighbor-of" ={
             posPA<-grep(sif$PARTICIPANT_A[i], proteins)
            
             posPB<-grep(sif$PARTICIPANT_B[i], proteins)
             neighbor_of[[posPA]]<-c(neighbor_of[[posPA]], proteins[posPB])
             neighbor_of[[posPA]]<-c(neighbor_of[[posPA]], proteins[posPA])
             neighbor_of[[posPA]]<-unique(neighbor_of[[posPA]])
           })
  }

#Quedarnos con los conjuntos de vecinos que se autoengloban
  Final_neighbor_of<-list()
  for(i in c(1:(length(neighbor_of)-1))){
    length(Final_neighbor_of)<-length(neighbor_of)
    for(j in c((i+1):(length(neighbor_of)))){
      
      trueVector <- match(neighbor_of[[j]],neighbor_of[[i]])
      trueVector <- trueVector[!is.na(trueVector)]
      trueVectorL <- length(trueVector)
      if(length(neighbor_of[[j]])>length(neighbor_of[[i]]) && trueVectorL == length(neighbor_of[[i]])){
        Final_neighbor_of[[i]]<-neighbor_of[[j]]
      }else if(length(neighbor_of[[i]])>length(neighbor_of[[j]]) && trueVectorL == length(neighbor_of[[j]]) &&
               length(Final_neighbor_of[[i]])<length(neighbor_of[[i]])){
        Final_neighbor_of[[i]]<-neighbor_of[[i]]
      }
    }
  }
  Final_neighbor_of <-list.clean(unique(Final_neighbor_of), fun = is.null, recursive = TRUE) 
  
#Creamos una reaccion de control por cada conjunto de proteinas independiente y por proteinas que no participan en ningun conjunto
  Finalproteins <- list()
  
  
  Finalproteins<-Final_neighbor_of
  for(P in proteins){
    containsConfirm <- F
    for(FN in Finalproteins){
      
      if(any(FN==P)){
        containsConfirm<-T
        break
      }
    }
    if(!containsConfirm){
      Finalproteins <- c(Finalproteins, P)
    }
  }
  #Catalisis
  for(i in c(1:length(participProteinA))){
    posPA <- grep(participProteinA[i], proteins)
    posPB <- grep(participProteinB[i], proteins)
    FinalsmallA[[posPB]] <- unique(c(FinalsmallA[[posPB]],FinalsmallB[[posPA]]))
    
  }
  #Agrupacion de moleculas de entrada en cada conjunto de proteinas vecinas
  FinalsmallA <- list()
  length(FinalsmallA) <- length(Finalproteins)
  FinalsmallB <- list()
  length(FinalsmallB) <- length(Finalproteins)
  
  for(i in c(1:length(proteins))){
    for(j in c(1:length(Finalproteins))){
      if(any(Finalproteins[[j]]==proteins[i])){
        FinalsmallA[[j]]<-c(FinalsmallA[[j]],smallA[[i]])
        FinalsmallB[[j]]<-c(FinalsmallB[[j]],smallB[[i]])
       
      }
    }
  }
  #Enumeracion inicial de moleculas
  for(i in c(1:length(Finalproteins))){
    FinalsmallA[[i]]<-unique(FinalsmallA[[i]])
    FinalsmallB[[i]]<-unique(FinalsmallB[[i]])
  }

  #
  
  
  

}



parseSifToDataModel(sif)
