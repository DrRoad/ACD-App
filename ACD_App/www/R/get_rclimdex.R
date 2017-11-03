#############################################################################
# SHINY-INTERFACE THROUGH R TO CONNECT TO RCLIMDEX
#' @title Open the RClimDex interface
#' @name get_rclimdex
#' @description This function opens the RClimDex Interface. It is possible
#' to calculate up to 29 climate indices in RClimDex. The inputs out of the
#' shiny interface are used.
#' @details RClimDex needs a .txt file with the following columns:
#' Year, Month, Day, Prcp, Tmax, Tmin. This file can be created with the
#' FtpToClimDex2 function.

get_rclimdex <- function(input,output){
  ###################################################################
  # converting data from ftp-server into data usable for RClimDex
  toClim <- reactive({
    toClim <- FtpToClimDex2(station.id = input$station_id,
                            date.begin = "1700-01-01",
                            date.end   = Sys.Date())
    toClim
  })

  ###################################################################
  # RClimDex index calculation
  RClim <- reactive({
    toClim()
    RClim <- RClimDex2()
    RClim
  })

  ###################################################################
  # Create plots from RClimDex
  RClim()
  wd <- getwd()
  setwd("~/") #set wd to direction where RClimDex data are saved

  RClimCompleted <<- "no"
  shiny.stop <<- F

  # Check if there are already "old" plots saved
  name.ind <-(dir(file.path(getwd(), FormatID(input$station_id), "plots")))
  n2 <- length(name.ind)
  print(paste("Already existing plots: ", n2))
  if (n2 != 0){
    answer<- tkmessageBox(message = paste("There are already ", n2," plots of",
                                          " indices for this station.",
                                          " All existing plots will ",
                                          "be shown.", "\n", "Do you want ",
                                          "to delete the old ones? ", sep=""),
                          type = "yesno")
    if (tclvalue(answer) == "yes"){
      unlink(file.path(getwd(), FormatID(input$station_id), "plots"), T)
    } else {
      answer2 <- tkmessageBox(
        message=paste("If you want to continue the index calculation ",
                      "click YES. Recalculated indices will overwirte the existing. ",
                      "\n","If you do not want to add new indices, click NO. ",
                      "Only the already existing plots will be shown. "),
        type = "yesno")
      if(tclvalue(answer2) == "no"){
        RClimCompleted <- "ok"
      }

    }
  }

  # pause action as long as indices calculation not done
  # vorher hier rclimcompleted and shiny.stop

  while (as.character(RClimCompleted) != "ok"){
    Sys.sleep(3)
    print("Wait")
    if (shiny.stop == T){
      break
    }
  }


  #######################################################################
  if (as.character(RClimCompleted)=="ok"){
    # close RClimDex Window
    if (class(RClim())=="tkwin"){
      tkdestroy(RClim())
    }
    # title for plots
    output$plotsRClim <- renderUI({h3("Plots from RClimDex")})
    # get names of graphics
    name.ind <-(dir(file.path(getwd(), FormatID(input$station_id), "plots")))
    n2 <- length(name.ind) # number of elements in the folder plots
    print(paste("new number of plots: ", n2))

    # Create dynamic number of  tabs (number of calculated indices)
    output$image <- renderUI({
      Tabs <- lapply(1:n2,function(i){
        tabname <- substr(name.ind[i], 7, nchar(name.ind[i])-4)
        plotname <- paste0("tabs",tabname)
        tabPanel(tabname,imageOutput(plotname))
      })
      do.call(tabsetPanel,Tabs)
    })

    #######################################################################
    # Create/open plots of RClimDex
    for (i in 1:n2){
      local({
        my_i <- i
        plotname <- paste0("tabs", substr(name.ind[my_i], 7,
                                          nchar(name.ind[my_i])-4))
        output[[plotname]] <- renderImage({

          outfile <- normalizePath(file.path(getwd(), FormatID(input$station_id),
                                             "plots", name.ind[my_i]))

          list(src = outfile,
               contentType = 'image/png',
               width = 700,
               height = 500,
               alt = "Not available at the moment.")

        },deleteFile = FALSE) # renderImage
      }) # local
    } # for (number of plots)
  } # RclimCompleted

  return(output)
}
