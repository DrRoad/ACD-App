get_ftp_data <- function(station_id, element_names, time_resol, begin_date, end_date, graphic_type, change, output){
  
  ftp_data <- list()
  
  for (i0 in 1:length(element_names)){
    #########################################################################
    # METADATA
    metadata <- get.plots.from.ftp::get.metadata(element.name = element_names[i0],
                                                 time.resol = time_resol,
                                                 station.id = station_id,
                                                 date.begin = begin_date,
                                                 date.end = end_date,
                                                 graphic.type = tolower(graphic_type))
    
    #
    #       input <- list()
    #            input$element_name <- "Windrichtung"
    #            input$station_id <- "00044"
    #            input$dates[1] <- "1900-01-01"
    #            input$dates[2] <- "2015-01-01"
    #            input$changes <- "none"
    #            input$time_resol <- "hourly"
    #            input$graphic <- "windrose"
    #
    #
    #   t1<- input$time_resol
    #   t2<-input$station_id
    #   t3<- input$dates
    #   t4 = input$graphic
    #
    #   print(paste(t1,t2,t3,t4, sep= " : "))
    
    
    # Check if a data exists for this station
    path.output <- get.plots.from.ftp::get.temp.path()
    tmp.file <- get_tmp_file_name(station_id, begin_date, end_date, element_names[i0], time_resol)
    
    if (file.exists(file.path(path.output,tmp.file))==T){
      #ignore error if file is empty
      data <- try(read.table(file.path(path.output,tmp.file), header = T), silent = T)
      print("Data available in temporary directory")
      data
    }else{
      print("Data not available in temporary directory")
      data <- get.plots.from.ftp::get.data(metadata)
      write.table(data,file = file.path(path.output,tmp.file), row.names = F)
    }
    
    #########################################################################
    # CHECK THE EXISTENCE OF THE DATA
    if (nrow(data)== 1 || is.null(nrow(data))){
      ftp_data[[i0]] <- NULL
    }else{
      #######################################################################
      # CHANGES
      changes <- get.plots.from.ftp::get.changes(metadata,
                                                 data,
                                                 changes.in=change)
      
      ###################################################################
      # SAVE METADATA, DATA & CHANGES
      ftp_data[[i0]] <- list(metadata=metadata,data=data,changes=changes)
    }
  } # for (i0 in 1:length(element_names))
  
  return(ftp_data)
  
}
