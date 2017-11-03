################################################################################
#' @export climsoft_db_disconnect
#'
#' @title Clear-Up the ACD-App
#'
#' @description Function used to clear up the mainPanel of the ACD-App, as
#' well as the variables stored in the .Globalenvironment (besides
#' \code{input}, \code{output}, \code{session}). The function is run when the
#' \code{actionButton} 'Disconnect' is pressed.
#'
#' @param input shiny object. It is a list-like object.
#' It stores the current values of all of the widgets in the
#' application. The Shiny App uses the \code{input}
#' to receive user input from the client web browser.
#' @param output shiny object. It is a list-like object that stores
#' instructions for building the R objects in the Shiny application.
#' Shiny application.
#' @param session shiny object. It is a special object that is used for finer
#' control over a user's app session.
#'
#' @details This function will be called by the function
#' \code{\link[ACD]{climsoft_db}}.
#'
################################################################################

climsoft_db_disconnect <- function(input, output, session){
  # Remove all variables beside "input", "output", and "session"
  ls()[!(ls() %in% c('input','output', 'session'))]
  output$UIsMainPanel <- renderUI({})
  output[[uiMapCheck]] <- renderUI({})
  output[[uiTableCheck]] <- renderUI({})
  output[[uiPlotsCheck]] <- renderUI({})
  output[[uiReportCheck]] <- renderUI({})
  output[[uiViewCheck]] <- renderUI({})
  output[[uiRclimCheck]] <- renderUI({})
  output[[uiUserRightsCheck]] <- renderUI({})
  output[[uiExportCheck]] <- renderUI({})
  
  # Remove temporary directory
  if (dir.exists("tmp_from_get.plots")){
    unlink("tmp_from_get.plots",recursive = T)
  }
  return(output)
}
