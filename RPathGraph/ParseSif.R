sif<-toSif("www/prueba3.owl")

parseSifToDataModel = function(sif){
  proteins <- c()
  smallA <- list()
  smallB <- list()
  participProteinA <- c()
  participProteinB <- c()
  controlReaction <- c()
  by_form = matrix(nrow=8, ncol=3)
  counterSM = 1;
  counterCR = 1;
  
  for(i in c(1:length(sif$INTERACTION_TYPE))){
    switch(sif$INTERACTION_TYPE[i],
           "consumption-controlled-by"={
             SM <- sif$PARTICIPANT_A[i]
             posP <- grep(sif$PARTICIPANT_B[i], proteins)
             
             if (length(posP)==0){
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
             if (length(posP)==0){
               
               smallB <- c(smallB,SM)
               
             }else{
               
               smallB[[posP]] <- c(smallB[[posP]],SM)
             }
             
           },
           "catalysis-precedes" ={
             
             participProteinA <- c(participProteinA, sif$PARTICIPANT_A[i])
             participProteinB <- c(participProteinB, sif$PARTICIPANT_B[i])
           })
  }
  print(proteins)
  print(smallA)
  print(smallB)
  Finalproteins <- proteins
  FinalsmallA <- smallA
  FinalsmallB <- smallB
  for (i in c(1:(length(proteins)-1))){
    
    for (j in c((i+1):length(proteins))){
     
      
      if(length(grep(FALSE,smallA[[i]]==smallA[[j]]))==0 && length(grep(FALSE,smallB[[i]]==smallB[[j]]))==0){
        pos<-grep(proteins[j],Finalproteins)
        if(length(pos)!=0){
          FinalsmallA<-FinalsmallA[-pos]
          FinalsmallB<-FinalsmallB[-pos]
          Finalproteins<-Finalproteins[-pos]
        }
        
      }
    }
  }

  
  #Primera creación de links
  source <- c()
  target <- c()
  tipoLink <- c()
  Links <- data.frame()
  for(i in c(1:length(Finalproteins))){
    controlReaction <- c(controlReaction, paste("controlReaction",i))
  }
  for(i in c(1:length(FinalsmallA))){
    for(jSMA in c(1:length(FinalsmallA[[i]]))){
      source <- c(source,FinalsmallA[[i]][jSMA] )
      tipoLink <- c(tipoLink,"imputLink")
      target <- c(target,controlReaction[i])
    }
    for(jSMB in c(1:length(FinalsmallB[[i]]) )){
      target <- c(target,FinalsmallB[[i]][jSMB] )
      print(FinalsmallB[[i]][jSMB])
      tipoLink <- c(tipoLink, "outputLink")
      source <- c(source, controlReaction[i])
    }
      source <- c(source, Finalproteins[i])
      target <- c(target, controlReaction[i])
      tipoLink <- c(tipoLink, "controlOf")
  }
  lon <- max(length(source),length(target),length(tipoLink))
  length(source)<-lon
  length(target)<-lon
  length(tipoLink)<-lon
  Links <- data.frame(source,tipoLink,target)
  return(Links)
}

parseSifToDataModel(sif)