library(shiny)
library(caret)
library(ggplot2)
library(rmarkdown)
library(htmltools)
library(RCurl)
library(e1071)


transform_data <- function(x)
{
  
  x$Duration.to.accept.offer <- ifelse(is.na(x$Duration.to.accept.offer), 0, x$Duration.to.accept.offer)
  x$Duration.to.accept.offer <- ifelse(x$Duration.to.accept.offer < 0, 0, x$Duration.to.accept.offer)
  x$Duration.to.accept.offer <- ifelse(x$Duration.to.accept.offer > 125, 125, x$Duration.to.accept.offer)
  
  if(is.na(x$exp_hike)){
    x$exp_hike <- x$offered_hike}
  
  if(is.na(x$offered_hike)){
    x$offered_hike <- x$exp_hike}
  
  if(is.na(x$exp_hike) && is.na(x$offered_hike)){
    x$offered_hike <- 0
    x$exp_hike <- 0}
  
  x$hike_diff <- x$exp_hike - x$offered_hike
  
  x$Rex.in.Yrs <- as.numeric(as.vector(x$Rex.in.Yrs))
  if(is.na(x$Rex.in.Yrs)) x$Rex.in.Yrs <- 0
  
  x$Age <- as.numeric(as.vector(x$Age))
  if(is.na(x$Age)) x$Age <- 0
  
  x$Location <- as.character(as.vector(x$Location))
  if(is.na(x$Location)) x$Location <- " "
  
  x$LOB <- as.character(as.vector(x$LOB))
  if(is.na(x$LOB)) x$LOB <- " "
  
  x <- x[, c(-5,-6)]
  
  return(x)
  
}

transform_data_hr <- function(x)
{
  
  x <- x[, -1]
  
  x$Status <- ifelse(x$Status == "Joined", 1,0)
  
  x$Duration.to.accept.offer <- ifelse(is.na(x$Duration.to.accept.offer), 0, x$Duration.to.accept.offer)
  x$Duration.to.accept.offer <- ifelse(x$Duration.to.accept.offer < 0, 0, x$Duration.to.accept.offer)
  x$Duration.to.accept.offer <- ifelse(x$Duration.to.accept.offer > 125, 125, x$Duration.to.accept.offer)
  
  for(i in 1:nrow(x)) {
    if(is.na(x[i,5])){ 
      x[i,5] <- x[i,6]}
  }
  
  for(i in 1:nrow(x)) {
    if(is.na(x[i,6])){ 
      x[i,6] <- x[i,5]}
  }
  
  for(i in 1:nrow(x)) {
    if(is.na(x[i,6]) && is.na(x[i,6])){ 
      x[i,6] <- 0
      x[i,5] <- 0}
  }
  
  for(i in 1:nrow(x)) {
    if(is.na(x[i,7])){ 
      x[i,7] <- 0}
  }
  
  x$hike_diff <- x$Pecent.hike.expected.in.CTC - x$Percent.hike.offered.in.CTC
  
  x$Rex.in.Yrs <- as.numeric(as.vector(x$Rex.in.Yrs))
  x[is.na(x$Rex.in.Yrs), "Rex.in.Yrs"] <- 0
  
  x$Age <- as.numeric(as.vector(x$Age))
  x[is.na(x$Age), "Age"] <- 0
  
  x$Location <- as.character(as.vector(x$Location))
  x[is.na(x$Location), "Location"] <- " "
  
  x$LOB <- as.character(as.vector(x$LOB))
  x[is.na(x$LOB), "LOB"] <- " "
  
  x <- x[, c(-5,-6,-7)]
  
  
  return(x)
  
}


url1 <- "https://www.dropbox.com/s/vurla8dt9t26pu9/HR.csv?dl=1"
data <- getURL(url1, ssl.verifypeer=0L, followlocation=1L)
hr_data <- read.csv(text=data)

url2 <- "https://www.dropbox.com/s/dmeoxdsknpvlh00/HR_Analysis.html?dl=1"
data_html <- getURL(url2, ssl.verifypeer=0L, followlocation=1L)

url3 <- "https://www.dropbox.com/s/6kdadh9mbsk648l/Tutor.html?dl=1"
fig_html <- getURL(url3, ssl.verifypeer=0L, followlocation=1L)


hr_data <- transform_data_hr(hr_data)
mod_fit2 <- glm(formula = Status ~ DOJ.Extended + Duration.to.accept.offer + 
                  Notice.period + Offered.band + Joining.Bonus + Candidate.relocate.actual + 
                  Candidate.Source + Rex.in.Yrs + LOB + Age + hike_diff, family = binomial(link = "logit"),
                data = hr_data)

results <- predict(mod_fit2, hr_data, "response")
final_results <- as.vector(ifelse(results > 0.5,1,0))
actual_results <- as.vector(hr_data$Status)
tab <- data.frame(actual = actual_results, predicted = final_results, difference = abs(as.numeric(as.vector(actual_results)) - as.numeric(as.vector(final_results))))

cm <- confusionMatrix(actual_results, final_results)
fit_data <- data.frame(cm$overall)
names(fit_data) <- c("Measure Values")
fit_data$`Measue Names` <- rownames(fit_data)


shinyServer(
  
  function(input, output)
    
  {
    
    observe({
      
      if(input$goButton == 0) {
        
        fit_data[, 1] <- round(fit_data[, 1],2) 
        output$accuracy <- renderDataTable(fit_data[ ,c(2,1)], options = list(paging = FALSE, searching = FALSE, info = FALSE))
        
        output$plot <- renderPlot(ggplot(tab, aes(x = actual, y = predicted, color = as.factor(difference))) + geom_jitter() + scale_colour_manual(values=c("darkgreen", "coral"),  name = "Results",labels=c("Match", "Do not Match")), width = 600, height = 500)
        
        output$html <- renderText(data_html)
        
        output$fig <- renderText(fig_html)
        
        
      } else {
        
        
        isolate({
          
          new_data <- data.frame(DOJ.Extended = input$DOJ, Duration.to.accept.offer = input$Duration, Notice.period = input$Notice,
                                 Offered.band = input$Band, exp_hike = input$exp_hike, offered_hike = input$offered_hike,
                                 Joining.Bonus = input$Bonus, Candidate.relocate.actual = input$Relocate,
                                 Gender = input$Gender, Candidate.Source = input$Source, Rex.in.Yrs = input$Rex,
                                 LOB = input$Lob, Location = input$Location, Age = input$Age, Status = as.numeric(0), hike_diff = 0)
          
          final_data <- transform_data(new_data)
          
          final_data$Status_prob <- as.numeric(round(predict(mod_fit2, final_data, "response"), 4))
          
          if(final_data$Status_prob <= 0.05){
            
            output$Prob <- renderText("Extremely low Probability")
            
          } else{
            
            if(final_data$Status_prob >= 0.95){
              
              output$Prob <- renderText("Extremely high Probability")
              
            } else {
              
              output$Prob <- renderText(paste((final_data$Status_prob * 100), "%"))
              
            }
            
          }
          
          output$text2 <- renderText("Probability of Joining : ")
          
        })
        
      }
      
    })
    
  }
  
)