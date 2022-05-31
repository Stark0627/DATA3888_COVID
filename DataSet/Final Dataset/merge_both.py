import csv

is_first_1 = True
is_first_2 = True
total_data = []
# You can change file name here
search_name = input("Enter File Name you want to merge: ")
Search_file = "AllCountries_"+search_name+".csv"
Covid_file = "weekly_world_cases.csv"
# Merges the new_cases with the specified Google Search Index csv file
for lines in open(Covid_file):
    if is_first_1:
        is_first_1 = False
    else:
        data = lines.strip().split(",")
        country = data[0]
        day = data[1]
        newCase = data[2]
        for search_lines in open(Search_file):
            if is_first_2:
                is_first_2 = False
            else:
                search_data = search_lines.strip().split(",")
                search_country = search_data[0]
                search_day = search_data[1]
                search_index = search_data[2]
                if country == search_country and day == search_day:
                    total_data.append([country, day, newCase, search_index])

header = ["CountryName", "Date", "new_cases", "Search Index"]
# Write a new csv, called countryname_case.csv
output_name = input("Enter Name you want to output: ")
csv_name = output_name+".csv"
file = open(csv_name, "w")
writer = csv.writer(file)
writer.writerow(header)
for sublist in total_data:
    writer.writerow(sublist)
file.close()
