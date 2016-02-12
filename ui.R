library(shiny)
library(readxl)
library(ggplot2)
library(plotly)
library(shinythemes)
library(markdown)
library(e1071)

shinyUI(
  
  navbarPage(title = "Predicting if a candidate would join or not (Designed for Indian IT Companies)",theme = "bootstrap.css",collapsible = TRUE,
             
             tabPanel("Working Model",
                      
                      fluidRow(
                        
                        column(12, style = "background-color:lightgrey;",
                               
                               fluidRow(
                                 
                                 column(5,
                                        
                                        fluidRow(
                                          
                                          column(5, style = "background-color:grey;color:white",
                                                 
                                                 br(),
                                                 
                                                 radioButtons(inputId = "DOJ", label = "Date of Joining Extension Requested ?", choices = c("Yes", "No"), selected = "No", inline = TRUE),
                                                 
                                                 numericInput(inputId = "Duration", label = "Duration to Accept the Offer", value = 7),
                                                 
                                                 numericInput(inputId = "Notice", label = "Notice Period", value = 30),
                                                 
                                                 selectInput(inputId = "Band", label = "Offered Band", choices = c("E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8", "E9", "E10", "E11", "E12"), selected = "E6", multiple = FALSE),
                                                 
                                                 numericInput(inputId = "exp_hike", label = "Percentage Hike Expected in CTC", value = 10),
                                                 
                                                 numericInput(inputId = "offered_hike", label = "Percentage Hike Offered in CTC", value = 10),
                                                 
                                                 radioButtons(inputId = "Bonus", label = "Was a Joining Bonus Offered ?", choices = c("Yes", "No"), selected = "No", inline = TRUE)
                                                 
                                                 #radioButtons(inputId = "Relocate", label = "Was relocation required ?", choices = c("Yes", "No"), selected = "No", inline = TRUE)
                                                 
                                          ),
                                          
                                          column(5, style = "background-color:grey; color:white",
                                                 
                                                 br(),
                                                 
                                                 radioButtons(inputId = "Gender", label = "Gender", choices = c("Male", "Female"), selected = "Male", inline = TRUE),
                                                 
                                                 selectInput(inputId = "Source", label = "Candidate Source", choices = c("Agency", "Direct", "Employee Referral"), selected = "Direct", multiple = FALSE),
                                                 
                                                 numericInput(inputId = "Rex", label = "Relevant Experience in Years", value = 5),
                                                 
                                                 selectInput(inputId = "Lob", label = "Line of Business", choices = c("AXON", "BFSI", "BSERV", "CORP", "CSMP", "EAS", "ERS", "ETS", "Healthcare", "INFRA", "MMS", "SALES"), selected = "ERS", multiple = FALSE),
                                                 
                                                 selectInput(inputId = "Location", label = "Location", choices = c("Ahmedabad", "Bangalore", "Noida", "Chennai", "Cochin" , "Coimbatore", "Gurgaon", "Hyderabad", "Kolkata", "Mumbai", "Pune", "Others"), selected = "Bangalore", multiple = FALSE),
                                                 
                                                 numericInput(inputId = "Age", label = "Age", value = 30),
                                                 
                                                 radioButtons(inputId = "Relocate", label = "Was relocation required ?", choices = c("Yes", "No"), selected = "No", inline = TRUE)
                                                 
                                          )
                                        ),
                                        
                                        fluidRow(
                                          
                                          column(5,
                                                 
                                                 br(), br(), br(),
                                                 
                                                 tags$style(type='text/css', '#goButton {background-color: rgba(0,0,0,1); color: white;}'),
                                                 actionButton("goButton", "Predict the Probability\nof Joining"),
                                                 
                                                 br(), br(), br(), br(), br()
                                                 
                                          ),
                                          
                                          column(5,
                                                 
                                                 br(),
                                                 
                                                 tags$style(type='text/css', '#text2 {background-color: rgba(0,0,255,0.10); color: blue;}'), 
                                                 tags$style(type='text/css', '#Prob {background-color: rgba(0,0,255,0.10); color: blue;}'), 
                                                 
                                                 h2(textOutput("text2")),
                                                 h2(textOutput(outputId = "Prob", inline = TRUE))
                                                 
                                          )
                                        )
                                 ),
                                 
                                 column(7,
                                        
                                        fluidRow(
                                          
                                          column(7,
                                                 
                                                 h3("Performance of our Prediction Model"),
                                                 
                                                 tabsetPanel(
                                                   
                                                   tabPanel("Model Performance Measures", 
                                                            dataTableOutput("accuracy"),
                                                            br(), br(),
                                                            p("The model provides an accuracy of about 76%. Given the randomness of data and an observed week correlation between the parameters and the outcome (Candidate Joined / Not Joined), this is apparently a fairly reasonable accuracy")),
                                                   tabPanel("Plot - Test Results", 
                                                            plotOutput("plot"),
                                                            br(), br(), br(), br(), br(), br(),
                                                            p("As we can see, the proportion of False-Positives and False-Negatives is very less and the model is able to predict the outcome to a fairly reasonable extent.")),
                                                            br(), br(),
                                                            p("Note: Please wait for a few seconds once you start the App for the data to be loaded. Please start using the App once the table of performamce measures / plot appears above.", style = "background-color:grey; color:white")
                                                   
                                                 )
                                                 
                                          )
                                        )
                                 )
                               )
                        )
                      )
                      
             ),
             
             tabPanel("Descriptive Analysis",
                      fluidRow(htmlOutput("html"))
             ),
             
             tabPanel("App Help",
                      fluidRow(htmlOutput("fig"))
             )
             
  )
)
