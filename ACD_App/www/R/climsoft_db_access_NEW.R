################################################################################
#' @export climsoft_db_access
#'
#' @title Connect to a MS-Access database and create options
#'
#' @description It connects to a selected MS-Access database and displays the
#' options available for this type of database (e.g. 'Create Map',
#' 'Create Table', etc.)
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
#' @details This function will be called by the function
#' \code{\link[ACD]{climsoft_db}}.
#'
################################################################################

climsoft_db_access_NEW <- function(input, output, session){
  ##############################################################################
  uid <- substr(UUIDgenerate(FALSE),1, 4)
  popupLogin <- paste0("popupLogin_", uid)
  connectButtonId <<- paste0("connect_", uid)
  disconnectButtonId <<- paste0("disconnect_", uid)
  connectMessageId <<- paste0("connectMessage_", uid)
  loginNew <<- paste0("loginNew_", uid)
  loginPanel <<- paste0("loginPanel_", uid)
  username <<- paste0("username_", uid)
  passwd <<- paste0("passwd_", uid)
  
  ##############################################################################
  # DNS
  list_ODBC <- odbcDataSources(type = c("user"))
  drivers_prev <<- as.character(list_ODBC)
  dns_prev <- row.names(as.data.frame(list_ODBC))
  dns_id <- (grep("climsoft", tolower(dns_prev)))
  dns <<- dns_prev[dns_id]
  drivers <<- drivers_prev[dns_id]
  output[[uiDns]] <- renderUI({
    selectInput("dns", label = (textSidePanel03), choices = dns)
  })
  
  ##############################################################################
  # Action Buttons
  output[[uiConnect]] <- renderUI({
    uid <- substr(UUIDgenerate(), 1, 4)
    
    bootstrapPage(
      div(style="display:inline-block", 
          actionButton(connectButtonId, label = h5(textConnectButton))),
      div(style="display:inline-block", 
          actionButton(disconnectButtonId, label = h5(textDisconnectButton))),
      div(style="display:inline-block", uiOutput(connectMessageId)),
      
      bsModal(popupLogin, "Log in", trigger = connectButtonId,
              size = "small",
              tabPanel(loginPanel, br(),
                       tags$form(
                         textInput(username, label = textLoginUser),
                         passwordInput(passwd,label = textLoginPassword),
                         actionButton(loginNew, label = h5("OK"))
                       )
                       
              )
      )
    )
  })
  
  observeEvent(input[[loginNew]],{
    output <- climsoft_db_disconnect(input, output, session)
    toggleModal(session, modalId = popupLogin, toggle = "close")
    user <<- input[[username]]
    pswd <<- input[[passwd]]
    
    ############################################################################
    # Create uiOutputs to be placed in the mainPanel
    output <- climsoft_db_connect(input, output, session)
    
    observe({
      if ((exists("channel2")) && (!is.null(channel2)) && (channel2 != -1) &&
          openConn(channel2)){
        uid2 <- substr(UUIDgenerate(), 1, 4)
        # mainPanel - uiOutputs
        print("log: Connected to MS-Access db")
        uiMap <<- paste0("uiMap_", uid2)
        uiTable <<- paste0("uiTable_", uid2)
        uiPlots <<- paste0("uiPlots_", uid2)
        uiMessages <<- paste0("uiMessages_", uid)
        uiRclim <<- paste0("uiRclim_", uid2)
        uiView <<- paste0("uiView_", uid2)
        uiReport <<- paste0("uiReport_", uid2)
        uiUserRights <<- paste0("uiUserRights_", uid2)
        uiExport <<- paste("uiExport_", uid2)
        
        output$UIsMainPanel <- renderUI({
          uiOutputs <- list(
            uiOutput(uiMap),
            uiOutput(uiTable),
            uiOutput(uiPlots),
            uiOutput(uiMessages),
            uiOutput(uiReport),
            uiOutput(uiView),
            uiOutput(uiRclim),
            uiOutput(uiUserRights),
            uiOutput(uiExport)
          )
          do.call(tagList, uiOutputs)
        })
        ########################################################################
        # Create products
        df.users <- climsoft_db_users()
        observe({
          id0 <- which(df.users$users == user & df.users$pswd == pswd)
          if(length(id0)!=0){
            if (df.users$Map[id0] == T){
              output <- climsoft_db_map(input, output, session)
            }
            if (df.users$Table[id0] == T){
              output <- climsoft_db_table(input, output, session)
            }
            if (df.users$Plots[id0] == T){
              output <- climsoft_db_plots_NEW2(input, output, session)
            }
            if (df.users$Report[id0] == T){
              output <- climsoft_db_report(input, output, session)
            }
            if (df.users$Overview[id0] == T){
              output <- climsoft_db_overview(input, output, session)
            }
            if (df.users$UserRights[id0] == T){
              output <- climsoft_db_user_rights(input, output, session)
            }
            
            if (df.users$Export[id0] == T){
              download_right <<- T
              output <- climsoft_db_export(input, output, session)
            }else{
              download_right <<- F
            }
          }else{
            output <- climsoft_db_disconnect(input, output, session)
            output[[connectMessageId]] <- renderText({textWrongLogin})
          }
        })
      }else{
        output <- climsoft_db_disconnect(input, output, session)
      }
      
    })
  })
  
  ##############################################################################
  # Disconnect
  observeEvent(input[[disconnectButtonId]],{
    odbcCloseAll()
    channel2 <<- -1
    output <- climsoft_db_disconnect(input, output, session)
    output[[connectMessageId]] <- renderText({textDisconnectMessage})
  })
}
