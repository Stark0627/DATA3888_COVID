# DATA3888
## Dataset

Our data comes from these two sites:

Google Search Index: https://trends.google.com/trends/explore?geo=US&q=COVID (Filtered trends in searches for "COVID.)

COVID-19 dataset: https://github.com/owid/covid-19-data/tree/master/public/data

Since we don't need global data at the moment (considering not all countries use Google, we chose 17 countries for analysis, and more countries may be added later), I used Python code to clean up the data.

I am going to describe the contents of each file and folder below:

- **DataSet/COVID_CASE/owid-covid-data.csv** : The global COVID-19 data set was downloaded directly from GitHub
- **DataSet/COVID_CASE/clean.py**: Python code to select 17 countries from the original data set with only three columns (country name, date, new_case).
- **DataSet/COVID_CASE/Countries_cases.csv**: Data processed by clean.py has 17 countries and 3 columns of data
- **DataSet/COVID_CASE/week_data.py**: Take new_case data for 17 countries weekly. Because the original data is recorded daily new_case changes. We want to explore weekly data. So the data needs to be grouped into seven-day groups. And we also processed the empty data.
- **DataSet/COVID_CASE/weekly_world_cases.csv**: Data processed by week_data.py
- **DataSet/COVID_CASE/GoogleSearch_Origin/**: It includes data from 16 countries and around the world downloaded directly from Google's search site. There are 17 CSV files and 1 Python file
- **DataSet/COVID_CASE/GoogleSearch_Origin/clean_Google.py**: Clean up the original data, delete empty data, delete random characters. The new data is saved to Google_new_eachCountry
- **DataSet/COVID_CASE/Google_new_eachCountry/**: There are 17 cleaned CSV files and a Python file
- **DataSet/COVID_CASE/Google_new_eachCountry/merge.py**: Merge 17 CSV files into one CSV file and save it to DataSet/ COVID-19 CASE/AllCountries_Search.csv
- **DataSet/ COVID-19 CASE/AllCountries_Search.csv**: Google search index data processed by Python 

