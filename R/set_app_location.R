################################################################################
#' @export set_app_location
#'
#' @title Select the location of the ACD_App
#' @description This function checks where the ACD_App is located (in 
#' folder ACD_standalone)
#' 
#' @param appDir string. Path where the ACD-App is stored. Typically under 
#' "ACD_standalone". If empty, the user will be ask to select the path
#' interactively.
#'
#' @examples 
#' appDir <- 'C:/Users/username/Documents/ACD_standalone/'
#' set_app_location(appDir)
#'
################################################################################
set_app_location <- function(appDir = NULL){
  while (!exists("appDir") | is.null(appDir)){
    tt <- paste0("log: Please, select the folder 'ACD_standalone', ",
                 "where ACD_App is located")
    print(tt)
    appDir <- choose.dir(caption = "Select folder")
  }
  if (is.na(appDir) | grepl("\\<ACD_standalone\\>", appDir) == F){
    tt <- paste0("log: No ACD_App location selected. ",
                 "A compact version of the App cannot be created") 
    print(tt)
    appDir <- NULL
  }else{
    tt <- paste0("log: ", "'", appDir, "' selected")
    print(tt)
    return(appDir)
  }
  
}