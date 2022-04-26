import csv
import datetime

def diffDate(day1, day2):
    d1 = datetime.datetime.strptime(day1, "%Y-%m-%d")
    d2 = datetime.datetime.strptime(day2, "%Y-%m-%d")
    diff = d1 - d2
    if str(diff) == "0:00:00":
        return 0
    else:
        diff_day = str(diff).split(",")[0].split(" ")[0]
        return int(diff_day)

def fillDate(diff, country, world_data):
    new_case = 0
    addDay = datetime.timedelta(days=1)
    first_date = datetime.datetime.strptime("2020-01-26", "%Y-%m-%d")
    for i in range(diff):
        new_date = str(first_date).split(",")[0].split(" ")[0]
        world_data.append([country, new_date, new_case])
        first_date = first_date + addDay


is_first = True
world_data = []
# Choose which country you want data for
country_name = ["World", "Brazil", "Cuba", "France", "Germany", "India", "Iran", "Italy", "Mexico", "Poland", "Spain", "Turkey", "United States", "United Kingdom", "Australia", "Canada", "Singapore"]
# country_name = ["Turkey"]
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
            if day == "2022-04-15":
                continue
            else:
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

# use to fill in the date
is_add = True
is_first = True
initial_date = "2020-01-26"
world_data = []
for lines in open(csv_name):
    if is_first:
        is_first = False
    else:
        data = lines.strip().split(",")
        country = data[0]
        day = data[1]
        diff = diffDate(day, initial_date)
        if diff < 0:
            continue
        elif diff >= 0 and is_add:
            if diff == 0:
                newCase = data[2]
                world_data.append([country, day, newCase])
            else:
                fillDate(diff, country, world_data)
                newCase = data[2]
                world_data.append([country, day, newCase])
            is_add = False
        else:
            newCase = data[2]
            world_data.append([country, day, newCase])
        if day == "2022-04-14":
            is_add = True

file = open(csv_name, "w")
writer = csv.writer(file)
writer.writerow(header)
for sublist in world_data:
    writer.writerow(sublist)
file.close()