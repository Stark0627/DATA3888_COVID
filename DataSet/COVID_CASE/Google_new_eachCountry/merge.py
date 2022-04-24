import csv

# Choose which country you want data for
country_names = ["World", "Brazil", "Cuba", "France", "Germany", "India", "Iran", "Italy", "Mexico", "Poland", "Spain", "Turkey", "usa", "United Kingdom", "Australia", "Canada", "Singapore"]
country_names.sort()
all_data = []
for name in country_names:
    filename = name+"_Search.csv"
    is_first = True
    for lines in open(filename):
        if is_first:
            is_first = False
        else:
            data = lines.strip().split(",")
            country = data[0]
            if country == "usa":
                country = "United States"
            date= data[1]
            google_search = data[2]
            all_data.append([country, date, google_search])

header = ["Country", "Date", "Search_Index"]
# Write a new csv for each country
csv_name = "../AllCountries_Search.csv"
file = open(csv_name, "w")
writer = csv.writer(file)
writer.writerow(header)
for sublist in all_data:
    writer.writerow(sublist)
file.close()

