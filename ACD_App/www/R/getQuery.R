################################################################################
#' @export getQuery
#'
#' @title Get a request
#'
#' @description Allows getting a request to either a MS-Access database
#' or a mariadb database. Currently based on the function
#' \code{\link[RODBC]{sqlQuery}}, but for mariadb it should be replaced
#' by the function \code{\link[RMySQL]{dbSendQuery}}
#'
#' @param db.type character. Type of database selected. Two options are
#' available: \code{access} or \code{mariadb} with no default.
#'
#' @param channel ODBC connection. Object containing the ODBC to the database
#' 
#' @param request string. SQL request to make to the database
#' 
#' @note It requires the packages 'RMySQL' and 'RODBC'.
#'
################################################################################

getQuery <- function(db.type, channel, request){
  library(RMySQL)
  library(RODBC)
  
  if (db.type == 'access'){
    # Set up a new function to be used as dygraphOutput
    result <- sqlQuery(channel, request)
    return(result)
  }else if (db.type == 'mariadb'){
    result <- sqlQuery(channel, request)
    return(result)
  }else{
    print("Not database type recognized")
  }
}
