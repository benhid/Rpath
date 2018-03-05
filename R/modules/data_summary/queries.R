pw.endpoint <- "http://rdf.pathwaycommons.org/sparql/"

query.custom <-
  'SELECT ?name, ?organism WHERE {
 %s rdf:type bp:Pathway .
 ?pathway bp:pathwayComponent ?c .
 ?pathway bp:organism ?organism .
 ?c bp:name ?name .
 ?c rdf:type bp:BiochemicalReaction
} LIMIT 20'

query.controlreactions <-
  'select  ?nameController ?reference  ?nameControlled where {\n
%s bp:pathwayComponent ?ReactionControl.\n
?ReactionControl a bp:Control .\n
?ReactionControl bp:controller ?controller.\n
?ReactionControl bp:controlled ?controlled.\n
?controller bp:standardName ?nameController.\n
?controlled bp:standardName ?nameControlled.\n
?controller bp:entityReference ?reference. \n}'

query.catalysisreactions <-
  'select  ?nameController ?reference  ?nameControlled where {\n
%s bp:pathwayComponent ?Catalysis.\n
?Catalysis a bp:Catalysis .\n
?Catalysis bp:controller ?controller.\n
?Catalysis bp:controlled ?controlled.\n
?controller bp:entityReference ?reference.\n
?controller bp:standardName ?nameController.\n
?controlled bp:standardName ?nameControlled.\n}'

query.biochemicalreactions <-
  'select ?nameReaction ?nleft ?nright ?leftReference ?rightReference  where {\n
%s bp:pathwayComponent ?s.\n
?s a bp:BiochemicalReaction.\n
?s bp:left ?left.\n
?s bp:right ?right.\n
?s bp:displayName ?nameReaction.\n
?left bp:displayName ?nleft.\n
?right bp:displayName ?nright.\n
?left <http://www.biopax.org/release/biopax-level3.owl#entityReference> ?leftReference.\n
?right <http://www.biopax.org/release/biopax-level3.owl#entityReference> ?rightReference.\n
}'

query.templatereactions <-
  'select * where {\n
     %s bp:pathwayComponent ?TemplateReaction.\n
     ?TemplateReaction a bp:TemplateReaction.\n
     ?TemplateReaction bp:product ?product. \n
     ?product bp:displayName ?name.\n
     ?product  bp:entityReference ?reference.\n}'

query.templatereactionsregulations <-
  'select ?nameController ?reference ?controller where {\n
                                          %s bp:pathwayComponent ?TemplateReactionRegulation.\n
                                          ?TemplateReactionRegulation a bp:TemplateReactionRegulation.\n
                                          ?TemplateReactionRegulation bp:controlled ?controlled.\n
                                          ?TemplateReactionRegulation bp:controller ?controller.\n
                                          ?controller bp:displayName ?nameController.\n
                                          ?controller bp:entityReference ?reference.\n}'

query.degradationreactions <-
  'select * where {\n
                           %s bp:pathwayComponent ?Degradation.\n
                           ?Degradation a bp:Degradation .\n
                           ?Degradation bp:displayName ?name. \n}'

query.modulationreactions <-
  'select ?nameController ?reference ?nameControlled where {\n
                            %s bp:pathwayComponent ?Modulation.\n
                            ?Modulation a bp:Modulation.\n
                            ?Modulation bp:controller ?controller.\n
                            ?controller bp:displayName ?nameController.\n
                            ?controller bp:entityReference  ?reference.\n
                            ?Modulation bp:controlled ?controlled.\n
                            ?controlled bp:displayName ?nameControlled.\n}'

custom1 <-
  'SELECT DISTINCT * WHERE
{ %s bp:pathwayComponent ?reaction .
?reaction bp:displayName ?reaction_name  ;
rdf:type ?reaction_type VALUES ?reaction_type {bp:BiochemicalReaction bp:Degradation bp:TemplateReaction}
OPTIONAL { ?reaction bp:conversionDirection ?direction }
OPTIONAL { VALUES ?direction{"LEFT_TO_RIGHT"} }}'
