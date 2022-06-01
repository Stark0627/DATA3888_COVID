import csv

def AVG(avg_list):
    return sum(avg_list)/len(avg_list)


is_first = True
week_data = []
# Record the first day of each week
initial_date = 0
# Sum the number of cases in a week
new_case_week = 0
# Sum the number of new death in a week
new_death_week = 0
# Sum the number of test in a week
new_test_week = 0
# Sum the number of vaccine in a week
new_vaccine_week = 0
# Calculate the number of positive rate in a week
positive_rate_week = []
# Record data per week. So i < 7
i = 0
initial_country = ""
filename = "Countries_cases.csv"
# The weekly value of the variable is computed
for lines in open(filename):
    if is_first:
        is_first = False
    else:
        data = lines.strip().split(",")
        country = data[0]
        date = data[1]
        if i == 0:
            initial_country = country
            initial_date = date
        new_case_day = data[2]
        newDeath_day = data[3]
        newTest_day = data[4]
        positiveRate_day = data[5]
        newVaccine_day = data[6]
        if new_case_day == "" or new_case_day is None:
            new_case_day = 0
        if country == initial_country:
            if i < 6:
                new_case_week += float(new_case_day)
                new_death_week += float(newDeath_day)
                new_test_week += float(newTest_day)
                new_vaccine_week += float(newVaccine_day)
                positive_rate_week.append(float(positiveRate_day))
                i += 1
            elif i == 6:
                new_case_week += float(new_case_day)
                new_death_week += float(newDeath_day)
                new_test_week += float(newTest_day)
                new_vaccine_week += float(newVaccine_day)
                positive_rate_week.append(float(positiveRate_day))
                avg_positive_rate = AVG(positive_rate_week)
                week_data.append([country, initial_date, new_case_week, new_death_week,new_test_week, avg_positive_rate, new_vaccine_week])
                new_case_week = 0
                new_death_week = 0
                new_test_week = 0
                new_vaccine_week = 0
                positive_rate_week = []
                i = 0
        else:
            avg_positive_rate = AVG(positive_rate_week)
            week_data.append([initial_country, initial_date, new_case_week, new_death_week,new_test_week, avg_positive_rate, new_vaccine_week])
            new_case_week = float(new_case_day)
            new_death_week = float(newDeath_day)
            new_test_week = float(newTest_day)
            new_vaccine_week = float(newVaccine_day)
            positive_rate_week = [float(positiveRate_day)]
            initial_date = date
            initial_country = country
            i = 1
avg_positive_rate = AVG(positive_rate_week)
week_data.append([initial_country, initial_date, new_case_week, new_death_week,new_test_week, avg_positive_rate, new_vaccine_week])

header = ["Country", "Date", "new_case_weekly", "new_death_weekly", "new_test_weekly", "positive_rate_weekly", "new_vaccine_weekly"]
file = open("Final Dataset/weekly_world_cases.csv", "w")
writer = csv.writer(file)
writer.writerow(header)
for sublist in week_data:
    writer.writerow(sublist)
file.close()