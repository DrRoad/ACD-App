################################################################################
#' @export compact.large
#'
#' @title Compact the ACD-App (large version)
#'
#' @description This function creates a new folder called "ACD_compact_large"
#' that contains all the files required for the installation and run of the
#' ACD-App. Its size is around 120 Mb
#' 
#' @param appDir string. Path where the ACD-App is stored. Typically under 
#' "ACD_standalone". If empty, the user will be ask to select the path
#' interactively.
#'
#' @details The folder created should be considered as an "installation" 
#' package, with which the user will be able to install the ACD-App without 
#' having access to the internet.
#'
#' @examples 
#' appDir <- 'C:/Users/userName/ACD_standalone/'
#' compact_large(appDir)
#'
################################################################################

compact_large <- function(appDir = NULL){
  
  ##############################################################################
  #
  #                           SET ACD_APP LOCATION
  #
  ##############################################################################
  if (is.null(appDir)){
    appDir <- set_app_location(appDir)
  }
  ##############################################################################
  #
  #                                   COPY FILES
  #
  ##############################################################################
  # Copy the files into the new folder
  appDir_new <<- normalizePath(file.path(appDir, "..", "ACD_compact_large"))
  dir.create(appDir_new,showWarnings = F)
  print("log: Copying ACD_App files...")
  file.copy(appDir, appDir_new, overwrite = T, recursive = T,
            copy.mode = TRUE, copy.date = FALSE)
  dirsToCheck <- normalizePath(list.dirs(appDir_new, recursive = T))
  
  ##############################################################################
  #
  #                                 REMOVE FILES
  #
  ##############################################################################
  # Remove libraries
  print("log: Deleting libraries...")
  pathToDelete <- file.path(appDir_new, "ACD_standalone", "ACD_App", "www", 
                            "libraries")
  filesToDelete <- list.files(pathToDelete, full.names = TRUE)
  do.call(unlink, list(filesToDelete, recursive = T))
  
  # Remove packages from "win.binary" folder
  print("log: Deleting packages...")
  pathToDelete <- file.path(appDir_new, "ACD_standalone", "ACD_App", "www", 
                            "R_pkgs", "win.binary")
  pkgsToSave <- paste("defaults", sep = "|")
  dirs <- list.files(pathToDelete, full.names = T, recursive = F)
  filesToDelete <- dirs[grep(pkgsToSave, dirs, invert = T)]
  do.call(unlink, list(filesToDelete, recursive = T))
  
  # Remove documentation.html
  print("log: Deleting documentation files...")
  filesToDelete <- c(list.files(path = appDir_new, 
                                pattern = "documentation.html",
                                recursive = T),
                     list.files(path = appDir_new, 
                                pattern = "documentation_doc.docx",
                                recursive = T),
                     list.files(path = appDir_new, 
                                pattern = "documentation_pdf.pdf",
                                recursive = T))
  do.call(unlink, list(filesToDelete, recursive = T), T)
  
  # Remove all "tex" files
  print("log: Deleting LaTeX files...")
  filesToDelete <- list.files(path = appDir_new, 
                              pattern = "latex.",
                              recursive = T)
  do.call(unlink, list(filesToDelete, recursive = T))
  
  # Remove all ".Rhistory" files
  print("log: Deleting .Rhistory files...")
  filesToDelete <- list.files(path = appDir_new, 
                              pattern = ".Rhistory",
                              recursive = T)
  do.call(unlink, list(filesToDelete, recursive = T))
  
  # Remove "temp_files"
  print("log: Deleting temporary files...")
  pathToDelete <- file.path(appDir_new, "ACD_standalone", "ACD_App")
  dirs <- list.files(pathToDelete, full.names = T, recursive = F, all.files = T)
  filesToDelete <- dirs[grep("temp_|temp.html", dirs)]
  do.call(unlink, list(filesToDelete, recursive = T))
  
  ##############################################################################
  #
  #                           SETTING THE APP TO DEFAULT
  #
  ##############################################################################
  print("log: Setting the ACD-App to defaults...")
  pathToDelete <- file.path(appDir_new, "ACD_standalone")
  unlink(file.path(pathToDelete, "localSettings.rda"))
  unlink(file.path(pathToDelete, "ACD_App", "loginData.Rda"))
}