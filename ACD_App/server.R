
shinyServer(function(input,output,session){
  
  ##############################################################################
  #
  #                           SOURCE R-SCRIPTS
  #
  ##############################################################################
  # Source the R-Scripts placed in the App
  dirR <- file.path(".", "www", "R")
  pathnames <- list.files(pattern="[.]R$", path=dirR, full.names=TRUE)
  sapply(pathnames, FUN=source)
  
  ##############################################################################
  observe({
    # Create Progress bar ("Loading")
    withProgress(message = "Loading...", value = 0, {
      
      # Remove unused variables
      rm(list= ls(all=TRUE)[!(ls() %in% c('input','output', 'session'))])
      
      ##########################################################################
      # A) CLIMSOFT
      observe({
        if (input$dbase=="CLIMSOFT"){
          output <- climsoft_db(input, output, session)
        }
      })
      
      ##########################################################################
      # C) Local file
      observe({
        if (input$dbase=="LOCAL_FILE"){
          options(shiny.maxRequestSize=30*1024^2)
          output <- local_db(input, output, session)
        }
      })
      
      ##########################################################################
      # Remove temporary files when session ends
      session$onSessionEnded(function(){
        #setwd("~/")
        path.output <- file.path(".","tmp_from_get.plots")
        if (file.exists(path.output)){
          unlink(path.output, recursive = T)
          print(paste("log: ", path.output, "directory removed."))
        }
        print("log: ACD-App closed")
      })
    })
  })
})
