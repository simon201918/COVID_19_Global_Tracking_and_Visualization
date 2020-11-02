# Install the required packages if necessary

# install.packages("covid19.analytics")
# install.packages("rlist")
# install.packages("countrycode")
# install.packages("rnaturalearth")
# install.packages("rnaturalearthdata")
# install.packages('transformr')
# install.packages('rworldmap')

library(covid19.analytics)
library(ggplot2)
library(dplyr)
library(dbplyr)
library(tidyr)
library(lubridate)
library(gganimate)
library(gifski)
library(av)
library(gapminder)
library(rlist)
library(countrycode)
library(rnaturalearth)
library(rnaturalearthdata)
library(maps)
library(sf)
library(transformr)
library(tidyverse)
library(rworldmap)
library(scales)

# Data
# obtain time series data for "confirmed" cases
# confirmed <- covid19.data("ts-confirmed")
# deaths <- covid19.data("ts-deaths")
# recover <- covid19.data("ts-recovered")
all <- covid19.data("ts-ALL")

# 1.Data Cleaning - COVID Package
head(all)

# Match the countries with continent names
all$continent <- countrycode(sourcevar = all[, "Country.Region"],
                                origin = "country.name",
                                destination = "continent")

# Unpivot the "all" data, and call the unpivoted data "all_gather"
exclude_list = c('Province.State','Country.Region','Lat','Long','status','continent')
all_gather <- gather(all,date,number,-exclude_list)
head(all_gather)

  #1.1 Set Date
all_gather$date <- ymd(all_gather$date)

  #1.2 Introduce new variables
all_ts <- all_gather %>% 
  rename(country = Country.Region, state = Province.State) %>% 
  group_by(country, status)

head(all_ts)

  #1.3  Split data by status
    # 1.3.1 Confirmed
confirmed_ts <- all_ts %>% 
  filter(status == 'confirmed') %>% 
  rename(confirmed_state = number) %>% 
  
  # build up indicators at state level
  group_by(country,state) %>% 
  mutate(new_confirmed_state = confirmed_state - lag(confirmed_state)) %>% 
  mutate(growth_rate_confirmed_by_state = new_confirmed_state / lag(confirmed_state) * 100) %>%
  mutate(current_over_max_ratio_confirmed_by_state = new_confirmed_state / max(new_confirmed_state, na.rm=T) * 100) %>%
  
  group_by(date) %>% 
  mutate(world_total_confirmed = sum(confirmed_state)) %>% 
  mutate(percentage_of_world_total_confirmed_by_state = confirmed_state/world_total_confirmed *100) %>% 
  mutate(world_new_confirmed = sum(new_confirmed_state)) %>% 
  mutate(current_over_max_ratio_confirmed_by_world = world_new_confirmed / max(world_new_confirmed, na.rm=T) * 100) %>%
  mutate(percentage_of_world_new_confirmed_by_state = new_confirmed_state/world_new_confirmed *100) %>%
  ungroup() %>%
  
  # build up indicators at conutry level
  group_by(country, date) %>% 
  mutate(confirmed_country = sum(confirmed_state)) %>% 
  ungroup() %>% 
  group_by(country, state) %>% 
  mutate(new_confirmed_country = confirmed_country - lag(confirmed_country)) %>% 
  mutate(growth_rate_confirmed_by_country = new_confirmed_country / lag(confirmed_country) * 100) %>% 
  mutate(current_over_max_ratio_confirmed_by_country = new_confirmed_country / max(new_confirmed_country, na.rm=T) * 100) %>%
  
  mutate(percentage_of_world_total_confirmed_by_country = confirmed_country/world_total_confirmed *100) %>% 
  mutate(percentage_of_world_new_confirmed_by_country = new_confirmed_country/world_new_confirmed *100) %>%
  ungroup() %>%
  # deal with NA, Inf, NaN
  mutate_at(-c(1:7), ~replace(., is.na(.), 0)) %>% 
  mutate_at(-c(1:7), ~replace(., is.infinite(.), 0.01)) %>% 
  mutate_at(-c(1:7), ~replace(., is.nan(.), 0))

# names(confirmed_ts)



    # 1.3.2 Death
death_ts <- all_ts %>% 
  filter(status == 'death') %>% 
  rename(death_state = number) %>% 
  
  # build up indicators at state level
  group_by(country,state) %>% 
  mutate(new_death_state = death_state - lag(death_state)) %>% 
  mutate(growth_rate_death_by_state = new_death_state / lag(death_state) * 100) %>%
  mutate(current_over_max_ratio_death_by_state = new_death_state / max(new_death_state, na.rm=T) * 100) %>%
  
  group_by(date) %>% 
  mutate(world_total_death = sum(death_state)) %>% 
  mutate(percentage_of_world_total_death_by_state = death_state/world_total_death *100) %>% 
  mutate(world_new_death = sum(new_death_state)) %>% 
  mutate(current_over_max_ratio_death_by_world = world_new_death / max(world_new_death, na.rm=T) * 100) %>%
  mutate(percentage_of_world_new_death_by_state = new_death_state/world_new_death *100) %>%
  ungroup() %>%
  
  # build up indicators at conutry level
  group_by(country, date) %>% 
  mutate(death_country = sum(death_state)) %>% 
  ungroup() %>% 
  group_by(country, state) %>% 
  mutate(new_death_country = death_country - lag(death_country)) %>% 
  mutate(growth_rate_death_by_country = new_death_country / lag(death_country) * 100) %>% 
  mutate(current_over_max_ratio_death_by_country = new_death_country / max(new_death_country, na.rm=T) * 100) %>%
  
  mutate(percentage_of_world_total_death_by_country = death_country/world_total_death *100) %>% 
  mutate(percentage_of_world_new_death_by_country = new_death_country/world_new_death *100) %>%
  ungroup() %>%
  # deal with NA, Inf, NaN
  mutate_at(-c(1:7), ~replace(., is.na(.), 0)) %>% 
  mutate_at(-c(1:7), ~replace(., is.infinite(.), 0.01)) %>% 
  mutate_at(-c(1:7), ~replace(., is.nan(.), 0))

    
    
    #1.3.3 Recovered
recovered_ts <- all_ts %>% 
  filter(status == 'recovered') %>% 
  rename(recovered_state = number) %>% 
  
  # build up indicators at state level
  group_by(country,state) %>% 
  mutate(new_recovered_state = recovered_state - lag(recovered_state)) %>% 
  mutate(growth_rate_recovered_by_state = new_recovered_state / lag(recovered_state) * 100) %>%
  mutate(current_over_max_ratio_recovered_by_state = new_recovered_state / max(new_recovered_state, na.rm=T) * 100) %>%
  
  group_by(date) %>% 
  mutate(world_total_recovered = sum(recovered_state)) %>% 
  mutate(percentage_of_world_total_recovered_by_state = recovered_state/world_total_recovered *100) %>% 
  mutate(world_new_recovered = sum(new_recovered_state)) %>% 
  mutate(current_over_max_ratio_recovered_by_world = world_new_recovered / max(world_new_recovered, na.rm=T) * 100) %>%
  mutate(percentage_of_world_new_recovered_by_state = new_recovered_state/world_new_recovered *100) %>%
  ungroup() %>%
  
  # build up indicators at conutry level
  group_by(country, date) %>% 
  mutate(recovered_country = sum(recovered_state)) %>% 
  ungroup() %>% 
  group_by(country, state) %>% 
  mutate(new_recovered_country = recovered_country - lag(recovered_country)) %>% 
  mutate(growth_rate_recovered_by_country = new_recovered_country / lag(recovered_country) * 100) %>% 
  mutate(current_over_max_ratio_recovered_by_country = new_recovered_country / max(new_recovered_country, na.rm=T) * 100) %>%
  
  mutate(percentage_of_world_total_recovered_by_country = recovered_country/world_total_recovered *100) %>% 
  mutate(percentage_of_world_new_recovered_by_country = new_recovered_country/world_new_recovered *100) %>%
  ungroup() %>%
  # deal with NA, Inf, NaN
  mutate_at(-c(1:7), ~replace(., is.na(.), 0)) %>% 
  mutate_at(-c(1:7), ~replace(., is.infinite(.), 0.01)) %>% 
  mutate_at(-c(1:7), ~replace(., is.nan(.), 0))


#summary(recovered_ts$current_over_max_ratio_recovered_by_country)
#summary(max(recovered_ts$world_new_recovered, rm.na=T))
#hist(recovered_ts$current_over_max_ratio_recovered_by_world)
#plot(recovered_ts$date,recovered_ts$current_over_max_ratio_recovered_by_country)


# 1.4 Merge the data into one dataframe (combine "confirmd", "death" and "recovered")
combine_list = c("state","country","Lat" ,"Long","date","continent")
merge_1 <- merge(confirmed_ts, death_ts, by=combine_list)
covid_country_and_state <- merge(merge_1, recovered_ts, by=combine_list)

names(covid_country_and_state)

# 1.5 Summarize the data at country level and drop state information
covid_country <- covid_country_and_state %>% 
  select(-contains('state'))
covid_country <- unique(covid_country)



# 2. Answer key questions about COVID-19

# Question 1: Time trend for different countries (US, China, Italy), focus on confirmed cases
covid_country_and_state_selected <- covid_country_and_state %>% 
  filter(country == 'Italy' | country == 'China'|country == 'US') %>% 
  select(-contains('state'))
covid_country_and_state_selected_country <- unique(covid_country_and_state_selected)

# names(covid_country_and_state_selected_country)

# Making plots

q1_1_country_confirmed <- covid_country_and_state_selected_country %>% 
  ggplot(aes(x = date, y = new_confirmed_country, col = country))+
  geom_line()+
  ggtitle('Q1-1 Daily Confirmed Cases By Country')+
  theme(plot.title = element_text(hjust = 0.5))+
  ylab('Daily Confirmed Cases')+
  xlab('Month')+
  facet_grid(. ~ country)
  
q1_1_country_confirmed



q1_2_country_confirmed <- covid_country_and_state_selected_country %>% 
  ggplot(aes(x = date, y = percentage_of_world_new_confirmed_by_country, col = country))+
  geom_line()+
  ggtitle('Q1-2 Percentage of World New Confirmed By Country')+
  theme(plot.title = element_text(hjust = 0.5))+
  ylab('Percentage of World New Confirmed')+
  xlab('Month')+
  facet_grid(. ~ country)

q1_2_country_confirmed 


q1_3_country_confirmed <- covid_country_and_state_selected_country %>% 
  ggplot(aes(x = date, y = percentage_of_world_total_confirmed_by_country, col = country))+
  geom_line()+
  ggtitle('Q1-3 Percentage of World Total Confirmed By Country')+
  theme(plot.title = element_text(hjust = 0.5))+
  ylab('Percentage of World Total Confirmed')+
  xlab('Month')+
  facet_grid(. ~ country)

q1_3_country_confirmed 


q1_4_country_confirmed <- covid_country_and_state_selected_country %>% 
  ggplot(aes(x = date, y = current_over_max_ratio_confirmed_by_country, col = country))+
  geom_line()+
  ggtitle('Q1-4 Current-Over-Max Ratio Confirmed by Country')+
  theme(plot.title = element_text(hjust = 0.5))+
  ylab('Current-Over-Max Ratio Confirmed by Country')+
  xlab('Month')+
  facet_grid(. ~ country)

q1_4_country_confirmed 




# Summarize the data at continent level
continent_data <- covid_country %>% 
  group_by(date, continent) %>% 
  mutate(continent_total_confirmed = sum(confirmed_country),
         continent_total_death = sum(death_country),
         continent_total_recovered = sum(recovered_country),
         continent_new_confirmed = sum(new_confirmed_country),
         continent_new_death = sum(new_death_country),
         continent_new_recovered = sum(new_recovered_country)) %>% 
  select(date,continent,continent_total_confirmed, continent_new_confirmed,
         continent_total_death, continent_new_death,
         continent_total_recovered, continent_new_recovered) %>% 
  unique()

# head(continent_data)

continent_data_gathered <- continent_data %>%
  gather(key = 'kind', value = 'value', -date, -continent)

continent_data_gathered_total <- continent_data_gathered %>%
  filter(kind == "continent_total_confirmed" | 
           kind == "continent_total_death"| 
           kind == "continent_total_recovered")


continent_total_plot <- continent_data_gathered_total %>% 
  ggplot(aes(x=date, y=log(value), col=kind))+
  geom_line()+
  scale_y_continuous(labels = comma)+
  theme(plot.title = element_text(hjust = 0.5))+
  xlab('Month')+
  ylab('Count in Log Value')+
  ggtitle('Q1-5 Continent Accumulative Plot')+
  facet_wrap(vars(continent),nrow = 2)

continent_total_plot


continent_data_gathered_new <- continent_data_gathered %>%
  filter(kind == "continent_new_confirmed" | 
           kind == "continent_new_death"| 
           kind == "continent_new_recovered")

continent_new_plot <- continent_data_gathered_new %>% 
  ggplot(aes(x=date, y=log(value), col=kind))+
  geom_line()+
  scale_y_continuous(labels = comma)+
  theme(plot.title = element_text(hjust = 0.5))+
  xlab('Month')+
  ylab('Count in Log Value')+
  ggtitle('Q1-6 Continent New Plot')+
  facet_wrap(vars(continent),nrow = 2)

continent_new_plot

   
# Question 2: Trend & Pattern
   # 2-1
   
   q2_1_country_confirmed <- covid_country %>% 
     ggplot(aes(x = current_over_max_ratio_confirmed_by_country, 
                y = log(new_confirmed_country), 
                size = confirmed_country, col = country))+
     geom_point(show.legend = F, alpha = 0.7)+
     ggtitle('Q5-1 Current-Over-Max Ratio Confirmed by Country')+
     theme(plot.title = element_text(hjust = 0.5))+
     ylab('New Confirmed by Country in Log Value')+
     xlab('Current-Over-Max Ratio Confirmed by Country')+
     xlim(0,100)+
     transition_time(date) +
     shadow_wake(wake_length = 0.3, alpha = FALSE)+
     labs(title = 'Date: {frame_time}')+
     facet_wrap(.~continent)
   
   animate(q2_1_country_confirmed, fps=8)
   anim_save("Q2_1 Current-Over-Max Ratio Confirmed by Country.gif")
   
   
   
   
   
   q2_2_country_confirmed <- covid_country %>% 
     ggplot(aes(x = current_over_max_ratio_confirmed_by_country, 
                y = current_over_max_ratio_death_by_country, 
                size = confirmed_country, col = country))+
     geom_point(show.legend = F, alpha = 0.7)+
     ggtitle('Q2_2 Current-Over-Max Ratio Confirmed by Country')+
     theme(plot.title = element_text(hjust = 0.5))+
     ylab('Current-Over-Max Ratio Death by Country')+
     xlab('Current-Over-Max Ratio Confirmed by Country')+
     ylim(0,100)+
     xlim(0,100)+
     transition_time(date) +
     shadow_wake(wake_length = 0.3, alpha = FALSE)+
     labs(title = 'Date: {frame_time}')+
     facet_wrap(.~continent)
   
   animate(q2_2_country_confirmed, fps=8)
   anim_save("Q2_2 Current-Over-Max Ratio Confirmed by Country.gif")
   
   
   
   
   
   q2_3_country_confirmed <- covid_country %>% 
     ggplot(aes(x = log(new_confirmed_country), 
                y = log(new_death_country), 
                size = confirmed_country, col = country))+
     geom_point(show.legend = F, alpha = 0.7)+
     theme(plot.title = element_text(hjust = 0.5))+
     xlab('New Confirmed by Country in Log Value')+
     ylab('New Death by Country in Log Value')+
     geom_abline(intercept = 0, slope = 1, col='red')+
     transition_time(date) +
     shadow_wake(wake_length = 0.3, alpha = FALSE)+
     labs(title = 'Date: {frame_time}')+
     facet_wrap(.~continent)
   
   animate(q2_3_country_confirmed, fps=8)
   anim_save("Q2_3 New Confirm_Death.gif")
   
   
   
   q2_4_country_confirmed <- covid_country %>% 
     ggplot(aes(x = log(confirmed_country), 
                y = log(death_country), 
                size = confirmed_country, col = country))+
     geom_point(show.legend = F, alpha = 0.7)+
     theme(plot.title = element_text(hjust = 0.5))+
     xlab('Total Confirmed by Country in Log Value')+
     ylab('Total Death by Country in Log Value')+
     geom_abline(intercept = 0, slope = 1, col='red')+
     transition_time(date) +
     shadow_wake(wake_length = 0.3, alpha = FALSE)+
     labs(title = 'Date: {frame_time}')+
     facet_wrap(.~continent)
   
   animate(q2_4_country_confirmed, fps=8)
   anim_save("Q2_4 Total Confirm_Death.gif")
   
   
   
   # Q2_5 World Data
   names(covid_country)
   
   world_data <- covid_country %>% 
     select(date,world_total_confirmed, world_new_confirmed,
            world_total_death, world_new_death,
            world_total_recovered, world_new_recovered) %>% 
     unique()
    

    
     world_data_gathered <- world_data %>%
       gather(key = 'kind', value = 'value', -date)
    
     world_data_gathered_total <- world_data_gathered %>%
       filter(kind == "world_total_confirmed" | 
                kind == "world_total_death"| 
                kind == "world_total_recovered")
       
     
     world_total_plot <- world_data_gathered_total %>% 
       ggplot(aes(x=date, y=value, col=kind))+
       geom_line(lwd=1)+
       scale_y_continuous(labels = comma)+
       theme(plot.title = element_text(hjust = 0.5))+
       xlab('Month')+
       ylab('Count')+
       ggtitle('Q2-5 World Accumulative Plot')
    
     
     world_data_gathered_new <- world_data_gathered %>%
       filter(kind == "world_new_confirmed" | 
                kind == "world_new_death"| 
                kind == "world_new_recovered")
    
     world_new_plot <- world_data_gathered_new %>% 
       ggplot(aes(x=date, y=value, col=kind))+
       geom_line(lwd=1)+
       scale_y_continuous(labels = comma)+
       theme(plot.title = element_text(hjust = 0.5))+
       xlab('Month')+
       ylab('Count')+
       ggtitle('Q2-6 World New Plot')
  
  

     
# 3. Export the data and use Tablau to visualize in map (See "Country Dynamic Visulization.twb")
  
  
     #library(gapminder)
     #head(gapminder)
     gapminder_duplicate <- gapminder %>% 
       select(country, continent) %>% 
       unique()
     write.csv(covid_country,"covid_country.csv", row.names = FALSE)
     
     
     
     


