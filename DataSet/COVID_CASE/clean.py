import csv

is_first = True
world_data = []
# Choose which country you want data for
country_name = ["World", "Brazil", "Cuba", "France", "Germany", "India", "Iran", "Italy", "Mexico", "Poland", "Spain", "Turkey", "United States", "United Kingdom", "Australia", "Canada", "Singapore"]
country_name.sort()
filename = "owid-covid-data.csv"
for lines in open(filename):
    if is_first:
        is_first = False
    else:
        data = lines.strip().split(",")
        country = data[2]
        day = data[3]
        newCase = data[5]
        if country in country_name:
            world_data.append([country, day, newCase])

header = ["CountryName", "Date", "new_cases"]
# Write a new csv, called countryname_case.csv
csv_name = "Countries_cases.csv"
file = open(csv_name, "w")
writer = csv.writer(file)
writer.writerow(header)
for sublist in world_data:
    writer.writerow(sublist)
file.close()

