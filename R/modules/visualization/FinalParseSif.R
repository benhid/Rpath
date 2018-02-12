library("rlist")

parseSifToDataModel <- function(sif){
  Links<-c()
  FinalNodes <- c()
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
  controlReaction <- c()
  #Metadatos para almacenamiento de links
  source <- c()
  target <- c()
  tipoLink <- c()
  Links <- data.frame()
  #Control de fosforilaicon
  controlPhospho <- c()
  counterPhospho <- 1
  proteinChangePhosphoA <- c()
  phosphoChangeProteinB <- c()
  #Contorl de estado
  controlState <- c()
  stateChangeProteinsB <- c()
  proteinsChangeStateA <- c()
  counterControlState <- 1
  #contorl expresion of
  controlExpresion <- c()
  counterExpresion <- 1
  expresionProteins <- c()
  #chemical-affects
  controlChemicalAffects <- c()
  counterChemical <- 1
  chemicalProteins <- c()
  chemicalSM <- c()
  
  in_complex_Proteins <- c()
  interactsProteins <- c()
  #Lectura del sif y sus relaciones
  for(i in c(1:length(sif$INTERACTION_TYPE))){
    switch(sif$INTERACTION_TYPE[i],
           "chemical-affects" ={
             P <- sif$PARTICIPANT_B[i]
             SM <- sif$PARTICIPANT_A[i]
             if(!any(chemicalProteins == P)){
               chemicalProteins <- c(chemicalProteins, P)
             }
             if(!any(chemicalSM == SM)){
               chemicalSM <- c(chemicalSM, SM)
             }
             controlChemicalAffects <- c(controlChemicalAffects, paste("control_chemical", counterChemical))
             posCOUNT <- controlChemicalAffects[counterChemical]
             source <- c(source, SM)
             target <- c(target, posCOUNT)
             tipoLink <- c(tipoLink, "controlOf")
             
             source<- c(source, P)
             target <- c(target, posCOUNT)
             tipoLink <- c(tipoLink, "imputLink")
             
             source <- c(source, posCOUNT)
             target <- c(target, paste(P,"_chem_Affects"))
             tipoLink <- c(tipoLink, "outputLink")
             counterChemical = counterChemical + 1 
           },
            "interacts-with" = {
              PA <- sif$PARTICIPANT_A[i]
              PB <- sif$PARTICIPANT_B[i]
              interactsProteins <- c(interactsProteins, PA, PB)
              source <- c(source, PA)
              target <- c(target, PB)
              tipoLink <- c(tipoLink, "molecule_interaction")
            }
           ,"in-complex-with" = {
             PA <- sif$PARTICIPANT_A[i]
             PB <- sif$PARTICIPANT_B[i]
             in_complex_Proteins <- c(in_complex_Proteins, PA, PB)
             source <- c(source, PA)
             target <- c(target, PB)
             tipoLink <- c(tipoLink, "in_complexLink")
             
           }
           ,
           "controls-expression-of" = {
             if(!any(expresionProteins==sif$PARTICIPANT_A[i])){
               expresionProteins <- c(expresionProteins, sif$PARTICIPANT_A[i])
             }
             if(!any(expresionProteins==sif$PARTICIPANT_B[i])){
               expresionProteins <- c(expresionProteins, sif$PARTICIPANT_B[i])
             }
             controlExpresion <- c(controlExpresion, paste("control_expression", counterExpresion))
             source <- c(source, sif$PARTICIPANT_A[i])
             target <- c(target, controlExpresion[counterExpresion])
             tipoLink <- c(tipoLink, "controlOf")
             
             source <- c(source, controlExpresion[counterExpresion])
             target <- c(target, sif$PARTICIPANT_B[i])
             tipoLink <- c(tipoLink, "outputLink")
             counterExpresion = counterExpresion + 1
           },
           "controls-phosphorylation-of" = {
             if(!any(proteinChangePhosphoA == sif$PARTICIPANT_A[i])){

               proteinChangePhosphoA <- c(proteinChangePhosphoA, sif$PARTICIPANT_A[i])
             }
             if(!any(phosphoChangeProteinB == sif$PARTICIPANT_B[i])){
               phosphoChangeProteinB <- c(phosphoChangeProteinB, sif$PARTICIPANT_B[i])
             }
             controlPhospho <- c(controlPhospho, paste("phospho_control", counterPhospho))
             #añadimos enlace proteina entrante->control
             source <- c(source, sif$PARTICIPANT_B[i])
             target <- c(target, controlPhospho[counterPhospho])
             tipoLink <- c(tipoLink, "imputLink")
             #añadimos enlace proteinaControl->contorl
             source <- c(source, sif$PARTICIPANT_A[i])
             target <- c(target, controlPhospho[counterPhospho])
             tipoLink <- c(tipoLink, "controlOf")
             #añadimos enlace control->proteinaPhospho
             source <- c(source, controlPhospho[counterPhospho])
             target <- c(target, paste(sif$PARTICIPANT_B[i],"_P"))
             tipoLink <- c(tipoLink, "outputLink")
             
             counterPhospho <- counterPhospho + 1
           },
           "controls-state-change-of" = { 
             #añadimos el enlace proteina inicial->control
             if (!any(stateChangeProteinsB==sif$PARTICIPANT_B[i])){
               stateChangeProteinsB <- c(stateChangeProteinsB, sif$PARTICIPANT_B[i])
             }
             if (!any(proteinsChangeStateA==sif$PARTICIPANT_A[i])){
               proteinsChangeStateA <- c(proteinsChangeStateA, sif$PARTICIPANT_A[i])
             }
             controlState <- c(controlState, paste("controlState",counterControlState))
             source <- c(source, sif$PARTICIPANT_B[i])
             target <- c(target, controlState[counterControlState])
             tipoLink <- c(tipoLink, "imputLink")
             #añadimos el enlace proteinaControl->control
             source <- c(source, sif$PARTICIPANT_A[i])
             target <- c(target, controlState[counterControlState])
             tipoLink <- c(tipoLink, "controlOf")
             #añadimos el enlace control->proteina final
             source <- c(source, controlState[counterControlState])
             target <- c(target, paste(sif$PARTICIPANT_B[i],"_STATE_CHANGE"))
             tipoLink <- c(tipoLink, "outputLink")
             
             counterControlState <- counterControlState + 1
           },
           "consumption-controlled-by"={
             SM <- sif$PARTICIPANT_A[i]
             
             if (!any(proteins==sif$PARTICIPANT_B[i])){
               proteins <- c(proteins, sif$PARTICIPANT_B[i])
               smallA <- c(smallA,SM)
               
             }else{
               posP <- grep(sif$PARTICIPANT_B[i], proteins)
               
               smallA[[posP]] <- c(smallA[[posP]],SM)
             }
             length(smallB)<-length(proteins)
           },
         "controls-production-of"={
             SM <- sif$PARTICIPANT_B[i]
            
             if (!any(proteins==sif$PARTICIPANT_A[i])){
               proteins <- c(proteins, sif$PARTICIPANT_A[i])
               smallB <- c(smallB,SM)
               
             }else{
               posP <- grep(sif$PARTICIPANT_A[i], proteins)
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
  #Nos quedamos con las proteinas vecinas
  length(neighbor_of) <- length(proteins)
   #Para numerar el numero de reacciones de cambios de estado
  for(i in c(1:length(sif$INTERACTION_TYPE))){
    switch(sif$INTERACTION_TYPE[i],
           "neighbor-of" ={
             
             if (!any(proteins==sif$PARTICIPANT_A[i])){
               proteins <- c(proteins, sif$PARTICIPANT_A[i])
             }
             if (!any(proteins==sif$PARTICIPANT_B[i])){
               proteins <- c(proteins, sif$PARTICIPANT_B[i])
             }
             length(neighbor_of) <- length(proteins)
             posPA<-grep(sif$PARTICIPANT_A[i], proteins, fixed = F)
             posPB<-grep(sif$PARTICIPANT_B[i], proteins, fixed = F)
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
  
  Finalproteins <- list()
  
  #Una vez tenemos el conjunto de vecinos que se autoengloban creamos una lista de proteinas finales
  #Tendremos una entrada en esta lista por cada conjunto de vecinos y por cada proteina que no pertenezca a ningún conjunto
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
  #Finalsmall
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
  #Limpieza Moleculas
  for(i in c(1:length(Finalproteins))){
    FinalsmallA[[i]]<-unique(FinalsmallA[[i]])
    FinalsmallB[[i]]<-unique(FinalsmallB[[i]])
  }
  
  #Cambiamos el nombre de las proteinas que han sufrido un cambio de estado y aprovechamos para añadir algunos nodos
  
  for (i in c(1:length(Finalproteins))){
    NP<-Finalproteins[[i]]
    for(j in c(1:length(NP))){
      if(any(stateChangeProteinsB==NP[j])){
        Finalproteins[[i]][j]<-paste(NP[j],"_STATE_CHANGE")
      }
      if(any(phosphoChangeProteinB == NP[j])){
        Finalproteins[[i]][j]<-paste(NP[j],"_P")
      }
      if(any(chemicalProteins == NP[j])){
        Finalproteins[[i]][j]<-paste(NP[j],"_chem_Affects")
      }
    }
  }
  
  #Creación inicial de links
  for(i in c(1:length(Finalproteins))){
    controlReaction <- c(controlReaction, paste("controlReaction",i))
    for(P in Finalproteins[[i]]){
      source <- c(source, P)
      target <- c(target, controlReaction[i])
      tipoLink <- c(tipoLink, "controlOf")
    }
    for(SM in FinalsmallA[[i]]){
      source <- c(source, SM)
      target <- c(target, controlReaction[i])
      tipoLink <- c(tipoLink, "imputLink")
    }
    for(SM in FinalsmallB[[i]]){
      source <- c(source, controlReaction[i])
      target <- c(target, SM)
      tipoLink <- c(tipoLink, "outputLink")
    }
  }
  Links <- data.frame(source,tipoLink,target)
  ProteinNodes<-c()
  ProteinNodes <- unique(unlist(list(Finalproteins, stateChangeProteinsB, 
                                     proteinsChangeStateA, controlReaction, controlState,
                                     proteinChangePhosphoA, phosphoChangeProteinB, controlPhospho, 
                                     expresionProteins, controlExpresion, chemicalProteins, controlChemicalAffects
                                     , in_complex_Proteins, interactsProteins)))
  smNodes <- c()
  smNodes <- unique(unlist(list(FinalsmallA, FinalsmallB, chemicalSM)))
  FinalNodes <- nodeSet(ProteinNodes, smNodes)
  return(c(Links,FinalNodes))
  
}

nodeSet <- function(ProteinNodes, smNodes){
  #Metadatos para almacenamiento de nodos
  tipoNodo <- c()
  nodos<- c()
  FinalNodes <- data.frame()

  for(P in ProteinNodes){
    if(length(grep("_STATE_CHANGE",P))!=0){
      nodos <- c(nodos, P)
      tipoNodo <- c(tipoNodo, "state_change")
    }else if(length(grep("control",P))!=0){
      nodos<- c(nodos, P)
      tipoNodo <- c(tipoNodo, "control")
    }else if(length(grep("_P", P))!=0){
      nodos <- c(nodos, P)
      tipoNodo <- c(tipoNodo, "withP")
    }else{
      nodos <- c(nodos, P)
      tipoNodo <- c(tipoNodo, "NProt")
    }
  }
  for(SM in smNodes){
    nodos <- c(nodos, SM)
    tipoNodo <- c(tipoNodo, "NSM")
  }
  
  
  FinalNodes <- data.frame(nodos, tipoNodo)
  return(FinalNodes)
}


