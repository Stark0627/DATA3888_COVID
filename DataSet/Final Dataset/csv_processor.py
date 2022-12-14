# encoding:utf-8
import csv
import math
import os
import sys


def read(csv_file):
    '''
    read csv
    :param csv_file:
    :return:
    '''
    rows = []
    with open(csv_file, 'r') as c_file:
        reader = csv.reader(c_file)
        rows = [row for row in reader]
    return rows


def write(content, csv_file):
    '''
    write csv
    :param content:
    :param csv_file:
    :return:
    '''
    with open(csv_file, 'w') as c_file:
        writer = csv.writer(c_file)
        # 先写columns_name
        writer.writerow(content[0])
        # 写入多行用writerows
        writer.writerows(content[1:])


def process(content, file_name):
    '''
    Process data in CSV to conform to expected format (calculate variable growth rate)
    :param content:
    :param file_name:
    :return:
    '''
    # If there are already 6 columns, do not process the data
    if len(content[0]) >= 6:
        return
    # Change header
    header = content[0]
    header.append('new_cases_rate')
    six_row = file_name[5:len(file_name) - 4]
    six_row = six_row.lower() + '_rate'
    header.append(six_row)
    # print(header)
    # print(content[0])
    count = len(content)
    # Change first row
    row_one = content[1]

    if row_one[2] == '0.0' or row_one[2] == '0':
        row_one.append(0)
    else:
        row_one.append(1)
    if row_one[3] == '0.0' or row_one[3] == '0':
        row_one.append(0)
    else:
        row_one.append(1)

    current_country = content[1][0]

    for i in range(2, count):
        row = content[i]
        if current_country != row[0]:  # If you change countries, reset the initial ratio
            if row[2] == '0.0' or row[2] == '0':
                row.append(0)
            else:
                row.append(1)
            if row[3] == '0.0' or row[3] == '0':
                row.append(0)
            else:
                row.append(1)
            current_country = row[0]
            continue
        # add new_cases_rate column
        new_cases_last = float(content[i - 1][2])  # Value of last row
        row_two = float(row[2])
        if math.isclose(row_two, 0.0, rel_tol=0.1):
            row.append(0)
        else:
            if math.isclose(new_cases_last, 0, rel_tol=0.1):
                row.append(1)
            else:
                row.append('{:.2f}'.format(float(row[2]) / new_cases_last))
        search_index_last = float(content[i - 1][3])
        if math.isclose(float(row[3]), 0.0, rel_tol=0.1):
            row.append(0)
        else:
            if math.isclose(search_index_last, 0, rel_tol=0.1):
                row.append(1)
            else:
                row.append('{:.2f}'.format(float(row[3]) / search_index_last))


def process_csv(csv_file, target=''):
    original = read(csv_file_name)
    process(original, csv_file_name)

    if target == '':
        write(original, csv_file_name)
    else:
        write(original, target)


if __name__ == '__main__':

    if len(sys.argv) < 2:
        print('Need provide csv file name to process. \n Usage: \n  python csv_processor.py  finalFlight.csv \n Or '
              '\n python csv_processor.py  finalFlight.csv target_file.csv')

    else:
        csv_file_name = sys.argv[1]

        if sys.argv[2]:
            process_csv(csv_file_name, sys.argv[2])
        else:
            process_csv(csv_file_name)
