################################################################################
#' @export climsoft_db_connect
#'
#' @title Connect to Database
#'
#' @description Connects to a CLIMSOFT database, either a MS-Access database
#' or a Mariadb database. The connection is done currently through
#'  RODBC (22.11.2016). The funtion is run when the \code{actionButton}
#'  'OK' of the 'Log in' pannel is pressed (input id: \code{LoginNew},
#'  defined in \code{\link{climsoft_db_access}} or
#'  \code{\link{climsoft_db_mariadb}}).
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
#' @param session shiny object. It is a special object that is used for finer
#' control over a user's app session.
#'
#' @details This function will be called by the functions
#' \code{\link[ACD]{climsoft_db_access}} and
#' \code{\link[ACD]{climsoft_db_mariadb}}.
#'
################################################################################

climsoft_db_connect <- function(input, output, session){
  uid <<- substr(UUIDgenerate(FALSE),1, 4)
  connectCondition <<- paste0("output.", connectMessageId, " == '",
                              textConnectMessage01, "'")
  mapMarkerClick <<- NULL
  channel2 <<- -1
  
  channel2 <<- odbcConnect(input$dns)
  
  if (channel2 == -1){
    print(textODBCMessage)
    output[[connectMessageId]] <- renderText({textODBCMessage})
  }else{
    if (openConn(channel2) == FALSE){
      connection <<-  FALSE
      output[[connectMessageId]] <- renderText({textConnectMessage02})
    }else{
      connection <<- TRUE
      output[[connectMessageId]] <- renderText({textConnectMessage01})
    }
    outputOptions(output, connectMessageId, suspendWhenHidden = FALSE)
  }
  return(output)
}
