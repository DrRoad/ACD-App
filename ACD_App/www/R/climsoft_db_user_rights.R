##########################################################################
#' @export climsoft_db_user_rights
#'
#' @title Interactive setup of user rights
#'
#' @description Allows the setup of user rights within the 'ACD-App'
#' interface.
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
#' \code{\link[ACD]{climsoft.db.access}} and
#' \code{\link[ACD]{climsoft.db.mariadb}}.
#'
################################################################################

climsoft_db_user_rights <- function(input, output, session){
  ##############################################################################
  #
  #                         SIDE PANEL
  #
  ##############################################################################
  uid <- substr(UUIDgenerate(), 1, 4)
  userRightsCheck <- paste0("userRightsCheck_", uid)
  output[[uiUserRightsCheck]] <- renderUI({
    conditionalPanel(condition = connectCondition,
                     h3(checkboxInput(userRightsCheck, (textUserRights00), F)),
                     h5(helpText(textUserRights01))
    )
  })

  ##############################################################################
  #
  #                         MAIN PANEL
  #
  ##############################################################################
  # Create new uiOutputs for mainPanel if check Box is TRUE
  observe({
    if (!is.null(input[[userRightsCheck]]) && (input[[userRightsCheck]] == T)){
      print("log: User-Rights option selected")
      output[[uiUserRights]] <- renderUI({
        uiOutputs <- list(uiOutput("uiUserRightsHeader"),
                          rHandsontableOutput("hot"),
                          uiOutput("userRightsBreak1"),
                          actionButton("userRightsSaveData", textUserRights02),
                          uiOutput("userRightsBreak2"))
        do.call(tagList,uiOutputs)
      })

      # Header
      output$uiUserRightsHeader <- renderUI({h3(textUserRights03)})

      # Space between table and button
      output$userRightsBreak1 <- renderUI({HTML("<br/>")})


      aa <- load("loginData.Rda")
      df.users <- get(aa)

      values = reactiveValues()

      data = reactive({
        if (!is.null(input$hot)) {
          DF = hot_to_r(input$hot)
        } else {
          if (is.null(values[["DF"]]))
            DF = df.users
          else
            DF = values[["DF"]]
        }
        values[["DF"]] = DF
        DF
      })

      output$hot <- renderRHandsontable({
        colnames.data <- colnames(data())
        data.new <<- data()
        colnames(data.new) <- textUserRights04
        DF = data.new
        if (!is.null(DF))
          rhandsontable(DF, stretchH = "all")
      })

      observeEvent(input$userRightsSaveData,{
        colnames.original <- c("users", "pswd", "Map", "Table", "Plots",
        "Report", "Overview", "RClimDex", "UserRights", "Export")
        df.users2 <<- data.new
        colnames(df.users2) <- colnames.original
        save(df.users2, file = "loginData.Rda")
      })
      output$userRightsBreak2 <- renderUI({HTML("<br/>")})
    }else{
      # If Table Check box is not selected
      output[[uiUserRights]] <- renderUI({})
    }
  })
  return(output)
}
