################################################################################
#' @export get_climsoft_data
#'
#' @title Get the data (and metadata) from the CLIMSOFT-db
#'
#' @description This function retrieves metadata and data from the CLIMSOFT
#' database to which the user is connected.
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
#' @details This function will be called by the functions
#' \code{\link[ACD]{climsoft_db_plots}} .
#'
################################################################################
#'

get_climsoft_data <- function(input, output){
  list1 <- list()
  ftp_data <- list()
  
  for (i1 in c(1:length(tablesInfo))){
    assign(names(tablesInfo[i1]),tablesInfo[[i1]])
  }
  tr <- input[[stationId]]
  db.type <- input[[dbType]]
  station_id_prev <<- unlist(
    lapply(1:length(tr), function(i) {strsplit(tr[i], " - ")[[1]][1]}))
  element_names <- input$elementName
  begin_date <- input$dates[1]
  end_date <- input$dates[2]
  
  # ftp_data <- vector("list", length(station_id_prev))
  
  for (j0 in 1:length(station_id_prev)){
    station_id <- station_id_prev[j0]
    for (i0 in 1:length(element_names)){
      ##########################################################################
      # METADATA
      # Get the element_code
      request <- paste0("SELECT ", obs_element.code, " AS code",
                        " FROM ", obs_element ,
                        " WHERE ", obs_element.element_name , " = '",
                        element_names[i0],"';")
      element_code <- getQuery(db.type, channel2, request)
      
      #Get metadata
      metadata <- climsoft_db_metadata(db.type, channel2, begin_date, end_date, 
                                       station_id, element_code)
      
      ##########################################################################
      # DATA
      # Check if a data exists for this station
      path.output <- file.path(".","tmp_from_get.plots")
      dir.create(path.output,showWarnings=FALSE)
      tmp.file <- paste(station_id,"_", begin_date, "_", end_date, "_",
                        gsub("/","_", tolower(element_names[i0])), sep="")
      
      if (file.exists(file.path(path.output,tmp.file))==T){
        data <- read.table(file.path(path.output,tmp.file),sep="\t",header = T)
        print("Data available in temporary directory")
        var_name <- as.character(metadata[[3]]$element_name)
        colnames(data)[4] <- var_name
        colnames(data)[3] <- "mess_datum"
        data
      }else{
        print("Data not available in temporary directory")
        data <- climsoft_db_data(db.type, channel2, metadata)
        var_name <- as.character(metadata[[3]]$element_name)
        print(var_name)
        print(colnames(data))
        colnames(data)[4] <- var_name
        colnames(data)[3] <- "mess_datum"
        write.table(data,file = file.path(path.output,tmp.file),sep="\t",
                    row.names = F)
        data
      }
      
      #########################################################################
      # CHECK THE EXISTENCE OF THE DATA
      if (nrow(data) == 0 || is.null(nrow(data))){
        #ftp_data[[j0]][[i0]] <- list(NULL)
        list1[[i0]] <- NULL
      }else{
        #######################################################################
        # SAVE METADATA, DATA & CHANGES
        #ftp_data[[j0]][[i0]] <- list(metadata=metadata,data=data,changes=NULL)
        list1[[i0]] <- list(metadata=metadata,data=data,changes=NULL)
      }
    }
    ftp_data[[j0]] <- list(station=tr[[j0]], ftp_data= list1)
  }
  return(ftp_data)
  
}

