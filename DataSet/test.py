import csv
directory = input("Enter directory: ")
filename = "Export/Australia.csv"
is_First = True
for lines in open(filename):
    if is_First:
        is_First = False
    else:
        print(lines)