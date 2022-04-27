import csv

directory = input("Enter directory: ")
finalName = input("Give the output filename a name: ")
# Choose which country you want data for
country_names = ["World", "Brazil", "Cuba", "France", "Germany", "India", "Iran", "Italy", "Mexico", "Poland", "Spain", "Turkey", "United States", "United Kingdom", "Australia", "Canada", "Singapore"]
country_names.sort()
all_data = []
for name in country_names:
    filename = directory + "/" + name+"_Search.csv"
    is_first = True
    try:
        for lines in open(filename):
            if is_first:
                is_first = False
            else:
                data = lines.strip().split(",")
                country = data[0]
                date= data[1]
                google_search = data[2]
                all_data.append([country, date, google_search])
    except Exception:
        print(filename)
        continue

header = ["Country", "Date", "Search_Index"]
# Write a new csv for each country
csv_name = "Final Dataset/"+finalName+".csv"
file = open(csv_name, "w")
writer = csv.writer(file)
writer.writerow(header)
for sublist in all_data:
    writer.writerow(sublist)
file.close()
