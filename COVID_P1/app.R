#R package
library(shiny)
library(shinydashboard)
library(dashboardthemes)
library(shinydashboardPlus)
library(shinyWidgets)
library(factoextra)

library(ggplot2)
library(dplyr)
library(plotly)
library(tidyverse)
library(gridExtra)
library(kableExtra)
library(maps)
library(viridis)

library(readr)
library(readxl)
library(tibble)
library(janitor)
library(reshape2)
library(ggthemes)
library(hablar)
library(vars)
library(tsDyn)

library(pheatmap)
library(dygraphs)
library(zoo)
library(latticeExtra)
library(wordcloud2)
library(DiagrammeR)
#data
word_dat = read.csv("data/word.csv")
covid_index = read.csv("data/Percent_COVID_Index.csv")
covid_pred = read_csv("data/Percent_COVID_Index.csv")
Countries <- c('Australia', 'Belgium', 'Brazil', 'Canada', 'China HongKong', 'France', 'Germany', 'India', 'Israel', 'Italy', 'Japan', 'Netherlands', 'Qatar', 'Russia', 'Saudi Arabia', 'Singapore', 'South Korea', 'Spain', 'Switzerland', 'Thailand', 'Turkey', 'United Arab Emirates', 'United Kingdom', 'United States', 'Vietnam', 'World')
windowSize = 13

#function

l_p_distance <- function(x, y, p){
  distance = sum((x - y)^p, na.rm = TRUE)^(1/p)
  return(distance)
}

create_subset <- function(data, country) {
  model_vars = data %>% dplyr::filter(CountryName==country) %>% dplyr::select(new_cases, COVID_search_index, new_death_weekly, new_test_weekly, positive_rate_weekly)
  return(model_vars)
}


make_var <- function(model_vars, train = 100) {
  lag = VARselect(model_vars[1:train,])$selection[4][[1]] + 1
  model = vars::VAR(model_vars[1:train,],lag.max = lag, ic="FPE")
  return(model)
}

############ this is not my code !!!!! ####################
VAR.pred <- function(x, varest, n.ahead = 1)
{
  lag = varest$p
  nvars = ncol(varest$y)
  coefMatrix = matrix(NA, nvars, 1+nvars*lag)
  
  for(k in 1:nvars) {
    coefMatrix[k, ] = (coef(varest)[[k]])[, 1]
  }
  
  cst = as.matrix(coefMatrix[, ncol(coefMatrix)])
  M = coefMatrix[, -ncol(coefMatrix)]
  prediction = matrix(NA, n.ahead, nvars)
  x_subset = as.matrix(x[nrow(x):(nrow(x)- lag + 1), ])
  
  for(i in 1:n.ahead)
  {
    nextWeek = M[, 1:nvars]%*%t(x_subset)[, 1]
    for(l in 2:lag) {
      nextWeek = nextWeek + M[, (1 + nvars*(l-1)):(nvars*l)]%*%t(x_subset)[, l]
    }
    nextWeek = nextWeek + cst
    
    prediction[i, ] = t(nextWeek) 
    x_subset = rbind(t(nextWeek), x_subset)[1:lag, ]
  }
  
  result = data.frame(prediction)
  names(result) = dimnames(x)[[2]]
  
  return(result)
}

#####################################################

test_var <- function(model, data, test_start, test_end) {
  predictions = c()
  truevals=c()
  
  for (i in test_start:test_end) {
    pred = VAR.pred(x = data[1:i,] ,varest = model, n.ahead = 1)[1][[1]]
    trueval = data[i+1,1][[1]]
    truevals = c(truevals, trueval)
    predictions = c(predictions, pred)
  }
  
  return(data.frame(prediction = predictions, actual = truevals))
}


prediction_result <- function(date, country, covid_data) {
  date_filter = covid_data %>% dplyr::filter(CountryName==country) %>% dplyr::select(Date)
  dates = as.character(date_filter$Date)
  this_week = which(dates == date)
  target_data = create_subset(data = covid_data,country = country)
  
  model = make_var(target_data, train = 100)
  direction = ""
  next_week_case = VAR.pred(x = target_data[1:this_week,], varest = model, n.ahead = 1)[,1]
  
  if (next_week_case > target_data$new_cases[this_week]) {
    direction = "increase"
  }
  if (next_week_case < target_data$new_cases[this_week]) {
    direction = "decrease"
  }
  if (next_week_case == target_data$new_cases[this_week]) {
    direction = "level"
  }
  return(data.frame(new_case_next_week = next_week_case, direction = direction))
}

draw_compare <- function(comparison_data) {
  comparison_data = cbind(week = 1:nrow(comparison_data), comparison_data)
  d <- melt(comparison_data, id.vars=c("week"))
  print(ggplot(d, aes(x=week, y=value, col=variable)) 
        + geom_point() 
        + geom_line() 
        + xlab("Week")  
        + ylab("New Cases") 
        + ggtitle(stringr::str_glue("Prediction vs Actual new cases in {country}")) 
        + theme(plot.title = element_text(family = "serif", 
                                          face = "bold", 
                                          size = 15, 
                                          hjust = 0.5, 
                                          vjust = 2, 
                                          angle = 0, 
                                          lineheight = 20, 
                                          margin = margin(20, 0, 0, 0)), 
                plot.caption = element_text(hjust = 0.5, colour = "brown4"), 
                plot.caption.position = "panel"))
}

# Shiny UI -------
ui <- dashboardPage(skin = "black",
                    dashboardHeader(userOutput("user"),title = shinyDashboardLogo(theme = "blue_gradient",boldText = "COVID-19",mainText = "Search Index",badgeText = "v4.1"),
                                    fixed = T),
                    dashboardSidebar(
                      sidebarMenu(
                        menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
                        menuItem("Cluster", tabName = "cluster", icon = icon("th")),
                        menuItem("Model" , tabName = "model", icon = icon("signal")),
                        menuItem("Data" , tabName = "data", icon = icon("database")),
                        menuItem("Help" , tabName = "help", icon = icon("paperclip"))
                      )),
                    dashboardBody(
                      setBackgroundColor(
                        color = "#FFFFFF",
                        shinydashboard = T
                      ),
                      tags$head( 
                        tags$style(HTML(".main-sidebar {font-size: 15px}")) #change the font size to 20
                      ),
                      tabItems(
                        tabItem(tabName = "dashboard",
                                fluidRow(
                                  box(width = 12, 
                                      wordcloud2Output('wordcloud2',height = "15vh"),
                                      HTML(paste("<p><h1>", "Study Search Terms and Related Policy during COVID-19 Pandemic, based on Google Search Index","</h1><p>")),
                                      HTML(paste("<p><h3>", "   over periods of Jan 2020-April 2022.","</h3><p>"))),
                                  box(width = 8,height = "40vh",title = "Target",style = "overflow-x: scroll;overflow-y: scroll;height: 40vh;",
                                      p("It is an ",strong("App")," for all media workers (including if you work for Twitter, Instagram, Youtube, Tiktok, or if you're an Influencer, Instagram Models, We-Media, etc).",style="text-align:justify;color:black;background-color:lavender;padding:15px;border-radius:10px"),
                                      p("You can check out our app to see what are the top search terms related to COVID-19 new cases in each country. Based on these hot words, you can post about them on social media platforms. This can make your post more influential and relevant.",style="text-align:justify;color:black;background-color:lavender;padding:15px;border-radius:10px"),
                                      p("We also showed what was happening in each country at the point in time when COVID-19 new cases were increasing dramatically. Explores why hot words differ from country to country. This will make it easier for media workers to sort and summarize relevant information to produce more news.",style="text-align:justify;color:black;background-color:lavender;padding:15px;border-radius:10px"),
                                      p("In addition, our app can approximately predict the trend and number of new cases  for next week. It also helps media worker or journalists publish predictive articles. It also helps the government to formulate relevant policies and measures in advance.",style="text-align:justify;color:black;background-color:lavender;padding:15px;border-radius:10px")),
                                  box(width = 4,title = "Popular search terms during COVID-19 pandemic",
                                      plotlyOutput("world_map"))),
                                fluidRow(
                                  box(width = 8, title = textOutput("dygraph_title"),
                                      dygraphOutput("new_case_event")),
                                  column(width = 4,
                                         box(width = 12,title = "Big Event", htmlOutput("big_event"),style = "overflow-x: scroll;overflow-y: scroll;height: 280px;"),
                                         box(width = 12, title = "Country",
                                             selectInput("Country_event",label = NULL,choices = c('Australia', 'Belgium', 'Brazil', 'Canada', 'Hong Kong', 'France', 'Germany', 'India', 'Israel', 'Italy', 'Japan', 'Netherlands', 'Qatar', 'Russia', 'Saudi Arabia', 'Singapore', 'South Korea', 'Spain', 'Switzerland', 'Thailand', 'Turkey', 'United Arab Emirates', 'United Kingdom', 'United States', 'Vietnam', 'World'),selected = "Australia")))
                                )
                                ),
                        
                        tabItem(tabName = "cluster",
                                fluidRow(
                                  box(width = 12,title = h2("Search Index and Policy"),
                                      h4("The same level new case percentage country for policy and rank search index change"),
                                      box(width = 12, title = "Tips to Use",
                                          grVizOutput("grviz",height = "100px"))),
                                  column(width = 6,
                                         box(width = 12,title = "Input",
                                             selectInput("country_cluster","Location:",choices = c("Australia",
                                                                                                   "Belgium",
                                                                                                   "Brazil",
                                                                                                   "Canada",
                                                                                                   "France",
                                                                                                   "Germany",
                                                                                                   "Hong Kong",
                                                                                                   "India",
                                                                                                   "Israel",
                                                                                                   "Italy",
                                                                                                   "Japan",
                                                                                                   "Netherlands",
                                                                                                   "Qatar",
                                                                                                   "Russia",
                                                                                                   "Saudi Arabia",
                                                                                                   "Singapore",
                                                                                                   "South Korea",
                                                                                                   "Spain",
                                                                                                   "Switzerland",
                                                                                                   "Thailand",
                                                                                                   "Turkey",
                                                                                                   "United Arab Emirates",
                                                                                                   "United Kingdom",
                                                                                                   "United States",
                                                                                                   "Vietnam"),selected = "Australia",width = "60%"),
                                             selectInput("hot_word","Key Word:",choices = c("LOCK DOWN" = "lockdown",
                                                                                             "MASK" = "mask",
                                                                                             "WFH" = "wfh"),selected = "wfh",width = "60%"),
                                             box(HTML("<p><h4>Level of color label for new case percentages</h4></p><Ol><li>LIGHT-BLUE: VERY STRONG</li><li>DARK-BLUE: STRONG</li><li>GREEN: NETURE</li><li>RED: WEAK</li></Ol>"),title = textOutput("cluster_country"),width = 12),
                                             box(textOutput("policy_cluster"),width = 12,title = "Policy"),
                                             box(htmlOutput("ref_cluster"),width = 12,title = "Reference(Link):")),
                                         box(width = 12,title = "The rank of Hashtag in each color label",dataTableOutput("cluster_table"),style = "overflow-x: scroll;overflow-y: scroll;")),
                                  column(width = 6,
                                         tabBox(selected = "Tab1",side = "right",width = 12,title = "New cases as a percentage in total population in each country",
                                           tabPanel("Tab1", imageOutput("image")),
                                           tabPanel("Tab2", plotOutput("bar_3d"))
                                         ))
                                )
                                
                                ),
                        
                        tabItem(tabName = "model",
                                box(width = 12,h3("New Cases Estimator")),
                                tags$head(tags$style(HTML(".small-box {height: 23vh}"))),
                                valueBoxOutput("new_case_pred",width = 6),
                                valueBoxOutput("direction_pred",width = 6),
                                box(width = 12, title = h3("Input"),
                                    selectInput("country_pred",HTML(paste("<h5>", "COUNTRY:","</h5>")),width = "50%",choices = c('Australia', 'Belgium',  'Canada', 'China HongKong', 'France', 'Germany', 'India', 'Israel', 'Italy', 'Japan', 'Netherlands',  'Russia', 'Saudi Arabia', 'South Korea', 'Spain', 'Switzerland', 'Thailand', 'Turkey', 'United Arab Emirates', 'United Kingdom', 'United States')),
                                    dateInput("date_pred",HTML(paste("<h5>", "DATE:","</h5>")),width = "50%",min = as.Date("2021-12-26"),max = as.Date("2022-04-10"),value = as.Date("2021-12-26"),daysofweekdisabled = c(1,2,3,4,5,6))),
                                box(width = 12,title = h3("Interpretation"),htmlOutput("predict")))
                        
                                ,
                        
                        tabItem(tabName = "data",
                                box( title = "Google Trend Data", width = 12,
                                     column(width = 12,DT::dataTableOutput("data"),style = "overflow-x: scroll;overflow-y: scroll;"))),
                        
                        tabItem(tabName = "help",
                                box(width = 12,
                                    htmlOutput("help_text")))
                      )
                    ),
                    footer = dashboardFooter(right = "COVID P1")
)


# Shiny Server Side -------
server <- function(input, output) {
  top_3_df = read.csv("data/top_3.csv")
  df_cluster = read.csv("data/df_cluster.csv")
  
  #header
  
  output$user <- renderUser({
    dashboardUser(
      name = "COVID P1", 
      image = "head.jpg",
      title = "Project",
      footer = p(socialButton(href = "https://github.sydney.edu.au/czen8507/DATA3888",
                              icon = icon("github")), class = "text-center")
      )
  })
  
  #home page
  event = read.csv("data/event.csv")
  event$Date.spike.=as.Date(event$Date.spike.,'%Y.%m.%d')
  new_case = read.csv("data/New_case.csv")
  
  output$wordcloud2 <- renderWordcloud2({
    wordcloud2(word_dat, size=1)
  })
  
  output$dygraph_title <- renderText({
    c = input$Country_event
    t = paste("New case in",c)
    t
  })
  
  output$new_case_event <- renderDygraph({
    c = input$Country_event
    event_c = subset(event,Country == c)
    event_c = event_c[order(event_c$Date.spike.),]
    newcase = subset(new_case,location == c)
    newcase = newcase[,c("date","new_cases")]
    newcase_date = zoo(newcase,as.Date(newcase$date))
    J.ts<-data.frame("new_case"=newcase_date[,2])
    q <- dygraph(J.ts) %>%
      dySeries("new_case", label = "New case")%>%
      dyRangeSelector()%>% 
      dyLegend(show = 'follow')
    a = nrow(event_c)
    if (a == 1){
      q <- q%>%dyEvent(date = event_c[a,]$Date.spike.,label = paste("[",a,"]",event_c[a,]$Summary,sep = ""),color = "blue")
    }
    if (a > 1){
      for(i in 1: a){
        q <- q%>%dyEvent(date = event_c[i,]$Date.spike.,label = paste("[",i,"]",event_c[i,]$Summary,sep = ""),color = "blue")
      }
    }
    q
  })
  
  output$big_event <- renderText({
    c = input$Country_event
    event_c = subset(event,Country == c)
    event_c = event_c[order(event_c$Date.spike.),]
    a = nrow(event_c)
    text_event = ""
    if (a == 1){
      text_event = paste(text_event,"<p><h5><strong>[1]",event_c[a,]$Summary,"</strong></h5></p><p>",event_c[a,]$Description,"</p><p><a href=",event_c[a,]$Website1,">",event_c[a,]$Website1,"</a></p><p><a href=",event_c[a,]$Website.2,">",event_c[a,]$Website.2,"</a></p>",sep = "")
    }
    if (a > 1){
      for(i in 1: a){
        text_event = paste(text_event,"<p><h5><strong>[",i,"]",event_c[i,]$Summary,"</strong></h5></p><p>",event_c[i,]$Description,"</p><p><a href=",event_c[i,]$Website1,">",event_c[i,]$Website1,"</a></p><p><a href=",event_c[i,]$Website.2,">",event_c[i,]$Website.2,"</a></p>",sep = "")
      }
    }
    text_event = HTML(text_event)
  })
  
  output$world_map <- renderPlotly({
    colnames(top_3_df) <- c('CountryName', 'Fisrt Rank', 'Second Rank', 'Third Rank', 'Fourth Rank')
    df_world_code <- read.csv("data/2014_world_gdp_with_codes.csv")
    df_world_code = df_world_code[,c("COUNTRY", "CODE")]
    df_map = left_join(df_world_code,top_3_df,by = c("COUNTRY" = "CountryName"))
    df_map$text = lapply(paste("Country:",df_map$COUNTRY,"\n",
                               "1:", df_map$`Fisrt Rank`, "\n",
                               "2:", df_map$`Second Rank`, "\n",
                               "3:", df_map$`Third Rank`
    ), htmltools::HTML)
    df_map$na = ifelse(df_map$`Fisrt Rank`=="NA",0,1)
    df_map$na[is.na(df_map$na)]=0
    g <- list(
      projection = list(
        type = 'orthographic'
      ),
      showland = TRUE,
      showcountries = T,
      landcolor = toRGB("#e5ecf6")
    )
    
    fig <- plot_ly(data = df_map,type = 'choropleth',z = df_map$na, locations=df_map$CODE, text=df_map$text,hoverinfo = 'text', colors="Purples")%>% hide_colorbar()
    fig <- fig %>% layout(geo = g)
    fig
  })
  
  #cluster page
  policy = read.csv("data/policy.csv")
  covid_full = covid_index[,c("CountryName", "Date", "new_cases", "new_case_percentage")]
  covid_full = covid_full %>%rename(Country = CountryName,new_case_weekly = new_cases)
  covid_full = covid_full %>%
    mutate(Country = replace(Country, Country == "China HongKong", "Hong Kong"))
  countries = c("Brazil","France", "Germany", "India","Italy", "Spain", "Turkey", "United States", "United Kingdom", "Australia", "Canada", "Singapore","Thailand","Qatar","Netherlands","Belgium","Vietnam","Hong Kong","Russia","Switzerland","Japan","South Korea","Saudi Arabia","United Arab Emirates","Israel")
  countries <- sort(countries)
  covid_full$Date <- as.Date(covid_full$Date)
  ## selecting the 25 countries and required time period. 
  covid <- covid_full[covid_full$Country %in% countries, ]
  covid <- covid[ (covid$Date >= "2020-01-26" & covid$Date <= "2022-04-14") , ]
  time_index <- seq(as.Date("2020-01-26"), as.Date('2022-04-14'),'days')
  
  covid_alternative <- NULL # create a new data frame to store result 
  
  for ( i in countries){
    thiscountry <- covid[ covid$Country == i , ] 
    thiscountry <- thiscountry[ match(time_index, thiscountry$Date) , ] # ensure the time index is in order of the time index, by matching the two vectors 
    covid_alternative <- rbind(covid_alternative,thiscountry) 
  }
  p = 2
  covid_list = split.data.frame(covid[,c("Date","new_case_percentage")], covid$Country)
  n = length(countries)
  distance_matrix <- matrix(0, n, n)
  dateindex = covid_list[[1]]$Date
  for (i in 1:n ){
    for (j in 1:n){
      index_i = match(covid_list[[i]]$Date, dateindex)
      index_j = match(covid_list[[j]]$Date, dateindex) 
      ts_i <- covid_list[[i]][index_i,"new_case_percentage"]
      ts_j <- covid_list[[j]][index_j,"new_case_percentage"]
      distance_matrix[i,j] <-  l_p_distance(ts_i, ts_j, p)
    }
  }
  rownames(distance_matrix) <- colnames(distance_matrix) <- countries
  distance_matrix[!is.finite(distance_matrix)] <- 0
  
  output$cluster_country <- renderText({
    country_policy = input$country_cluster
    word_policy = input$hot_word
    policy_select = subset(policy, country == country_policy&policy.type == word_policy)
    color_clu = policy_select$cluster.group
    paste(country_policy, "is in the",color_clu,"group.")
  })
  
  output$policy_cluster <- renderText({
    country_policy = input$country_cluster
    word_policy = input$hot_word
    policy_select = subset(policy, country == country_policy&policy.type == word_policy)
    policy_select$policy.detail
  })
  
  output$ref_cluster <- renderText({
    country_policy = input$country_cluster
    word_policy = input$hot_word
    policy_select = subset(policy, country == country_policy&policy.type == word_policy)
    HTML(paste("<a href='",policy_select$Reference,"'>",policy_select$Reference,"</a>"))
  })
  
  
  
  Final = covid_full[which(covid_full$Country != "World"),]
  Final = Final %>%
    mutate(group = case_when(
      Country == "Australia" ~ "darkblue",
      Country == "United Kingdom" ~ "darkblue",
      Country == "Italy" ~ "darkblue",
      Country == "Spain" ~ "darkblue",
      Country == "United States" ~ "darkblue",
      Country == "Israel" ~ "lightblue",
      Country == "Netherlands" ~ "lightblue",
      Country == "Belgium" ~ "lightblue",
      Country == "France" ~ "lightblue",
      Country == "Switzerland" ~ "lightblue",
      Country == "South Korea" ~ "green",
      Country == "Hong Kong" ~ "green",
      Country == "Vietnam" ~ "green",
      Country == "Germany" ~ "green",
      Country == "Singapore" ~ "green",
      Country == "Russia" ~ "red",
      Country == "Turkey" ~ "red",
      Country == "Saudi Arabia" ~ "red",
      Country == "India" ~ "red",
      Country == "Japan" ~ "red",
      Country == "Thailand" ~ "red",
      Country == "Brazil" ~ "red",
      Country == "United Arab Emirates" ~ "red",
      Country == "Canada" ~ "red",
      Country == "Qatar" ~ "red",
      Country == "World" ~ "gg"))
  data = Final %>% group_by(Country, group) %>% summarise(percent = mean(new_case_percentage)) 
  data <- data.frame(data %>% arrange(group))
  
  output$bar_3d <- renderPlot({
    rank = data.frame(
      policy = as.factor(rep(c("lockdown","mask","WFH"),4)),
      label_color = as.factor(rep(c("Red","Dark blue","Light blue","Green"),3)),
      value = as.integer(c(5.2,3.8,7.4,4.8,5.0,5.0,2.8,8.6,7.7,2.4,4.8,3.2)))
    
    # library(RColorBrewer)
    # mycolors<-brewer.pal(3, "Blues")
    mycolors <- c("Red","Dark blue","Light blue","Green")
    
    cloud(value~label_color+policy,rank, panel.3d.cloud=panel.3dbars,col.facet=mycolors,
          xbase=0.4, ybase=0.4, scales=list(arrows=FALSE, col="grey"), 
          par.settings = list(axis.line = list(col = "transparent")))
  })
  
  output$cluster_table <- renderDataTable({
    df_cluster
  })
  
  output$image <- renderImage({
    list(src = 'data/img.png',
         width = '100%')
  },deleteFile=FALSE)
  
  output$grviz = renderGrViz({
    DiagrammeR::grViz("digraph {
graph [layout = dot, rankdir = LR]
node [shape = rectangle, style = filled, fillcolor = White]
Step1[label = 'Choose the country \nto find the color labels in a circle plot',fillcolor = LightBlue]
Step2[label = 'Through the color labels \nto find the level of new case percentage in the country',fillcolor = LightSkyBlue]
Step3[label = 'Choose the search terms/country \nto indicate policies in this period',fillcolor = SkyBlue]
Step4[label = 'Through the policies in each country, \nfind the correlation in the 3 search terms for color labels',fillcolor = DeepSkyBlue]
Step1 -> Step2 -> Step3 -> Step4
}")
  })
  
  #model page
  distinct_countries = c(covid_pred[,1] %>% dplyr::distinct(CountryName))
  n_countries = lengths(distinct_countries)
  
  test_direction <- function(model, data, test_start, test_end) {
    predictions = c()
    truedirs=c()
    
    for (i in test_start:test_end) {
      pred = VAR.pred(x = data[1:i,] ,varest = model, n.ahead = 1)[1][[1]]
      this_week = data[i,1][[1]]
      trueval = data[i+1,1][[1]]
      truedir = ""
      pred_dir = ""
      if (trueval > this_week) {
        truedir = "increase"
      }
      if (trueval < this_week) {
        truedir = "decrease"
      }
      if (trueval == this_week) {
        truedir = "level"
      }
      
      if (pred > this_week) {
        pred_dir = "increase"
      }
      if (pred < this_week) {
        pred_dir = "decrease"
      }
      if (pred == this_week) {
        pred_dir = "level"
      }
      
      truedirs = c(truedirs, truedir)
      
      predictions = c(predictions, pred_dir)
    }
    return(data.frame(prediction = predictions, actual = truedirs))
  }
  
  
  acc = c()
  for (i in 1:n_countries) {
    country = distinct_countries$CountryName[[i]]
    if (country != "Brazil" && country != "Qatar" && country != "Singapore" && country != "Vietnam" && country != "World") {
      innerty = test_direction(make_var(create_subset(data = covid_pred,country = country), train = 100), data = create_subset(data = covid_pred,country = country), test_start = 100, test_end=115)
      acc = c(acc, mean(innerty$prediction == innerty$actual))
    }
  }
  
  output$predict <- shiny::reactive({
    
    predict_date = input$date_pred
    predict_country = input$country_pred
    pre = prediction_result(date = predict_date, country = predict_country, covid_data = covid_pred)
    text = paste("<p>Today is <strong>", predict_date ,"</strong>.</p><p> The <strong>number of new cases for next week in ", predict_country ,"</strong> will be about <strong>",round(pre$new_case_next_week),"</strong> new cases. </p><p>Compared with this week, the number will <strong>",pre$direction,"</strong>.",sep ="" )
    text = paste("<h4>",text,"</h4>")
    text = HTML(text)
    text
  })
  
  output$new_case_pred <- renderValueBox({
    predict_date = input$date_pred
    predict_country = input$country_pred
    pre = prediction_result(date = predict_date, country = predict_country, covid_data = covid_pred)
    valueBox(
      tags$p(round(pre$new_case_next_week), style = "font-size: 130%;"), "NEW CASE", icon = icon("exclamation"),
      color = "purple"
    )
  })
  
  output$direction_pred <- renderValueBox({
    predict_date = input$date_pred
    predict_country = input$country_pred
    pre = prediction_result(date = predict_date, country = predict_country, covid_data = covid_pred)
    if (pre$direction == "decrease"){
      a = "arrow-down"
      color_dir = "blue"
    }
    if (pre$direction == "increase"){
      a = "arrow-up"
      color_dir = "red"
    }
    if (pre$direction == "level"){
      a = "arrow-right"
      color_dir = "purple"
    }
    valueBox(
      tags$p(toupper(pre$direction), style = "font-size: 130%;"), "WILL", icon = icon(a, lib = "glyphicon"),
      color = color_dir
    )
  })
  
  #data page
  output$data <- DT::renderDataTable({covid_index%>%
      DT::datatable(filter = "top")})
  
  #help page
  output$help_text <- renderText({
    text = paste("<p><h3>HOW TO USE THE APP:</h3></p>
                 <p><h4>HOME PAGE:</h4></p>
                 <p>You can move the mouse and place it on the world map in the upper right part to see the top three search interests of various countries in the epidemic situation.</p>
                 <p>In the lower part, you can see the changes of daily new cases in different countries, as well as the descriptions and links of major events affecting new cases.</p>
                 <p><h4>CLUSTER PAGE:</h4></p>
                 <p>You can choose a country to observe the proportion of new cases in the country's total population and judge the severity of the epidemic in that country.</p>
                 <p>And you can find the policy details of this country corresponding to this keyword by selecting the hot search keyword.</p>
                 <p><h4>MODEL PAGE:</h4></p>
                 <p>You can use the new case prediction model to predict the number and trend of new cases in the next week by selecting the country and date.</p>
                 <br />
                 <p><h3>For more information, please visit:</h3></p>
                 <p><a href='https://ourworldindata.org/coronavirus'>Our World in Data - Coronavirus Pandemic (COVID-19)</a></p>
                 <p><a href='https://covid19.who.int/'>WHO Coronavirus (COVID-19) Dashboard</a></p>
                 <br />
                 <p><h3>Special Thanks:</h3></p>
                 <p>Search trend data provided by <a href='https://trends.google.com/trends/'>Google Trends</a>.</p>
                 <p>Global COVID-19 data provided by <a href='https://ourworldindata.org/'>Our World in Data</a></p>
                 <br />
                 <br />
                 <p><strong>PLEASE NOTE</strong>: This APP is only for people to understand the search interest and policy changes during COVID-19. The new case prediction model is only for reference. In case of doubt, the government policies and data shall prevail.</p>")
    text = HTML(text)
    text
  })
}

# Run the application
shinyApp(ui = ui, server = server)