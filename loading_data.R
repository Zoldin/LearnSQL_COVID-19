#################
library(reshape)
library(stringr)
library(dplyr)


#first you need to download csv file from John hopkins and then run this code: 
#wget https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv
#wget https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv
#wget https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv

data_confirmed <- 'time_series_covid19_confirmed_global.csv'
data_deaths <- 'time_series_covid19_deaths_global.csv'
data_recovered <-'time_series_covid19_recovered_global.csv'

confirmed <- read.csv(data_confirmed,stringsAsFactors = FALSE)

confirmed$Lat<-NULL
confirmed$Long<-NULL


deaths <- read.csv(data_deaths,stringsAsFactors = FALSE)

deaths$Lat<-NULL
deaths$Long<-NULL


recovered <- read.csv(data_recovered,stringsAsFactors = FALSE)

recovered$Lat<-NULL
recovered$Long<-NULL





confirmed_melted <- melt(confirmed, id=c("Country.Region","Province.State")) 
confirmed_melted$variable <-gsub("X","0",confirmed_melted$variable)
confirmed_melted$day <- substr(confirmed_melted$variable,4,5)
confirmed_melted$month <- substr(confirmed_melted$variable,1,2)
confirmed_melted$day<-str_pad(gsub("\\.","",confirmed_melted$day),2,pad="0")
confirmed_melted$date<- paste0(confirmed_melted$day,'/', confirmed_melted$month,'/2020')
confirmed_melted$date <- as.Date(confirmed_melted$date,"%d/%m/%Y")
confirmed_melted$variable<-NULL
confirmed_melted$day<-NULL
confirmed_melted$month<-NULL
colnames(confirmed_melted)[3]<-"confirmed"

recovered_melted <- melt(recovered, id=c("Country.Region","Province.State")) 
recovered_melted$variable <-gsub("X","0",recovered_melted$variable)
recovered_melted$day <- substr(recovered_melted$variable,4,5)
recovered_melted$month <- substr(recovered_melted$variable,1,2)
recovered_melted$day<-str_pad(gsub("\\.","",recovered_melted$day),2,pad="0")
recovered_melted$date<- paste0(recovered_melted$day,'/', recovered_melted$month,'/2020')
recovered_melted$date <- as.Date(recovered_melted$date,"%d/%m/%Y")
recovered_melted$variable<-NULL
recovered_melted$day<-NULL
recovered_melted$month<-NULL
colnames(recovered_melted)[3]<-"recovered"

deaths_melted <- melt(deaths, id=c("Country.Region","Province.State")) 
deaths_melted$variable <-gsub("X","0",deaths_melted$variable)
deaths_melted$day <- substr(deaths_melted$variable,4,5)
deaths_melted$month <- substr(deaths_melted$variable,1,2)
deaths_melted$day<-str_pad(gsub("\\.","",deaths_melted$day),2,pad="0")
deaths_melted$date<- paste0(deaths_melted$day,'/', deaths_melted$month,'/2020')
deaths_melted$date <- as.Date(deaths_melted$date,"%d/%m/%Y")
deaths_melted$variable<-NULL
deaths_melted$day<-NULL
deaths_melted$month<-NULL
colnames(deaths_melted)[3]<-"deaths"



confirmed_melted2 <- confirmed_melted %>% group_by(Country.Region,Province.State) %>% arrange(date) %>% mutate(confirmed_day = confirmed - lag(confirmed, default = first(confirmed)))
deaths_melted2 <- deaths_melted %>% group_by(Country.Region,Province.State) %>% arrange(date) %>% mutate(deaths_day = deaths - lag(deaths, default = first(deaths)))
recovered_melted2 <- recovered_melted %>% group_by(Country.Region,Province.State) %>% arrange(date) %>% mutate(recovered_day = recovered - lag(recovered, default = first(recovered)))

colnames(confirmed_melted2)[1]<-c("country")
colnames(deaths_melted2)[1]<-c("country")
colnames(recovered_melted2)[1]<-c("country")

tail(deaths_melted2)

library(RMySQL)
con <- dbConnect(RMySQL::MySQL(), dbname = "test")

dbWriteTable(con, "confirmed_covid", confirmed_melted2, row.names=FALSE,append=TRUE)
dbWriteTable(con, "deaths_covid", deaths_melted2, row.names=FALSE,append=TRUE)
dbWriteTable(con, "recovered_covid", recovered_melted2, row.names=FALSE,append=TRUE)
