import csv

# Choose which country you want data for
country_names = ["World", "Brazil", "Cuba", "France", "Germany", "India", "Iran", "Italy", "Mexico", "Poland", "Spain", "Turkey", "usa", "United Kingdom", "Australia", "Canada", "Singapore"]
country_names.sort()
for name in country_names:
    new_data = []
    filename = name+".csv"
    index = 0
    for lines in open(filename):
        if index < 3:
            index += 1
            continue
        else:
            data = lines.strip().split(",")
            date = data[0]
            covid_search = data[1]
            if covid_search == "<1":
                covid_search = 0
            else:
                covid_search = float(covid_search)
            if name == "usa":
                name = "United States"
            new_data.append([name, date, covid_search])

    header = ["Country", "Date", "search_index"]
    # Write a new csv for each country
    csv_name = "../Google_new_eachCountry/"+name +"_Search.csv"
    file = open(csv_name, "w")
    writer = csv.writer(file)
    writer.writerow(header)
    for sublist in new_data:
        writer.writerow(sublist)
    file.close()

