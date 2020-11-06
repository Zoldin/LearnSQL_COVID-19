#################
library(reshape)
library(stringr)
library(dplyr)


#first you need to download csv file from John hopkins and then run this code: 
#wget https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv
#wget https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv
#wget https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv

library(plotly)
library(dplyr)
library(reshape)
library(stringr)
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
confirmed_melted$variable <-gsub("X","",confirmed_melted$variable)
dates <- data.frame(do.call(rbind, strsplit(confirmed_melted$variable, "\\.")))
confirmed_melted <- cbind(confirmed_melted,dates)
colnames(confirmed_melted)[5] <- "month"
colnames(confirmed_melted)[6] <- "day"
colnames(confirmed_melted)[7] <- "year"
confirmed_melted$day<-str_pad(gsub("\\.","",confirmed_melted$day),2,pad="0")
confirmed_melted$month<-str_pad(gsub("\\.","",confirmed_melted$month),2,pad="0")
confirmed_melted$year  <-paste0('20',confirmed_melted$year)
confirmed_melted$date<- paste0(confirmed_melted$month,'/', confirmed_melted$day,'/',confirmed_melted$year)
confirmed_melted$date<- as.Date(confirmed_melted$date,format = "%m/%d/%Y")
confirmed_melted$variable<-NULL
confirmed_melted$day<-NULL
confirmed_melted$month<-NULL
confirmed_melted$year<-NULL
colnames(confirmed_melted)[3]<-"confirmed"


recovered_melted <- melt(recovered, id=c("Country.Region","Province.State")) 
recovered_melted$variable <-gsub("X","",recovered_melted$variable)
dates <- data.frame(do.call(rbind, strsplit(recovered_melted$variable, "\\.")))
recovered_melted <- cbind(recovered_melted,dates)
colnames(recovered_melted)[5] <- "month"
colnames(recovered_melted)[6] <- "day"
colnames(recovered_melted)[7] <- "year"
recovered_melted$day<-str_pad(gsub("\\.","",recovered_melted$day),2,pad="0")
recovered_melted$month<-str_pad(gsub("\\.","",recovered_melted$month),2,pad="0")
recovered_melted$year  <-paste0('20',recovered_melted$year)
recovered_melted$date<- paste0(recovered_melted$month,'/', recovered_melted$day,'/',recovered_melted$year)
recovered_melted$date<- as.Date(recovered_melted$date,format = "%m/%d/%Y")
recovered_melted$variable<-NULL
recovered_melted$day<-NULL
recovered_melted$month<-NULL
recovered_melted$year<-NULL
colnames(recovered_melted)[3]<-"recovered"


deaths_melted <- melt(deaths, id=c("Country.Region","Province.State")) 
deaths_melted$variable <-gsub("X","",deaths_melted$variable)
dates <- data.frame(do.call(rbind, strsplit(deaths_melted$variable, "\\.")))
deaths_melted <- cbind(deaths_melted,dates)
colnames(deaths_melted)[5] <- "month"
colnames(deaths_melted)[6] <- "day"
colnames(deaths_melted)[7] <- "year"
deaths_melted$day<-str_pad(gsub("\\.","",deaths_melted$day),2,pad="0")
deaths_melted$month<-str_pad(gsub("\\.","",deaths_melted$month),2,pad="0")
deaths_melted$year  <-paste0('20',deaths_melted$year)
deaths_melted$date<- paste0(deaths_melted$month,'/', deaths_melted$day,'/',deaths_melted$year)
deaths_melted$date<- as.Date(deaths_melted$date,format = "%m/%d/%Y")
deaths_melted$variable<-NULL
deaths_melted$day<-NULL
deaths_melted$month<-NULL
deaths_melted$year<-NULL
colnames(deaths_melted)[3]<-"deaths"


confirmed_melted2 <- confirmed_melted %>% group_by(Country.Region,Province.State) %>% arrange(date) %>% mutate(confirmed_day = confirmed - lag(confirmed, default = first(confirmed)))
deaths_melted2 <- deaths_melted %>% group_by(Country.Region,Province.State) %>% arrange(date) %>% mutate(deaths_day = deaths - lag(deaths, default = first(deaths)))
recovered_melted2 <- recovered_melted %>% group_by(Country.Region,Province.State) %>% arrange(date) %>% mutate(recovered_day = recovered - lag(recovered, default = first(recovered)))

colnames(confirmed_melted2)[1]<-c("country")
colnames(deaths_melted2)[1]<-c("country")
colnames(recovered_melted2)[1]<-c("country")
colnames(confirmed_melted2)[2]<-"province_state"
colnames(deaths_melted2)[2]<-c("province_state")
colnames(recovered_melted2)[2]<-c("province_state")


data.frame(deaths_melted2[deaths_melted2$country=="Croatia",])

library(RMySQL)
con <- dbConnect(RMySQL::MySQL(), dbname = "test")

dbWriteTable(con, "confirmed_covid2", confirmed_melted2, row.names=FALSE,append=TRUE)
dbWriteTable(con, "deaths_covid2", deaths_melted2, row.names=FALSE,append=TRUE)
dbWriteTable(con, "recovered_covid2", recovered_melted2, row.names=FALSE,append=TRUE)
