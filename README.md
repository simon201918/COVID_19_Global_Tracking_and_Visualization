


## COVID-19 Global Tracking and Visualization
This project used R and Tableau to visualize COVID-19 global dynamic trends at **country** and **daily** basis. It also performs ratio analysis to study the peak and flow of the pandemic. 

- Language/Software: R & Tableau
- Source of Data: [covid19.analytics package](https://cran.r-project.org/web/packages/covid19.analytics/index.html)

## Ratios Defined
- **Current-Over-Max  Confirmed  Ratio:**
Current confirmed cases over historical high confirmed cases
Measures whether the country is reaching or deviate from its peak level of confirmed cases

- **Current-Over-Max  Death  Ratio:**
Current death cases over historical high death cases
Measures whether the country is reaching or deviate from its peak level of death cases

- **Current-Over-Max  Recovered  Ratio:**
Current recovered cases over historical high recovered cases
Measures the proportion of patients recovered. Note that a high Current  Over  Max  Recovered  Ratio does not necessarily indicate an improved situation. Higher previous confirmed cases may cause the high ratio.

## Demo
This project analyzes the COVID-19 from two aspects: **(a) country comparison** and **(b) global trend**. 

### (a) Country Pomparison
For the first section (country comparison), I selected three countries as an example: China, Italy, and the US. Users could easily switch to other countries - as long as that country data is included in the [covid19.analytics package](https://cran.r-project.org/web/packages/covid19.analytics/index.html).

![say sth](https://github.com/simon201918/COVID_19_Global_Tracking_and_Visualization/blob/main/Plots%20and%20Animations/Q1-1%20Daily%20Confirmed%20Cases%20By%20Country.jpeg?raw=true)

The charts in this section are intuitive to understand. For example, Plot Q1-1 summarizes the three selected countries' daily confirmed data from 01/22/2020 to 10/30/2020. From the plot, we can see that both Italy and the US experience a sharp increase during October 2020. Yet China's data remains at a very low level.

![say sth](https://github.com/simon201918/COVID_19_Global_Tracking_and_Visualization/blob/main/Plots%20and%20Animations/Q1-2%20Percentage%20of%20World%20New%20Confirmed%20By%20Country.jpeg?raw=true)

We can develop another useful insight by comparing Q1-1 with Q1-2 (Percentage of World New Confirmed By Country). Even though the US daily confirmed cases increases significantly during October, the relative percentage of US new patients compared with world new patients remains stable. This means that confirmed cases must increase dramatically in some other countries (Such as Italy). 

### (b) Global Trend
For the first section (global trend), I plotted countries data by **continent** and visualized the trend dynamically at daily basis. Each dot indicates a country, and the dot's size is determined by the **TOTAL** confirmed cases in that country.
![say sth](https://github.com/simon201918/COVID_19_Global_Tracking_and_Visualization/blob/main/Plots%20and%20Animations/Q2_1%20Current-Over-Max%20Ratio%20Confirmed%20by%20Country.gif?raw=true)

For example, the plot above compares the current-over-max confirmed ratio with the number of new confirmed cases (in log value). This plot measures the **stage** of CONVID-19 at each continent. If many countries are hitting the right boundary, that means the current-over-max confirmed ratio is high, and the country is reaching the peak of the pandemic (as is the case for European countries in October). Moreover, Oceania countries have experienced two complete cycles because they reach the right boundary two times and drop back to the origin.

Let's take a look at another example - **new confirmed cases against new confrimed death**.
![say sth](https://github.com/simon201918/COVID_19_Global_Tracking_and_Visualization/blob/main/Plots%20and%20Animations/Q2_3%20New%20Confirm_Death.gif?raw=true)

The red diagonal line is the **break-even line** where **daily new confirmed cases equal to daily new death**. The further the dots deviate from this red line to the southeast, the lower the fatality rates are. We can tell that at the beginning of the pandemic (before April 2020), many countries suffered from high fatality rates and hit the red line frequently. Some countries even crossed the red line and moved to the northwest direction, which means the countries had more death reported than new confirmed cases. Luckily, **even though the world is experiencing a second wave attack, the death toll is not as severe as the beginning of the pandemic because the dots are moving towards the southeast and deviate from the red line**.

The rest of the plots and animations could be interpreted similarly so I will not discuss them in deatils. You could also generate the most up-to-date plots using the R code I provided. 

**Finally, you may utilize Tableau to visualize the COVID-19 trend over time (with "Country Dynamic Visulization.twb").** 
