## app.R ##
library(shiny)
library(shinydashboard)
library(gdata)
library(openxlsx)
library(data.table)

# By default, the file size limit is 5MB. It can be changed by
# setting this option. Here we'll raise limit to 9MB.
options(shiny.maxRequestSize = 9*1024^2)

ui <- dashboardPage(
  dashboardHeader(title = "KDT Stripper"),
  dashboardSidebar(
    textInput("subject_code", "Subject Code"),
    sidebarMenu(
      menuItem("Load KDT Master Sheet", tabName = "kdt_master_sheet", icon = icon("file-excel-o")),
      menuItem("Load Subject Information", tabName = "subject_info", icon = icon("bed"))
    )
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/app.css")
    ),
    tabItems(
      tabItem(tabName="kdt_master_sheet", 
        h2("KDT Master Sheet"),
        fluidRow(
          box(title="Load File", solidHeader=TRUE, status='warning', width=4,
              fileInput('master_sheet_path', 'Choose file to upload',
                        accept = c(
                          'application/vnd.ms-excel',
                          '.xls',
                          '.xlsx',
                          'text/csv',
                          'text/comma-separated-values',
                          'text/tab-separated-values',
                          'text/plain',
                          '.csv',
                          '.tsv'
                        )
              ),
              tags$hr(),
              checkboxInput('header', 'Header', TRUE),
              numericInput('skip_rows', label="Rows to Skip", value=8),
              numericInput('sheet_number', label="Sheet", value=2),
              radioButtons('sep', 'Separator',
                           c(Comma=',',
                             Semicolon=';',
                             Tab='\t'),
                           ','),
              radioButtons('quote', 'Quote',
                           c(None='',
                             'Double Quote'='"',
                             'Single Quote'="'"),
                           '"'),
                actionButton("upload_button", "Upload File")
              
          ),
          box(title="File Preview", width=8, 
            dataTableOutput("master_sheet_preview")
          )
        )
      ),
      tabItem(tabName="subject_info", 
        h2("Subject Information")
      )
    )
  ),
  skin="yellow"
)

server <- function(input, output) {
  master_sheet <- eventReactive(input$upload_button, {
    inFile <- input$master_sheet_path
    data_file <- NULL
    if (is.null(inFile)) {
      NULL
    } 
    else {
      print(inFile$type)
      
      if(inFile$type == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
        data_file <- read.xlsx(inFile$datapath, startRow=input$skip_rows+1,colNames=input$header)
      } 
      else if(inFile$type == 'application/vnd.ms-excel') {
        data_file <- read.xls(inFile$datapath, skip=input$skip_rows, header=input$header, quote=input$quote, sheet=input$sheet_number)
      }
      else {
        data_file <- read.table(inFile$datapath, skip=input$skip_rows, sep=input$sep, quote=input$quote,header=input$header,sheet=input$sheet_number)   
      }
    }
    
    data_file <- data.table(data_file)
    print(data_file$Subject)
    data_file
  }) 
  
  output$master_sheet_preview <- renderDataTable(master_sheet()[Subject == input$subject_code])
  
}

shinyApp(ui, server)