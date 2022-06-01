import csv
is_first = True
world_data = []
# Choose which country you want data for
country_name = ["World", "Brazil", "Thailand", "France", "Germany", "India", "Qatar", "Italy", "Netherlands", "Belgium",
                "Spain", "Turkey", "United States", "United Kingdom", "Australia", "Canada", "Singapore", "Vietnam",
                "Hong Kong", "Russia", "Switzerland", "Japan", "South Korea", "Saudi Arabia",
                "United Arab Emirates", "Israel"]
country_name.sort()
# Get population variables for 25 countries in "owid-covid-data.csv"
filename = "owid-covid-data.csv"
for lines in open(filename):
    if is_first:
        is_first = False
    else:
        data = lines.strip().split(",")
        country = data[2]
        population = data[48]
        if country in country_name:
            if country == "Hong Kong":
                country = "China HongKong"
            add_list = [country, population]
            if add_list not in world_data:
                world_data.append(add_list)

all_data = []
is_first = True
filename = "Final Dataset/Final-COVID-Index.csv"
header = ""
# Calculate the proportion of new_case to population in each country
for lines in open(filename):
    if is_first:
        is_first = False
        header = lines.strip().split(",")
    else:
        row_data = []
        data = lines.strip().split(",")
        country = data[0]
        new_case = float(data[2])
        for name_population in world_data:
            if country == name_population[0]:
                new_case_percent = (new_case/float(name_population[1])) * 1000
                row_data = data
                row_data.append(new_case_percent)
        all_data.append(row_data)

csv_name = "../RMarkdown/Percent_COVID_Index.csv"
header.append("new_case_percentage")

file = open(csv_name, "w")
writer = csv.writer(file)
writer.writerow(header)
for sublist in all_data:
    writer.writerow(sublist)
file.close()