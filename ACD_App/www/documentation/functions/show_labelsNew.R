show_labelsNew <- function(){
  env <- environment(climssc::add_defaults)
  env.vars <- ls(envir = env)
  id <- grep("_label$", env.vars)
  values <- sapply(1:length(id), function(i){
    get(env.vars[grep("_label$", env.vars)[i]])
  })
  
  df <- data.frame(gsub("_label", "", env.vars[id]), values)
  colnames(df) <- c("element label", "default label")
  write.csv(df, file = file.path("..","examples", "default_labels.csv"), row.names = F)
}