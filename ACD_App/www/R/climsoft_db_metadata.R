################################################################################
#' @export climsoft_db_metadata
#' 
#' @title Get metadata from Climsoft
#' 
#' @description This function retrieves the metadata from the CLIMSOFT database.
#' 
#' @param db.type string. Type of database to which the user is connected.
#' There are two options available: "access" or "mariadb"
#' 
#' @param channel2 ODBC connection. Object containing the ODBC to the database
#' 
#' @param date_begin string. Begin date of the measurements
#' 
#' @param date_end string. End date of the measurements
#' 
#' @param station_id string. Station id of interest
#' 
#' @param element_code numeric. Element code of interest. For instance, the 
#' element_code of daily precipitation is 5
#' 
################################################################################

climsoft_db_metadata <- function(db.type, channel2, date_begin, date_end, 
                                 station_id, element_code){
  ##############################################################################
  # get the table names ("tablesInfo" in .GlobalEnvironment)
  for (i1 in c(1:length(tablesInfo))){
    assign(names(tablesInfo[i1]),tablesInfo[[i1]])
  }

  ##############################################################################
  # LIST OF ATTRIBUTES TO BE SAVED IN THE OUTPUT
  attributes <- list(c("channel2","element_info","station_id","date_begin",
                       "date_end"))
  element_codes <- paste(as.matrix(element_code), collapse = " OR ")

  ##############################################################################
  # Element info
  request <- paste0("SELECT ",
                    obs_element.code, " AS code, ",
                    obs_element.abbreviation, " AS abbreviation, ",
                    obs_element.element_name, " AS element_name, ",
                    obs_element.description, " AS description, ",
                    obs_element.element_scale, " AS element_scale, ",
                    obs_element.upper_limit, " AS upper_limit, ",
                    obs_element.lower_limit, " AS lower_limit, ",
                    obs_element.units, " AS units, ",
                    obs_element.element_type, " AS element_type, ",
                    obs_element.total, " AS total ",
                    "FROM ", obs_element, " WHERE ",
                    obs_element.code, " IN (",
                    paste(as.matrix(element_code), collapse = ","),");",sep="")
  element_info <- getQuery(db.type, channel2, request)

  ##############################################################################
  # OUTPUT
  # Create the variable "metadata"
  metadata <- vector()
  metadata <- c(metadata, attributes)
  # Save all the attributes in the metadata variable
  for (i4 in attributes[[1]]){
    metadata <- c(metadata, list(get(i4)))
  }
  return(metadata)
}
