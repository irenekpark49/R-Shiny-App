library(shiny)
library(shinyjs)
library(shinythemes)
library(DT)

ui <- fluidPage(
  theme = shinythemes::shinytheme("cerulean"),
  
  #Title Panel 
  titlePanel("Irene Hsueh's R Shiny App"),
  
  sidebarLayout(
    #Sidebar Panel - Inputs
    sidebarPanel(
      fileInput(inputId = "file", 
                label = "Upload diamonds.txt data here", 
                accept = c(".tsv")
      ),
      sliderInput(inputId = "slider",
                  label = "Choose how many diamonds to subset:",
                  min=0, max=53940, value=53940, step=25, ticks=FALSE
      ),
      actionButton(inputId = "reset", label = "Reset")
    ),
    
    #Main Panel - Outputs
    mainPanel(
      plotOutput(outputId = "histogram"),
      DT::dataTableOutput(outputId = "data_table")
    )
  )
)

server <- function(input, output, session) {
  tableData <- reactive({
    uploaded_data <- input$file
    
    if (is.null(uploaded_data))
      return(NULL)
    
    data_table <- read.table(uploaded_data$datapath, sep = "\t", header=TRUE)
    return(data_table)
  })
  
  subset_data <- reactive({
    tableData()[1:input$slider,]
  })
  
  output$histogram <- renderPlot({
    if (is.null(tableData()))
      return(NULL)
    x = subset_data()$carat
    return(hist(x, 
                col="hotpink", 
                border="black", 
                main="Histogram of Diamond Carat"))
  })
  
  output$data_table <- DT::renderDataTable({
    if (is.null(tableData()))
      return(NULL)
    return(subset_data())
  })
  
  observeEvent(input$reset, {
    shinyjs::reset("slider")
    updateSliderInput(session, "slider", value=53940)
  })
}

shinyApp(ui = ui, server = server)
