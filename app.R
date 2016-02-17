## app.R ##
library(shiny)
library(shinydashboard)
library(shinyFiles)
library(gdata)
library(openxlsx)
library(data.table)
library(stringr)
#library(rsconnect)
#library(shinyapps)
source("labtime.R")

# By default, the file size limit is 5MB. It can be changed by
# setting this option. Here we'll raise limit to 9MB.
options(shiny.maxRequestSize = 9*1024^2)


readPasciInfo <- function(p_fp) {
  fr <- scan(p_fp, what=character(), skip=1, nlines=3, sep='|');
  list(vpd_file_name=fr[2], date=fr[7], time=substr(fr[12],1,8))
}

loadFile <- function(input_path, skip, header, sheet, seperator=',', quote='"') {
  inFile <- input_path
  print(input_path)
  data_file <- NULL
  if (is.null(inFile)) {
    NULL
  } 
  
  else {
    print(inFile$type)
    
    if(inFile$type == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
      data_file <- read.xlsx(inFile$datapath, startRow=skip+1,colNames=header)
    } 
    else if(inFile$type == 'application/vnd.ms-excel') {
      data_file <- read.xls(inFile$datapath, skip=skip, header=header, quote=quote, sheet=sheet)
    }
    else {
      data_file <- read.table(inFile$datapath, skip=skip, sep=seperator, quote=quote,header=header,sheet=sheet)   
    }
  }
  
  data_file <- data.table(data_file)
  data_file[,pk:=.I]
  data_file
}


ui <- dashboardPage(
  dashboardHeader(title = "KDT Stripper"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Load KDT Master Sheet", tabName = "kdt_master_sheet", icon = icon("file-excel-o")),
      menuItem("Load Subject Information", tabName = "subject_info", icon = icon("bed")),
      menuItem("Generate PS1 File", tabName='ps1', icon=icon("file-code-o")),
      menuItem("Generate PS2 File", tabName='ps2', icon=icon("file-code-o"))
      
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
                          'text/comma-separated-vralues',
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
              actionButton("upload_button", "Upload File", class='btn-block')
              
          ),
          box(title="File Preview", width=8, 
            dataTableOutput("master_sheet_preview")
          )
        )
      ),
      tabItem(tabName="subject_info", 
        h2("Subject Information"),
          fluidRow(
          box(solidHeader=TRUE, status='warning', width=12,
            textInput("subject_code", "Subject Code", value="3227GX"),
            textInput("fd_start_time", "FD Start Time (EC)", value=5889.52),
            textInput("fd_end_time", "FD End Time (EE)", value=6369.52),
            textInput("period_estimate", "Period Estimate (EG)", value=24.351),
            textInput("comp_min_estimate", "Comp Min Estimate (EL)", value=5908.79)
          ))
      ),
      tabItem(tabName="ps1", 
        fluidRow(
          box(title="PS1 File Options", width=4, status='warning',
            textInput('pasci_dir_path', "Pasci Directory Path",value="/X/People/Research Staff/Beckett_Scott/32-CSR_KDT-FFT_2013.09.16/3227GX/PASCI/C3"), shinyDirButton('pasci_dir', 'Browse', 'Please select a PASCI root folder.'),
            actionButton("generate_ps1", "Generate PS1", icon=icon("gears"), class='pull-right')
          ),
          box(title="Preview", width=8,
            downloadButton("downloadPS1", "Download PS1", class='btn-block'),
            br(),
            dataTableOutput("ps1_preview")
          
          )
        )
      ),
      tabItem(tabName='ps2',
        fluidRow(
          box(title="Preview", width=12,
            actionButton("generate_ps2", "Generate PS2", class='btn-block'),
            downloadButton("downloadPS2", "Download PS2", class='btn-block'),
            downloadButton("downloadPS2_Full", "Download Full Dataset", class='btn-block'),
            hr(),
            dataTableOutput("ps2_preview")
          )
        )
      )
      
    )
  ),
  skin="yellow"
)

# output$directorypath <- renderPrint({parseDirPath(volumes, input$directory)})

server <- function(input, output, session) {
  volumes = c(home="~/", wd="./", getVolumes()())
  shinyDirChoose(input, 'pasci_dir', session=session, roots=volumes)
  
  
  master_sheet <- eventReactive(input$upload_button, {
    ms <- loadFile(input$master_sheet_path, input$skip_rows, input$header, input$sheet_number, input$sep, input$quote)
    ms[,`:=`(KDT.Ending.Epoch=as.numeric(as.character(KDT.Ending.Epoch)),KDT.Beginning.Epoch=as.numeric(as.character(KDT.Beginning.Epoch)))]
    ms   
  }) 
  
  ps1_sheet <- eventReactive({input$generate_ps1}, {
    print("HELLO")
    #print(master_sheet())
    # parseDirPath(volumes, input$directory)
    #master_sheet()[Subject == input$subject_code, {print(as.character(VPD.Filename))},by='pk']
    
    all_files <- list.files(input$pasci_dir_path, full.names = TRUE)
    ps1_list <- character()
    

    for(file_pattern in master_sheet()[Subject==input$subject_code & !is.na(KDT.Beginning.Epoch) & !is.na(KDT.Ending.Epoch)]$VPD.Filename) {
      ps1_list <- c(ps1_list, grep(file_pattern, all_files, value=TRUE, ignore.case = TRUE))
    }
    
    data.table(file_path = ps1_list)
  })
  
  ps2_sheet <- eventReactive(input$generate_ps2, {
  
    
    my_ms <- copy(master_sheet()[Subject==input$subject_code])
    pasci_file_info <- ps1_sheet()[,readPasciInfo(file_path),by='file_path']
    
    ps2 <- data.table(subject_code=my_ms$Subject, vpd_pattern=my_ms$VPD.Filename, kdt_start_epoch=as.numeric(as.character(my_ms$KDT.Beginning.Epoch)), kdt_start_date=my_ms$Begin.Date, 
                      kdt_start_time=my_ms$KDT.Begin.Time, kdt_end_epoch=as.numeric(as.character(my_ms$KDT.Ending.Epoch)), kdt_end_date=my_ms$End.Date, kdt_end_time=my_ms$KDT.End.Time)
    ps2 <- ps2[!is.na(kdt_start_epoch) & !is.na(kdt_end_epoch)]
    ps2[,c("pasci_path", "vpd_file_name", "vpd_start_date", "vpd_start_time"):=pasci_file_info[grep(vpd_pattern, vpd_file_name, ignore.case=TRUE), which=FALSE],by='subject_code,vpd_pattern,kdt_start_epoch']
    
    ps2[,pk:=.I]
    ps2[,pasci_file_dt:=as.pasciDateTime(vpd_start_date, vpd_start_time)]
    ps2[,pasci_file_labtime:=as.labtime(pasci_file_dt)]
    ps2[,kdt_start_labtime:=pasci_file_labtime+((kdt_start_epoch-1)/2/60)]
    ps2[,kdt_end_labtime:=pasci_file_labtime+((kdt_end_epoch-1)/2/60)]
    
    ps2[,tau:=as.numeric(input$period_estimate)]
    ps2[,cbt_comp_min:=as.numeric(input$comp_min_estimate)]
    ps2[,fd_start_labtime:=as.numeric(input$fd_start_time)]
    ps2[,fd_end_labtime:=as.numeric(input$fd_end_time)]
    
    # Set comp_min to comp_min - (24*5)
    ps2[kdt_start_labtime < fd_start_labtime, `:=`(tau=24, cbt_comp_min=cbt_comp_min-(24*5))]
    
    # Set comp_min to comp_min + 24*20
    ps2[kdt_start_labtime > fd_end_labtime, `:=`(tau=24, cbt_comp_min=cbt_comp_min+(24*20))]
    
    
    
    ps2
  })
  
  
  output$downloadPS1 <- downloadHandler(
    filename = function(){ "example_ps1.ps1" },
    content = function(file) {
      ps1_output <- copy(ps1_sheet())
      ps1_output[,file_path:=gsub("/X", "X:",file_path),by="file_path"]
      cat("/*  VP PASCI FILE PARAMETERS\r\n", file=file)
      
      write.table(ps1_output, file, append = TRUE, col.names = FALSE, sep='', quote=FALSE, row.names = FALSE, eol="\r\n")
    }
  )
  
  output$downloadPS2 <- downloadHandler(
    filename = function(){ "example_ps2.ps2" },
    content = function(file) {
      ps2_output <- ps2_sheet()[,list(vpd_file_name, kdt_start_epoch, paste(kdt_start_date, substr(kdt_start_time,1,5)), print(kdt_start_labtime), kdt_end_epoch, paste(kdt_end_date, substr(kdt_end_time,1,5)), print(kdt_end_labtime), tau*60, round(cbt_comp_min,2))]
      
      cat("/*  VP PASCI TIMING PARAMETERS,,,,,,,,\r\n", file=file)
      write.table(ps2_output, file, sep=',', col.names = FALSE, quote=FALSE, row.names = FALSE, append=TRUE, eol="\r\n")
    }
  )
  
  output$downloadPS2_Full <- downloadHandler(
    filename = function(){ "example_ps2_full.csv" },
    content = function(file) {
      write.table(ps1_sheet(), file, col.names = TRUE, sep=',', quote='"', row.names = FALSE, eol="\r\n")
    }
  )
  
  
  
  output$master_sheet_preview <- renderDataTable(master_sheet())
  output$si_sheet_preview <- renderDataTable(si_sheet())
  output$ps1_preview <- renderDataTable(ps1_sheet())
  output$ps2_preview <- renderDataTable(ps2_sheet())
}

shinyApp(ui, server)