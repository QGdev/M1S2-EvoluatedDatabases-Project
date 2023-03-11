#!/usr/bin/env python3

import csv
import sys
import re
from io import TextIOWrapper

#
#   Advanced Databases Project
#
#   Converts CSV files into INSERTS SQL file(s)
#   for the CO2 emissions dataset from The World
#
#   Author: Quentin GOMES DOS REIS
#

#   How to use:
#       Give 3 parameters
#
#       - The first one is the location of the folder
#           which contains all csv files previously
#           processed by our bash scripts.
#               in our case: ./scripts/get_data_scripts/population_dataset/csv_processed
#
#       - The second one is the location of the folder
#           where the program will put SQL file(s)
#               in our case: ./sql_files
#
#       - The third is corresponding
#           to the limit of lines present in resulting
#           SQL files, it is the maximum number of lines
#           in one SQL file.
#           Not providing a limit, will cause the creation
#           of one huge file
#               in our case: 250000
#

#   Needed in order to get file easily
def get_file(file_path: str, encoding: str = "UTF-8") -> TextIOWrapper:
    return open(file_path, newline='', encoding=encoding)

#   Will return a 2D list from a csv file by unwrapping the csv iterator
def open_csv_file(file: TextIOWrapper) -> list[list]:
    csv_reader = csv.reader(file)
    return [*csv_reader]

#   Will scan the given csv header and depending on given rules 
#   will give columns where the wanted data is 
def process_header_line(head_line: list[str], columns_to_get: dict) -> dict:
    tmp = dict()

    for data_type in columns_to_get.keys():
        columns_found = dict()

        for i in range(len(head_line)):
            if(re.search(columns_to_get[data_type], head_line[i])):
                tmp_year = re.findall("[0-9]{4}", head_line[i])
                if(len(tmp_year) == 1):
                    columns_found[int(tmp_year[0])] = i

        tmp[data_type] = columns_found.copy()

    return tmp

#   Will build a tree to store each data with a tree like a kd-tree
#
#   -----Country1-----------CO2------Year1 : NULL
#   \                          \
#    \                          \
#     \                          \
#      \                          Year2 : 0.534
#       \
#        Country2------CO2...
#
def process_data(data_in: list[list], categories: dict, data_types: dict) -> dict:
    data = {}

    for row in data_in:
        #   If country is not registered, register it
        if(data.get(row[1]) is None):
            data[row[1]] = {}

        #   Take each categories
        for category in categories.keys():
            data[row[1]][category] = {}

            #   Take each year of the current category
            for year in categories[category].keys():
                tmp = row[categories[category][year]]

                #   Convert each values in the proper type
                if(type(tmp) is str):
                    if(tmp == ""):
                        data[row[1]][category][year] = None
                    else:
                        match data_types[category]:
                            case "float":
                                data[row[1]][category][year] = float(tmp)
                            case "int":
                                data[row[1]][category][year] = int(tmp)
                            case _:
                                data[row[1]][category][year] = str(tmp)
                else:
                    data[row[1]][category][year] = tmp
    return data


#   Will take the resulting tree and create files of lines limit
#   Each created files will have exactly the setted limit in it
#
#   WARNING: DON'T SET A SMALL NUMBER FOR THE LIMIT, WILL FILL YOUR STORAGE WITH A LOT OF FILES !
##   Will take the resulting tree and fill the provided file with sql INSERTS
def build_sql_co2_data(files_path: str, processed_data: dict, nb_lines_per_files: int = 250000) -> None:

    insert_request_to_format = "INSERT INTO co2_stats VALUES ('{}', {}, {});\n"

    current_file_number = 0
    nb_lines_written_in_file = 0

    file = open(files_path.format(current_file_number), "w")
            
    #   Scan each ends of the provided tree
    for country in processed_data.keys():        
        for year in processed_data[country]["CO2"].keys():
            
            value = processed_data[country]["CO2"][year]

            if (value is None):
                value = "NULL"

            file.write(str(insert_request_to_format).format(country, year, value))
            nb_lines_written_in_file+=1

            if(nb_lines_written_in_file >= nb_lines_per_files):
                file.close()
                current_file_number += 1
                nb_lines_written_in_file = 0
                file = open(files_path.format(current_file_number), "w")
    file.close()


if __name__ == '__main__':
    if(len(sys.argv) < 3):
        raise Exception("Not enought parameters")
    if(len(sys.argv) > 3):
        raise Exception("Too many parameters")

    csv_file_path = str(sys.argv[1])
    sql_folder_path = str(sys.argv[2])

    nb_lines_per_files = int(sys.argv[3])
    if(nb_lines_per_files < 1):
        raise Exception("Size limit cannot be null or negative !")
    #   Just to avoid potential catastrophic errors
    if(nb_lines_per_files < 1000):
        print("\n\033[93m WARNING : The size limit is set to {} ! \033[0m".format(nb_lines_per_files))
        if(input("Type \"yes\" to continue or anything else to abort : ") != "yes"):
            exit()

    print("\n")

    file = get_file(csv_file_path)
    if not (file.readable()):
                raise IOError("File isn't readable !")
    print("Deparsing csv file")

    csv_data = open_csv_file(file)
    print("Processing file")

    categories = process_header_line(csv_data[4], {"CO2": "^[0-9]{4}$"})

    data = process_data(csv_data[5::], categories, {"CO2": "float"})

    print("Building SQL files")

    build_sql_co2_data(sql_folder_path + "/INS_CO2_DATA_{}.sql", data, nb_lines_per_files)
    
    print("Cleanning memory")
    del csv_data
    del data

    print("\nDone")