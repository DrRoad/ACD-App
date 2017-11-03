################################################################################
#' @export openConnection
#' 
#' @title Check if an ODBC connection is open
#' 
#' @description The function checks whether the connection \code{conn} is still
#' open or not
#' 
#' @param conn ODBC connection. 
#' 
################################################################################
odbcOpenp <- function(conn)
  tryCatch({odbcGetInfo(conn);TRUE},error=function(...)FALSE)
openConn <- function(conn)
  if (class(conn)[1] == 'RODBC' | class(conn)[1] == 'numeric'){
  tryCatch({odbcGetInfo(conn);TRUE},error=function(...)FALSE)
  }else if(class(conn)[1] == 'MySQLConnection'){
    tryCatch({dbGetInfo(conn);TRUE},error=function(...)FALSE)
  }
