################################################################################
#' @export get_rclim_graphics
#'
#' @title Creates RClimDex Graphics
#'
#' @description It creates the graphics of the RClimDex Indices
#' 
#' @param input shiny object. It is a list-like object.
#' It stores the current values of all of the widgets in the
#' application. The Shiny App uses the \code{input}
#' to receive user input from the client web browser.
#' 
#' @param output shiny object. It is a list-like object that stores
#' instructions for building the R objects in the Shiny application.
#' Shiny application.
#'
################################################################################
get_rclim_graphics <- function(input, output){
  shiny.station.id <<- strsplit(input$stationIdRClim," - ")[[1]][1]
  ###################################################################
  # converting data from ftp-server into data usable for RClimDex
  if (input$dbase=="CLIMSOFT"){
    RClim <- reactive({
      RClim <- RClimDex2()
      RClim
    })
  }else{
#     toClim <- reactive({
#       toClim <- FtpToClimDex2(station.id = shiny.station.id,
#                               date.begin = "1700-01-01",
#                               date.end   = Sys.Date())
#       toClim
#     })
#
#     ###################################################################
#     # RClimDex index calculation
#     RClim <- reactive({
#       toClim()
      RClim <- reactive({RClimDex2()})
      RClim
    # })
  }
  ###################################################################
  # Create plots from RClimDex
  RClim()
  wd <- getwd()
  setwd("~/") #set wd to direction where RClimDex data are saved

  RClimCompleted <<- "no"
  shiny.stop <<- F

  # Check if there are already "old" plots saved
  name.ind <-(dir(file.path(getwd(), FormatID(shiny.station.id), "plots")))
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
      # delete all already calculated values
      unlink(file.path(getwd(), FormatID(shiny.station.id),
                       c("indices", "plots", "log", "trend")), T)

    } else {
      answer2 <- tkmessageBox(
        message=paste("If you want to continue the index calculation ",
                      "click YES. Recalculated indices will overwirte the existing. ",
                      "\n","If you do not want to add new indices, click NO. ",
                      "Only the already existing plots will be shown. "),
        type = "yesno")
      if(tclvalue(answer2) == "no"){
        RClimCompleted <<- "ok"
      }
    }
  }

  # pause action as long as indices calculation not done
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
    output$uiRClimHeader <- renderUI({h3("Plots from RClimDex")})

    # Get the name of the files containing the Index values (".csv" files)
    name.ind <- dir(file.path(getwd(), FormatID(shiny.station.id), "indices"))

    # Get the name of the indices
    index.names <- ldply(strsplit(ldply(strsplit(name.ind,".csv"))$V1,"_"))$V2

    # total number of elements in the "indices" folder
    n2 <- length(name.ind)
    print(paste("new number of indices: ", n2))

    # Create dynamic number of  tabs (number of calculated indices)
    output$uiRClimPlots <- renderUI({
      Tabs <<- lapply(1:n2,function(i){
        tabname <- index.names[i]
        plotname <- paste0("tabs",tabname)
        tabPanel(tabname,dygraphOutput(plotname))
      })
      do.call(tabsetPanel,Tabs)
    })



    ########################################################################
    # Create/open plots of RClimDex
    for (i in 1:n2){
      local({
        my_i <- i

        index.name <- index.names[my_i]
        plotname <- paste0("tabs", index.name)
        print(index.name)

        # Check if the variable "nn" exists
        if (exists('nn')){
          print("hola")
        }else{
          id <- grep("mm", index.names)
          prcp.name <- index.names[id]
          id2 <- which((prcp.name != "R10mm") & (prcp.name != "R20mm"))
          nn.prev <- substr(prcp.name[id2],1,nchar(prcp.name[id2])-2)
          nn <- substr(nn.prev, 2, nchar(nn.prev))
        }

        # long index name as title
        if (index.name=="CDD") main<-"Consecutive dry days (CDD)"
        else if (index.name=="CSDI") main<-"Cold Spell Duration Indicator (CSDI)"
        else if (index.name=="CWD") main<-"Consecutive wet days (CWD)"
        else if (index.name=="DTR") main<-"Diurnal temperature range (DTR)"
        else if (index.name=="GSL") main<-"Growing season length (GSL)"
        else if (index.name=="ID0") main<-"Ice days (ID0)"
        else if (index.name=="PRCPTOT") main<-"Annual total wet-day precipitation (PRCPTOT)"
        else if (index.name=="R10mm") main<-"Heavy precipitation days (R10mm)"
        else if (index.name=="R20mm") main<-"Very heavy precipitation days (R20mm)"
        else if (index.name=="R95p") main<-"Very wet days (R95p)"
        else if (index.name=="R99p") main<-"Extremly wet days (R99p)"
        else if (index.name=="RX1day") main<-"Max 1-day precipitation (RX1day)"
        else if (index.name=="RX5day") main<-"Max 5-day precipitation (RX5day)"
        else if (index.name=="SDII") main<-"Simple daily intensity (SDII)"
        else if (index.name=="SU25") main<-"Summer days (SU25)"
        else if (index.name=="TNn") main<-"Min Tmin (TNn)"
        else if (index.name=="TNx") main<-"Max Tmin (TNx)"
        else if (index.name=="TXx") main<-"Max Tmax (TXx)"
        else if (index.name=="TXn") main<-"Min Tmax (TXn)"
        else if (index.name=="WSDI") main<-"Warm Spell Duration Indicator (WSDI)"
        else if (index.name=="TR20") main<-"Tropical nights (TR20)"
        else if (index.name=="FD0") main<-"Frost days (FD0)"
        else if (index.name=="TX10P") main<-"Cool days (TX10p)"
        else if (index.name=="TX90P") main<-"Warm days (TX90p)"
        else if (index.name=="TN10P") main<-"Cool nights (TN10p)"
        else if (index.name=="TN90P") main<-"Warm nights (TN90p)"
        else if (index.name=="TMAXmean") main<-"Annual Mean Maximum Temperatures"
        else if (index.name=="TMINmean") main<-"Annual Mean Minimum Temperatures"
        else if (index.name== paste0("R",as.character(nn),"mm")){
          main<-paste0("Days above ",as.character(nn),"mm (R",as.character(nn),"mm)")}
        else main <- index.name

        print(main)
        # load tables with indices
        setwd(paste("~/",FormatID(shiny.station.id),"/indices", sep=""))
        indices.table <- read.csv(file = file.path("~",
                                                   FormatID(shiny.station.id),
                                                   "indices",
                                                   name.ind[my_i]), header=T)
        Year <- indices.table[,1]
        ind <- indices.table[,ncol(indices.table)]
        ind[which(ind==-99.9)] <- NA

        # Convert into date frame
        Year2 <- (as.Date(paste0(as.character(as.matrix(Year)),"-01","-01")))
        data.table <- data.frame(Year2,ind)

        # Convert to zoo object (for timeseries)
        z5 <- with(data.table,zoo(data.table[,2], order.by=(data.table$Year2)))

        # Create Dygraphs
        output[[plotname]] <- renderDygraph({
          k <<- dygraph(z5[,1], xlab="Year", ylab = index.name,
                        main = paste(main, FormatID(shiny.station.id),
                                     sep = "  ")) %>%
            dyRangeSelector()
          k
        }) # renderDygraph
      }) # local
    } # for (number of plots)
  } # RclimCompleted

  setwd(wd)
  return(output)

} # end of function
