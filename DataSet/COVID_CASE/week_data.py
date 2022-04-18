import csv

is_first = True
week_data = []
# Record the first day of each week
initial_date = 0
# Sum the number of cases in a week
new_case_week = 0
# Record data per week. So i < 7
i = 0
filename = "world_case.csv"
for lines in open(filename):
    if is_first:
        is_first = False
    else:
        data = lines.strip().split(",")
        country = data[0]
        date = data[1]
        if i == 0:
            initial_date = date
        new_case_day = data[2]
        if i < 6:
            new_case_week += float(new_case_day)
            i += 1
        elif i == 6:
            new_case_week += float(new_case_day)
            week_data.append([country, initial_date, new_case_week])
            new_case_week = 0
            i = 0

header = ["Country", "Date", "new_case_weekly"]
file = open("weekly_world_case.csv", "w")
writer = csv.writer(file)
writer.writerow(header)
for sublist in week_data:
    writer.writerow(sublist)
file.close()