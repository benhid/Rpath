library("rlist")

parseSifInteractions <- function(sifx){
  interactions <- sifx$edges
  components <- sifx$nodes
  Links <- c()
  source <- c()
  target <- c()
  tipoLink <- c()
  controls <- c()

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
  counterExpresion <- 1
  #Phosphorylation
  proteins.phosphorylation <- c()
  counterPhospho <- 1
  #state-change
  proteins.state <- c()
  counterControlState <-1
  #control-expresion-of
  proteins.expresion <- c()
  counterExpresion <- 1
  #chemical-affects
  counterChemical <- 1
  proteins.chemical <- c()
  
  for(i in c(1:length(interactions$INTERACTION_TYPE))){
    ParticipantA <- interactions$PARTICIPANT_A[i]
    ParticipantB <- interactions$PARTICIPANT_B[i]
    switch(interactions$INTERACTION_TYPE[i],
           "controls-production-of" ={
             neighborBoolean <- F
             for (j in c(1:length(neighbor_of))){
               if(length(neighbor_of)>0){
                 if(any(neighbor_of[[j]]==ParticipantA)){
                   neighborImput[[j]] <- c(neighborImput[[j]], ParticipantB) 
                   neighborBoolean <- T
                 }
               }
               
             }
             if(neighborBoolean == F){
               if(any(protein.catalysis == ParticipantA)){
                 poset <- grep(ParticipantA, protein.catalysis)
                 pos <- poset[1]
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
               if(length(neighbor_of)>0){
                 if(any(neighbor_of[[j]]==ParticipantB)){
                   neighborOutput[[j]] <- c(neighborOutput[[j]], ParticipantA) 
                   neighborBoolean <- T
                 }
               }
               
             }
             
             if(neighborBoolean == F){
               if(any(protein.catalysis == ParticipantB)){
                 poset <- grep(ParticipantB, protein.catalysis)
                 pos<-poset[1]
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
             tipoLink <- c(tipoLink, "imputLink")
             #añadimos enlace proteinaControl->contorl
             source <- c(source, ParticipantA)
             target <- c(target, controlPhospho)
             tipoLink <- c(tipoLink, "controlOf")
             #añadimos enlace control->proteinaPhospho
             source <- c(source, controlPhospho)
             target <- c(target, paste(ParticipantB,"_P"))
             tipoLink <- c(tipoLink, "outputLink")
             counterPhospho <- counterPhospho +1
             controls <- c(controls, controlPhospho)
           },
           "controls-state-change-of" = {
             controlState <- paste("controlState",counterControlState)
             source <- c(source, ParticipantB)
             target <- c(target, controlState)
             tipoLink <- c(tipoLink, "imputLink")
             #añadimos el enlace proteinaControl->control
             source <- c(source, ParticipantA)
             target <- c(target, controlState)
             tipoLink <- c(tipoLink, "controlOf")
             #añadimos el enlace control->proteina final
             source <- c(source, controlState)
             target <- c(target, paste(ParticipantB,"_STATE_CHANGE"))
             tipoLink <- c(tipoLink, "outputLink")
             counterControlState <- counterControlState + 1
             controls <- c(controls,controlState)
           },
           "controls-expression-of" = {
             
             controlExpresion <- paste("control_expression", counterExpresion)
             source <- c(source, ParticipantA)
             target <- c(target, controlExpresion)
             tipoLink <- c(tipoLink, "controlOf")
             
             source <- c(source, controlExpresion)
             target <- c(target, ParticipantB)
             tipoLink <- c(tipoLink, "outputLink")
             counterExpresion = counterExpresion + 1
             controls <- c(controls, controlExpresion)
             },
           "interacts-with" = {
             source <- c(source, ParticipantA)
             target <- c(target, ParticipantB)
             tipoLink <- c(tipoLink, "molecule_interaction")
           },
           "in-complex-with" = {
             source <- c(source, ParticipantA)
             target <- c(target, ParticipantB)
             tipoLink <- c(tipoLink, "in_complexLink")}
           ,
           "chemical-affects" ={
             controlChemicalAffects <- paste("control_chemical", counterChemical)
             source <- c(source, ParticipantA)
             target <- c(target, controlChemicalAffects)
             tipoLink <- c(tipoLink, "controlOf")
             
             source<- c(source, ParticipantB)
             target <- c(target, controlChemicalAffects)
             tipoLink <- c(tipoLink, "imputLink")
             
             source <- c(source, controlChemicalAffects)
             target <- c(target, paste(ParticipantB,"_chem_Affects"))
             tipoLink <- c(tipoLink, "outputLink")
             proteins.chemical <- c(proteins.chemical, ParticipantB)
             counterChemical = counterChemical + 1 
             controls<- c(controls, controlChemicalAffects)
           })
  }
  protein.imput <- list.clean(protein.imput, fun = is.null, recursive = T)
  protein.output <- list.clean(protein.output, fun = is.null, recursive = T)
  
  counterCatalysis <- 1
  
  for (i in c(1:length(protein.catalysis))){
    imput.sm <- protein.imput[[i]]
    out <- F
    if(length(protein.output)>=i){
      out <- T
      output.sm <- protein.output[[i]]
    }
    
    for(j in c(1:length(imput.sm))){
      control <- paste("control", counterCatalysis)
      
      source <- c(source, imput.sm[j])
      target <- c(target, control)
      tipoLink <- c(tipoLink, "imputLink")
      if(out){
        source <- c(source, control)
        target <- c(target, output.sm[j])
        tipoLink <- c(tipoLink, "outputLink")
      }
      
      source <- c(source, protein.catalysis[i])
      target <- c(target, control)
      tipoLink <- c(tipoLink, "controlOf")
      
    }
    controls <- c(controls,control)
    counterCatalysis <- counterCatalysis + 1
  }
  
  if(length(neighbor_of)>1){
    for (k in c(1:length(neighbor_of) )){
      sn <- neighbor_of[[k]]
      for (i in c(1:length(sn))){
        imput.sm <- neighborImput[[k]]
        output.sm <- neighborOutput[[k]]
        control <- paste("control", counterCatalysis)
        for(j in c(1:length(imput.sm))){
          
          
          source <- c(source, imput.sm[j])
          target <- c(target, control)
          tipoLink <- c(tipoLink, "imputLink")
          
          source <- c(source, control)
          target <- c(target, output.sm[j])
          tipoLink <- c(tipoLink, "outputLink")
          
          source <- c(source, sn[i])
          target <- c(target, control)
          tipoLink <- c(tipoLink, "controlOf")
        }
      }
      controls <- c(controls, control)
      counterCatalysis <- counterCatalysis + 1
    }
    
  }
  
  Links <- data.frame(source, tipoLink, target)
  
  FinalNodes <- c()
  
  nodos <-c()
  tipoNodo <- c()
  for(p in Proteins){
    nodos<-c(nodos,p)
    tipoNodo <-c(tipoNodo,"NProt")
  }
  if(length(SmallMolecules)>1){
    for(sm in SmallMolecules){
      nodos <- c(nodos,sm)
      tipoNodo <- c(tipoNodo, "NSM")
    }
  }
  print(controls)
  for(c in controls){
    nodos <- c(nodos,c)
    tipoNodo <- c(tipoNodo, "control")
  }
  FinalNodes <- data.frame(nodos, tipoNodo)
  
  return(c(Links,FinalNodes))
}