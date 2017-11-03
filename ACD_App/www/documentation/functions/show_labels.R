is.odd <- function(x) x %% 2 != 0 

show_labels <- function(){
  library(shiny)
  shinyApp(
    ui = fluidPage(
      sidebarLayout(fluid = FALSE,
        sidebarPanel(style = "position: fixed; overflow: visible;",
          fluidRow(uiOutput('Button'))
        ),
        mainPanel(
          fluidRow(uiOutput('Table'))
        )
      )
    ),
    
    server = function(input, output) {
      
      # store the counter outside your input/button
      vars = reactiveValues(counter = 1)
      output$Table <- renderUI({})
      
      output$Button <- renderUI({
        actionButton("click", label = label())
      })
      
      # increase the counter
      observeEvent(input$click, {
        isolate({
          vars$counter <- vars$counter + 1
        })
        # }
      })
      
      
      label <- reactive({
        if(!is.null(input$click)){
          if(!is.odd(vars$counter)){
            label <- "Hide Table"
          }else{
            label <- "View Table"
          }
        }
      })
      
      observeEvent(input$click,{
        env <- environment(climssc::add_defaults)
        env.vars <- ls(envir = env)
        id <- grep("_label$", env.vars)
        values <- sapply(1:length(id), function(i){
          get(env.vars[grep("_label$", env.vars)[i]])
        })
        
        observe({
          if(!is.odd(vars$counter)){
            output$Table <- renderUI({tableOutput("tbl")})
            df <- data.frame("element label" = gsub("_label", "", env.vars[id]), "default header" = values)
            output$tbl <- renderTable(height = 400, {df})
          }else{
            output$Table <- renderUI({})
          }
        })
      })
    }, options = list(height = 250)
  )
}
