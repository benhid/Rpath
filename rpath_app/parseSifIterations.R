library("rlist")

parseSifInteractions <- function(sifx){
  interactions <- sifx$edges
  components <- sifx$nodes
  Links <- data.frame()
  source <- c()
  target <- c()
  typeLink <- c()

  # Node type in set
  Proteins <- c() 
  SmallMolecules <- c()
  for(i in c(1:length(components$PARTICIPANT_TYPE))){
    if(components[i]$PARTICIPANT_TYPE == "ProteinReference"){
      Proteins <- c(Proteins, components[i]$PARTICIPANT)
    }else if(components[i]$PARTICIPANT_TYPE == "SmallMoleculeReference"){
      SmallMolecules <- c(SmallMolecules, components[i]$PARTICIPANT)
    }
  }
  
  #neighbor-of interaction type
  neighbor_of <- list()
  length(neighbor_of) <- length(Proteins)
  
  for(i in c(1:length(interactions$INTERACTION_TYPE))){
    ParticipantA <- interactions$PARTICIPANT_A[i]
    ParticipantB <- interactions$PARTICIPANT_B[i]
    switch(interactions$INTERACTION_TYPE[i],
           "neighbor-of" ={
             pos<-match(ParticipantA, Proteins)
             neighbor_of[[pos]] <- c(neighbor_of[[pos]],ParticipantB)
           })
  }
  
  for (j in c(1:length(neighbor_of))){
    setNeighborA <- neighbor_of[[j]]
    for (k in c(1:length(neighbor_of))){
      
      setNeighborB <- neighbor_of[[k]]
      if (!is.null(setNeighborA) && 1==length(unique(setNeighborA %in% setNeighborB))
          && length(setNeighborA)<length(setNeighborB)){
        neighbor_of[[j]]<-NA
        break
        
      }
    }
  }
  for (i in c(1:length(neighbor_of))){
    if(is.null(neighbor_of[[i]])){
      neighbor_of[[i]] <- NA
    }
  }
  for (i in c(1:length(neighbor_of))){
    if(!is.na(neighbor_of[[i]])){
      neighbor_of[[i]] <- c(neighbor_of[[i]],Proteins[i])
    }
  }
  neighbor_of<- neighbor_of[!is.na(neighbor_of)]
  neighbor_of <- list.clean(neighbor_of, fun = is.null, recursive = T)
  
  
  #Rest interactions
  
  #Neighbor_sets
  neighborImput <- list()
  length(neighborImput) <- length(neighbor_of)
  neighborOutput <- list()
  length(neighborOutput) <- length(neighbor_of)
  controlReaction <- c()
  #Proteins catalysis sets
  protein.catalysis <- c()
  protein.imput <- list()
  protein.output <- list()
  length(protein.catalysis) <- length(Proteins)
  length(protein.imput) <- length(Proteins)
  length(protein.output) <- length(Proteins)
  counterPhospho <- 1
  counterControlState <- 1
  #Phosphorylation
  proteins.phosphorylation <- c()
  
  for(i in c(1:length(interactions$INTERACTION_TYPE))){
    ParticipantA <- interactions$PARTICIPANT_A[i]
    ParticipantB <- interactions$PARTICIPANT_B[i]
    switch(interactions$INTERACTION_TYPE[i],
           "controls-production-of" ={
             neighborBoolean <- F
             for (j in c(1:length(neighbor_of))){
               if(any(neighbor_of[[j]]==ParticipantA)){
                 neighborImput[[j]] <- c(neighborImput[[j]], ParticipantB) 
                 neighborBoolean <- T
               }
             }
             if(neighborBoolean == F){
               if(any(protein.catalysis == ParticipantA)){
                 pos <- grep(ParticipantA, protein.catalysis)
                 protein.output[[pos]] <- c(protein.output[[pos]],ParticipantB)
               }else {
                 protein.catalysis <- c(protein.catalysis,ParticipantA)
                 protein.output[[length(protein.catalysis)]] <- ParticipantB
               }
               
             }
             
           },
           "consumption-controlled-by" = {
             neighborBoolean <- F
             for (j in c(1:length(neighbor_of))){
               if(any(neighbor_of[[j]]==ParticipantB)){
                 neighborOutput[[j]] <- c(neighborOutput[[j]], ParticipantA) 
                 neighborBoolean <- T
               }
             }
             
             if(neighborBoolean == F){
               if(any(protein.catalysis == ParticipantB)){
                 pos <- grep(ParticipantB, protein.catalysis)
                 print(pos)
                 protein.imput[[pos]] <- c(protein.imput[[pos]],ParticipantA)
               }else {
                 protein.catalysis <- c(protein.catalysis,ParticipantB)
                 protein.imput[[length(protein.catalysis)]] <- ParticipantA
               }
               
             }
           },
           "controls-phosphorylation-of" = {
             controlPhospho<-paste("phospho_control", counterPhospho)
             source <- c(source, ParticipantB)
             target <- c(target, controlPhospho)
             typeLink <- c(typeLink, "imputLink")
             #añadimos enlace proteinaControl->contorl
             source <- c(source, ParticipantA)
             target <- c(target, controlPhospho)
             typeLink <- c(typeLink, "controlOf")
             #añadimos enlace control->proteinaPhospho
             source <- c(source, controlPhospho)
             target <- c(target, paste(ParticipantB,"_P"))
             typeLink <- c(typeLink, "outputLink")
             counterPhospho <- counterPhospho +1
             proteins.phosphorylation <- c(proteins.phosphorylation, ParticipantB)
           },
           "controls-state-change-of" = {
             controlState <- paste("controlState",counterControlState)
             source <- c(source, ParticipantB)
             target <- c(target, controlState)
             typeLink <- c(typeLink, "imputLink")
             #añadimos el enlace proteinaControl->control
             source <- c(source, ParticipantA)
             target <- c(target, controlState)
             typeLink <- c(typeLink, "controlOf")
             #añadimos el enlace control->proteina final
             source <- c(source, controlState)
             target <- c(target, paste(ParticipantB,"_STATE_CHANGE"))
             typeLink <- c(typeLink, "outputLink")
             counterControlState <- counterControlState + 1
           })
  }
}