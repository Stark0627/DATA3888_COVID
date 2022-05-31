import csv

directory = input("Enter directory: ")
output_dir = input("Enter output directory: ")
# Choose which country you want data for
country_names = ["World", "Brazil", "Thailand", "France", "Germany", "India", "Qatar", "Italy", "Netherlands",
                 "Belgium",
                 "Spain", "Turkey", "usa", "United Kingdom", "Australia", "Canada", "Singapore", "Vietnam",
                 "China HongKong", "Russia", "Switzerland", "Japan", "South Korea", "Saudi Arabia",
                 "United Arab Emirates", "Israel"]
country_names.sort()
# Clean Google Search Index file
for name in country_names:
    new_data = []
    filename = directory + "/" + name + ".csv"
    index = 0
    try:
        for lines in open(filename):
            # Ignore the first three lines of the CSV file
            if index < 3:
                index += 1
                continue
            else:
                data = lines.strip().split(",")
                date = data[0]
                covid_search = data[1]
                # if value is '<1', change it to 0
                if covid_search == "<1":
                    covid_search = 0
                else:
                    covid_search = float(covid_search)
                if name == "usa":
                    name = "United States"
                new_data.append([name, date, covid_search])

        header = ["Country", "Date", "search_index"]
        # Write a new csv for each country
        csv_name = output_dir + "/" + name + "_Search.csv"
        file = open(csv_name, "w")
        writer = csv.writer(file)
        writer.writerow(header)
        print(name, ": ", len(new_data))
        for sublist in new_data:
            writer.writerow(sublist)
        file.close()
    except IOError:
        print(filename)
        continue
    except Exception:
        print("Other exception")
