#!/usr/bin/env python3

import csv
import sys
from io import TextIOWrapper
from country_names_to_a3 import country_to_a3

#
#   Advanced Databases Project
#
#   Converts CSV files into INSERTS SQL file(s)
#   for the population dataset from UNdata
#
#   Author: Quentin GOMES DOS REIS
#

#   How to use:
#       Give 4 or 5 parameters
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
#       - The third one is the start year, you need
#           to have a csv file that is corresponding
#           to it like 2000 -> 2000.csv exist
#               in our case: 1948
#
#       - The forth one is the last year, you need
#           to have a csv file that is corresponding
#           to it like 2000 -> 2000.csv exist
#               in our case: 2022
#
#       - The fifth is optionnal, it is corresponding
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

#   Will build a tree to store each data with a tree like a kd-tree
#
#   -----Country1------Year1------Urbain------Female------"0 - 5" : [Source Year, Value]
#   \            \          \           \           \
#    \            \          \           \           \
#     \            \          \           \           \
#      \            Year2...   Rural...    Male...     "6 - 10" : [Source Year, Value]
#       \
#        Country2------Year1
#
def process_data(data_in: list[list]) -> dict:
    data = {}

    for row in data_in:
        #   If country is not registered, register it
        if(data.get(row[1]) is None):
            data[row[1]] = {}

        #   If the year isn't registered, register it
        if(data[row[1]].get(row[2]) is None):
            data[row[1]][row[2]] = {}

        #   If the area isn't registerd, register it
        if(data[row[1]][row[2]].get(row[3]) is None):
            data[row[1]][row[2]][row[3]] = {}

        #   If the sex isn't registerd, register it
        if(data[row[1]][row[2]][row[3]].get(row[4]) is None):
            data[row[1]][row[2]][row[3]][row[4]] = {}

        #   If the age isn't registerd, register it
        if(data[row[1]][row[2]][row[3]][row[4]].get(row[5]) is None):
            data[row[1]][row[2]][row[3]][row[4]][row[5]] = [row[8], row[9]]

    return data

#   Will merge two trees
def merge_data(dict_a: dict, dict_b: dict) -> dict:
    data = dict_a.copy()

    for country in dict_b.keys():
        #   If country is not registered, register it
        if(data.get(country) is None):
            data[country] = dict_b.get(country).copy()
        
        #   The country is registered, need to merge the year
        else:
            for year in dict_b[country].keys():
                if(data[country].get(year) is None):
                    data[country][year] = dict_b[country].get(year).copy()
    return data

#   Will take the resulting tree and fill the provided file with sql INSERTS
def build_sql_pop_data(file: TextIOWrapper, processed_data: dict) -> TextIOWrapper:
    if not (file.writable()):
        raise Exception("Provided file isn't writable !")

    insert_request_to_format = "INSERT INTO population_stats VALUES ('{}', {}, '{}', '{}', '{}', {}, {});\n"

    #   Scan each ends of the provided tree
    for country in processed_data.keys():
        country_a3 = country_to_a3.get(country)
        if(country_a3 is None):
            raise Exception("Not able to find Alpha3 ISO for {}".format(country))

        for year in processed_data[country].keys():
            for area in processed_data[country][year].keys():
                for sex in processed_data[country][year][area].keys():
                    for age in processed_data[country][year][area][sex].keys():
                        file.write(str(insert_request_to_format).format(country_a3, year, area, sex, age, *(processed_data[country][year][area][sex][age])))
    return file

#   Will take the resulting tree and create files of lines limit
#   Each created files will have exactly the setted limit in it
#
#   WARNING: DON'T SET A SMALL NUMBER FOR THE LIMIT, WILL FILL YOUR STORAGE WITH A LOT OF FILES !
#
def build_sql_pop_data(files_path: str, processed_data: dict, nb_lines_per_files: int) -> None:

    insert_request_to_format = "INSERT INTO population_stats VALUES ('{}', {}, '{}', '{}', '{}', {}, {});\n"

    current_file_number = 0
    nb_lines_written_in_file = 0
    file = open(files_path.format(current_file_number), "w")


    #   Scan each ends of the provided tree
    for country in processed_data.keys():
        country_a3 = country_to_a3.get(country)
        if(country_a3 is None):
            raise Exception("Not able to find Alpha3 ISO for {}".format(country))
        
        for year in processed_data[country].keys():
            for area in processed_data[country][year].keys():
                for sex in processed_data[country][year][area].keys():
                    for age in processed_data[country][year][area][sex].keys():
                        file.write(str(insert_request_to_format).format(country_a3, year, area, sex, age, *(processed_data[country][year][area][sex][age])))
                        nb_lines_written_in_file+=1

                        if(nb_lines_written_in_file >= nb_lines_per_files):
                            file.close()
                            current_file_number += 1
                            nb_lines_written_in_file = 0
                            file = open(files_path.format(current_file_number), "w")
    file.close()


if __name__ == '__main__':
    if(len(sys.argv) < 5):
        raise Exception("Not enought parameters")
    if(len(sys.argv) > 7):
        raise Exception("Too many parameters")

    csv_folder_path = str(sys.argv[1])
    sql_folder_path = str(sys.argv[2])

    start_year = int(sys.argv[3])
    last_year = int(sys.argv[4])

    if(len(sys.argv) > 5):
        nb_lines_per_files = int(sys.argv[5])
        if(nb_lines_per_files < 1):
            raise Exception("Size limit cannot be null or negative !")
        #   Just to avoid potential catastrophic errors
        if(nb_lines_per_files < 1000):
            print("\n\033[93m WARNING : The size limit is set to {} ! \033[0m".format(nb_lines_per_files))
            if(input("Type \"yes\" to continue or anything else to abort : ") != "yes"):
                exit()
    else:
        nb_lines_per_files = None

    print("\n")

    last_data = None

    for year in range (start_year, last_year + 1):
        try:
            file = get_file("{}/{}.csv".format(csv_folder_path,str(year)))

            if not (file.readable()):
                raise IOError("File isn't readable !")

            print("{} - Deparsing csv file".format(year))
            csv_data = open_csv_file(file)

            print("{} - Processing file".format(year))
            data = process_data(csv_data[1::])

            if(last_data is None):
                last_data = data
            else:
                last_data = merge_data(last_data, data)

            
        except OSError as e:
            print("Unable to find csv file for {}".format(year))
            print(e)
        except IOError as e:
            print("Unable to access the csv file for {}".format(year))
            print(e)
        except Exception as e:
            print("Raised execption for {}".format(year))
            print(e)

    #   for x in last_data.keys():
    #       if(country_to_a3.get(x) is None):
    #           print(x)
    #   print("TEST")
    #   for x in country_to_a3.keys():
    #       if(last_data.get(x) is None):
    #           print(x)
    #   print(last_data)

    if(not(last_data is None) and len(last_data) > 0):
        print("Building SQL files")

        if(nb_lines_per_files is None):
            build_sql_pop_data(open(sql_folder_path+"/INS_POP_DATA.sql", "w"), last_data).close()
        else:
            build_sql_pop_data(sql_folder_path + "/INS_POP_DATA_{}.sql", last_data, nb_lines_per_files)

    print("Clean memory")
    del csv_data
    del data
    del last_data

    print("\nDone")