import csv
import datetime


# Used to calculate the number of days between two dates
def diffDate(day1, day2):
    d1 = datetime.datetime.strptime(day1, "%Y-%m-%d")
    d2 = datetime.datetime.strptime(day2, "%Y-%m-%d")
    diff = d1 - d2
    if str(diff) == "0:00:00":
        return 0
    else:
        diff_day = str(diff).split(",")[0].split(" ")[0]
        return int(diff_day)


# Fill 0 into blank date data. It will be filled from January 26, 2020
def fillDate(diff, country, world_data):
    new_case = 0
    newDeath = 0
    newTest = 0
    positiveRate = 0
    newVaccine = 0
    addDay = datetime.timedelta(days=1)
    first_date = datetime.datetime.strptime("2020-01-26", "%Y-%m-%d")
    for i in range(diff):
        new_date = str(first_date).split(",")[0].split(" ")[0]
        world_data.append([country, new_date, new_case, newDeath, newTest, positiveRate, newVaccine])
        first_date = first_date + addDay


# Check if it is the first line of the file
is_first = True
# Used to store data in files
world_data = []
# Choose which country you want data for
country_name = ["World", "Brazil", "Thailand", "France", "Germany", "India", "Qatar", "Italy", "Netherlands", "Belgium",
                "Spain", "Turkey", "United States", "United Kingdom", "Australia", "Canada", "Singapore", "Vietnam",
                "Hong Kong", "Russia", "Switzerland", "Japan", "South Korea", "Saudi Arabia",
                "United Arab Emirates", "Israel"]
country_name.sort()
filename = "owid-covid-data.csv"
# Clean up data, change None data and "" to 0
for lines in open(filename):
    if is_first:
        is_first = False
    else:
        data = lines.strip().split(",")
        country = data[2]
        day = data[3]
        newCase = data[5]
        newDeath = data[8]
        if newDeath == "" or newDeath is None:
            newDeath = 0
        newTest = data[30]
        if newTest == "" or newTest is None:
            newTest = 0
        positiveRate = data[31]
        if positiveRate == "" or positiveRate is None:
            positiveRate = 0
        newVaccine = data[38]
        if newVaccine == "" or positiveRate is None:
            newVaccine = 0
        if country in country_name:
            if day == "2022-04-15":
                continue
            else:
                if country == "Hong Kong":
                    country = "China HongKong"
                world_data.append([country, day, newCase, newDeath, newTest, positiveRate, newVaccine])
header = ["CountryName", "Date", "new_cases", "new_death", "new_test", "positive_rate", "new_Vaccine"]
# Write a new csv, called countryname_case.csv
csv_name = "Countries_cases.csv"
file = open(csv_name, "w")
writer = csv.writer(file)
writer.writerow(header)
for sublist in world_data:
    writer.writerow(sublist)
file.close()

# use to fill in the date, starting from 2020-01-26
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
                newDeath = data[3]
                newTest = data[4]
                positiveRate = data[5]
                newVaccine = data[6]
                world_data.append([country, day, newCase, newDeath, newTest, positiveRate, newVaccine])
            else:
                fillDate(diff, country, world_data)
                newCase = data[2]
                newDeath = data[3]
                newTest = data[4]
                positiveRate = data[5]
                newVaccine = data[6]
                world_data.append([country, day, newCase, newDeath, newTest, positiveRate, newVaccine])
            is_add = False
        else:
            newCase = data[2]
            newDeath = data[3]
            newTest = data[4]
            positiveRate = data[5]
            newVaccine = data[6]
            world_data.append([country, day, newCase, newDeath, newTest, positiveRate, newVaccine])
        if day == "2022-04-14":
            is_add = True

file = open(csv_name, "w")
writer = csv.writer(file)
writer.writerow(header)
for sublist in world_data:
    writer.writerow(sublist)
file.close()
