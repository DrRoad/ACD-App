##########################################################################
#' @export get_climObj
#'
#' @title Get a climate Object (climObj)
#'
#' @description It creates a climate object based on a given \code{data.frame}
#' and a given metadata information.
#'
#' @param metadata list. Contains metadata information of a station
#' selected, as well as information of the elements selected. This input
#' can be retrieved from two different sources:
#' \code{\link{climsoft_db_metadata}} if 'CLIMSOFT' is selected or
#' \code{\link[get.plots.from.ftp]{get.metadata}} if 'DWD-ftp' is selected.
#' @param data dataframe. Data retrieved either from
#' \code{\link{climsoft_db_data}} or \code{\link[get.plots.from.ftp]{get.data}}
#' @param changes character. Only of interest if 'DWD-ftp' is selected.
#'
#' @details This method will work
#' if the DNS of the ODBC connection includes the word "CLIMSOFT". 
#' This function will be called by the function. \code{\link[ACD]{server.R}}.
#'
################################################################################

get_climObj <- function(metadata,data,changes){
  
  # Check whether the database is from climsoft or not
  # id0 <- gregexpr("access",tolower(odbcGetInfo(metadata[[2]])[1]))
  if (is.null(metadata[[2]])){
    id0 <- 0
  }else{
    id0 <- gregexpr("climsoft",
                    tolower(odbcGetInfo(metadata[[2]])[["Data_Source_Name"]]))
  }
  if (id0 >0){
    # For Climsoft dataset
    var_name <- as.character(metadata[[3]]$element_name)
    var_data <- data
    var_data$mess_datum <- with(data,get("mess_datum"))
    var_data$station_id <- metadata[[4]]
  }else{
    # For DWD-ftp dataset
    var_name <- as.character(metadata[[3]]$element_name)
    id <- which(colnames(data)==var_name)
    var_data <- data[,c(1,2,id)]
    var_data[var_data=="-999"] <- NA
    var_data$station_id <- metadata[[5]]
  }
  
  # Create zooObject
  z5 <- function_to_run(metadata,var_data,changes)
  
  # Give colnames to the zooObject "z5"
  if (is.null(ncol(z5))){
    col_names <- "Total"
  }else{
    col_names <- as.character(as.matrix(colnames(z5)))
  }
  
  # Create a list of data.frames that will be stored in the ClimObject.
  # There will be one data.frame for each column of "z5"
  data_list <- list()
  dateformat_list <- list()
  datetimeperiod_list <- list()
  for (i in 1:length(col_names)){
    data_list[[i]] <- data.frame(mess_datum=index(z5),z5[,i],
                                 station_id=var_data$station_id[1])
    # Change the name of the column
    names(data_list)[[i]] <- col_names[i]
    # Change the name of the second column
    names(data_list[[i]])[2] <- var_name
    
    # Get date format
    #tra <- check_dateformat(data_list[[i]])
    tra <- check_dataframe(data_list[[i]])
    dateformat_list[[i]] <- tra$dateformat
    datetimeperiod_list[[i]] <- tra$datetimeperiod
  }
  # Create Climate Object
  climObj <- climate(data_tables = data_list,
                     date_formats = dateformat_list,
                     data_time_period = datetimeperiod_list)
  return(climObj)
}
