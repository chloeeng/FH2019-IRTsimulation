rm(list=ls())
require('tidyr')
require('dplyr')
require('magrittr')
require('gtools')
require('rlang')

#DO NOT EDIT
#call this function to do a single simulation
do.single.sim <- function(pars){
  number0 <- pars[["number0"]]
  number1 <- pars[["number1"]]
  number = number0 + number1
  mean.ability.study0 <- pars[["mean.ability.study0"]]
  sd.ability.study0 <- pars[["sd.ability.study0"]]
  mean.ability.study1 <- pars[["mean.ability.study1"]]
  sd.ability.study1 <- pars[["sd.ability.study1"]]
  num.items <- pars[["num.items"]]
  items.study0 <- pars[["items.study0"]]
  items.study1 <- pars[["items.study1"]]
  item.difficulties <- pars[["item.difficulties"]]
  item.discriminations <- pars[["item.discriminations"]]
  #checks
  test1 <- !length(item.difficulties)==num.items
  test2 <- !length(item.discriminations)==num.items
  if(test1|test2){
    if(test1)print("Error: wrong number of item difficulties")
    if(test2)print("Error: wrong number of item discriminations")
    return(NULL)
  }
  # items
  item.data <- data.frame(item.number=1:num.items)
  item.data %<>% mutate(difficulty=item.difficulties,
                        discriminiation=item.discriminations)
  item.data %<>% mutate(item.name=paste("item",item.number,sep=""))
  #simulate one scenario
  data <- data.frame(ID=1:number)
  data %<>% mutate(study=1)
  data[1:number0,"study"] <- 0
  data %<>% mutate(ability=NA)
  data %<>% mutate(ability=
                     ifelse(study==0,
                            rnorm(number,mean.ability.study0,sd.ability.study0),ability))
  data %<>% mutate(ability=
                     ifelse(study==1,
                            rnorm(number,mean.ability.study1,sd.ability.study1),ability))
  
  for(ii in 1:num.items){
    item.name <- item.data$item.name[ii]
    discrimination <- item.data$discriminiation[ii]
    difficulty <- item.data$difficulty[ii]
    data %<>% rowwise %>% mutate(!!item.name:=
                                   rbinom(1,1,inv.logit(discrimination*(ability-difficulty))))
    data %<>% mutate(!!item.name:=
                       ifelse(!(ii%in%items.study0)&(study==0),
                              NA,!!parse_expr(item.name)))
    data %<>% mutate(!!item.name:=
                       ifelse(!(ii%in%items.study1)&(study==1),
                              NA,!!parse_expr(item.name)))
  }
  data
}

do.many.sims <- function(pars,num.sims,scenario.name){
  pars$anchor.items <-
    pars$items.study0[pars$items.study0 %in% pars$items.study1]
  #system.command <- paste('if [ -d', scenario.name, ']; then echo 1; else echo 0; fi ') 
  #make.dir <- system(system.command)
  #if(!make.dir){
  #  system.command <- paste("mkdir",scenario.name,sep=" ")
  #  system(system.command)
  #}
  file.name <- paste("pars_scenario",scenario.name,
                     ".RData",sep="")
  save(pars,file=file.name)
  for(ii in 1:num.sims){
    tmp.data <- do.single.sim(pars)
    file.name <- paste("simdata_scenario",scenario.name,
                       "_num",ii,".csv",sep="")
    write.csv(tmp.data,file=file.name)
  }
}

#EDIT STARTING HERE
#parameters
#set input parameters
pars <- list(
  number0=500, #number in study0
  number1=500, #number in study1
  mean.ability.study0=-0.5, #mean ability in study0
  sd.ability.study0=1, #sd in ability in study0
  mean.ability.study1=0.5, #mean ability in study1
  sd.ability.study1=1, #sd in ability in study1
  num.items=15, #number of items
  items.study0=c((1:7)*2,7,9), #items in study0
  items.study1=c((0:7)*2+1,8), #items in study1
  item.difficulties= seq(-2.1,2.1,0.3), #item difficulties
  item.discriminations=rep(1,15) #item discriminations
)

#code to do a single simulation 
tmp <- do.single.sim(pars)
#write.csv(tmp,file="test_data.csv") #code to save to csv

#code to do a multiple simulations and save to csv
#set the number of simulations
do.many.sims(pars,scenario.name="TTTT",num.sims=10)





