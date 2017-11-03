################################################################################
#' @export climsoft_db_data
#' 
#' @title Get data from Climsoft
#' 
#' @description This function retrieves the data from the CLIMSOFT database.
#' 
#' @param db.type string. Type of database to which the user is connected.
#' There are two options available: "access" or "mariadb"
#' 
#' @param channel2 ODBC connection. Object containing the ODBC to the database
#' 
#' @param metadata list. A list with the metadata of the data of interest. This 
#' list is retrieved from \code{\link[ACD]{climsoft_db_metadata}}

################################################################################

climsoft_db_data <- function(db.type, channel2, metadata){
  Sys.setenv(TZ = 'UTC')

  ##############################################################################
  # EXTRACT DATA
  # metadata
  for (i1 in c(1:length(metadata[[1]]))){
    assign(metadata[[1]][i1],metadata[[i1+1]])
  }

  ##############################################################################
  # get the table names ("tablesInfo" in .GlobalEnvironment)
  for (i1 in c(1:length(tablesInfo))){
    assign(names(tablesInfo[i1]),tablesInfo[[i1]])
  }

  ##############################################################################
  # REQUEST TO GET THE DATA
  request <- paste0("SELECT ",
                    observation.recorded_from, " AS station_id, ",
                    observation.described_by, " AS element_id, ",
                    observation.recorded_at, " AS record_date, ",
                    observation.obs_value, " AS obs_value ",
                    "FROM ", observation,
                    " WHERE ", observation.recorded_from, " = '",metadata[[4]],
                    "' AND ", observation.described_by, " IN (",
                    paste(element_info$code, collapse =","),
                    ");", sep = "")

  result <- getQuery(db.type, channel2, request)
  data <- result[order(as.Date(result$record_date,format="%Y-%m-%d")),]

  if (nrow(data) == 0){
    print("No data available")
  }else{
    ############################################################################
    # GET DATA FOR SPECIFIC DATE INTERVAL

    record_date <- as.Date(data$record_date)

    id4 <- which(record_date>=date_begin &
                   record_date<=date_end)

    if (length(id4) == 0){
      print("No data available for the date range given")
      id4 <- 1:length(record_date)
      print(paste("Default dates selected:",
                  record_date[1], "and", record_date[length(record_date)]))
    }
    data <- data[id4,]
    data$obs_value <- as.numeric(data$obs_value)
    testing <<- data
    # Get the right "obs_vale"
    # If the database is a "main_database", then the values stored in the
    # attribute "obs_value" of the "observation" table are the right ones. BUT, 
    # if the database is the "intermediate", then the values stored in such an
    # attribute are not correct (they are usually stored without decimals)
    if(tolower(db.type)=="access"){
      db_path <- strsplit(
        strsplit(attr(channel2,"connection.string"),";")[[1]][2],
        "\\\\")[[1]]
      db_name <- db_path[length(db_path)]
      if (length(grep("main_climsoft",db_name))>0){
      }else{
        data$obs_value <- data$obs_value*metadata[[3]]$element_scale
      }
    }
    if(tolower(db.type)=="mariadb"){
      data$obs_value <- data$obs_value*metadata[[3]]$element_scale
    }


    # Replace -99 with NA
    data$obs_value[signif(data$obs_value)==-99] <- NA
  }
  ##############################################################################
  # OUTPUT
  return(data)
}
