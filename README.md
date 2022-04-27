# DATA3888
## Dataset

Our data comes from these two sites:

Google Search Index: https://trends.google.com/trends/explore?geo=US&q=COVID (Filtered trends in searches for "COVID.)

COVID-19 dataset: https://github.com/owid/covid-19-data/tree/master/public/data

Since we don't need global data at the moment (considering not all countries use Google, we chose 17 countries for analysis, and more countries may be added later), I used Python code to clean up the data.

I am going to describe the contents of each file and folder below:

- **DataSet/owid-covid-data.csv** : The global COVID-19 data set was downloaded directly from GitHub

- **DataSet/clean.py**: Python code to select 17 countries from the original data set with only three columns (country name, date, new_case).

- **DataSet/Countries_cases.csv**: Data processed by clean.py has 17 countries and 3 columns of data

- **DataSet/week_data.py**: Take new_case data for 17 countries weekly. Because the original data is recorded daily new_case changes. We want to explore weekly data. So the data needs to be grouped into seven-day groups. And we also processed the empty data.

- **DataSet/Final Dataset/weekly_world_cases.csv**: Data processed by week_data.py

- **DataSet/clean_Google.py**: Clean up the original data, delete empty data, delete random characters. The new data is saved to Google_new_eachCountry. When you use 'python3 clean_Google.py', you should input directory name:

  - GoogleSearch_origin
  - Export
  - Immigration
  - Lockdown
  - Marriage
  - Mask
  - Medical_treatment
  - Social_distance
  - Vaccine
  - WFH
  - Flight

  Also, you need to enter output directory name:

  - Google_new_eachCountry
  - export_new
  - Immigration_new
  - Lockdown_new
  - marriage_new
  - Mask_new
  - medical_treatment_new
  - Social_distance_new
  - Vaccine_new
  - WFH_new
  - Flight_new

- **DataSet/merge.py**: Merge 17 CSV files into one CSV file and save it to DataSet/Final Dataset/AllCountries_Search.csv. When you use 'python3 merge.py', you should input directory name:

  - Google_new_eachCountry
  - export_new
  - Immigration_new
  - Lockdown_new
  - marriage_new
  - Mask_new
  - medical_treatment_new
  - Social_distance_new
  - Vaccine_new
  - WFH_new
  - Flight_new

  Also, you need to givt the output file a name.

- **DataSet/GoogleSearch_Origin/**: It includes data from 16 countries and around the world downloaded directly from Google's search site. There are 17 CSV files and 1 Python file

- **DataSet/Google_new_eachCountry/**: There are 17 cleaned CSV files and a Python file

- **DataSet/Final Dataset/AllCountries_Search.csv**: Google search index data processed by Python 

- **DataSet/Final Dataset/merge_both.py**: Merge all csv file into one

- **DataSet/Final Dataset/finalCOVIDSearch.csv**: All the data is stored in this CSV file

Other folders without ‘new’ in their names are all raw data downloaded from Google Trend. After clean_google.py, it is saved to the 'xxx_new' folder. The content of all CSV files in the same folder is consolidated into a CSV file with a name starting with "AllCountries" in the Final Dataset by merge.py

By using merge_both.py in the Final Dataset, the processed Google Trend file and weekly_world_cases.csv can be combined into a CSV to facilitate the subsequent model establishment.
