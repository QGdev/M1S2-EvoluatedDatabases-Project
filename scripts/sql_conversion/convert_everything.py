#!/usr/bin/env python3

import csv
import sys
import re
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
#       Give 4 parameters
#
#       - The first one is the location of csv file of
#           population dataset.
#
#       - The second one is the location of csv file of
#           HDI/GNI/CO² dataset.
#
#       - The thrid one is the location of the folder
#           where SQL files will be strored
#
#       - The forth, it is corresponding to the limit of
#           lines present in resulting SQL files, it is
#           the maximum number of lines in one SQL file.
#           Not providing a limit, will cause the creation
#           of one huge file
#               in our case: 100000
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
#   -----Country1------Year1------05_9------Women------10002
#   \            \          \         \
#    \            \          \         \
#     \            \          \         \
#      \            Year2...   Total...  Men...
#       \
#        Country2------Year1
#
def process_pop_data(data_in: list[list]):
    data = {}
    countries = dict()
    years = set()

    genders = set()
    ages = set()

    for row in data_in:
        #   Reject age categories that we didn't want and work on the next row
        age = row[4]
        if(not(re.search("SHARE|OAD|TOTD|YD", str(age), re.IGNORECASE))):
            if(re.search("^[0][0-9]_[0-9]{1,2}$", age)):
                tmp = age.split("_")
                age =  "{}_{}".format(int(tmp[0]), int(tmp[1]))
           
            #   If country is not registered, register it
            country = row[0]

            if(data.get(country) is None):
                data[country] = {}
                
                #   Store the country in the dict for later
                countries[row[0]] = row[1]

            #   If the year isn't registered, register it
            year = int(row[6])

            if(data[country].get(year) is None):
                data[country][year] = {"POP": {}}
                
                #   Store the year in the set for later
                years.add(year)

            
            #   If the age category isn't registered, register it
            if(data[country][year]["POP"].get(age) is None):
                data[country][year]["POP"][age] = {}
                
                #   Store the age category in the set for later
                ages.add(age)

            #   If the gender isn't registered, register it
            gender = row[2]
            if(data[country][year]["POP"][age].get(gender) is None):
                #   Just drop the decimal part where it is not needed but sometimes present (POL/M/TOTAL/2000)                
                data[country][year]["POP"][age][gender] = int(row[8].split(".")[0])
                genders.add(gender)

    return data, countries, years, ages, genders


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
#   -----Country1-----------HDI------Year1 : NULL
#   \            \             \
#    \            \             \
#     \            \             \
#      \            GNI           Year2 : 0.534
#       \
#        Country2------HDI
#

def process_hdi_gni_co2_data(data_in: list[list], categories: dict, data_types: dict):
    data = {}
    countries = dict()
    years = set()

    for row in data_in:
        #   If country is not registered, register it
        if(data.get(row[0]) is None):
            data[row[0]] = {}
            countries[row[0]] = row[1]

        #   Take each categories
        for category in categories.keys():
            data[row[0]][category] = {}

            #   Take each year of the current category
            for year in categories[category].keys():
                tmp = row[categories[category][year]]
                years.add(int(year))

                #   Convert each values in the proper type
                if(type(tmp) is str):
                    if(tmp == ""):
                        data[row[0]][category][year] = None
                    else:
                        match data_types[category]:
                            case "float":
                                data[row[0]][category][year] = float(tmp)
                            case "int":
                                data[row[0]][category][year] = int(tmp)
                            case _:
                                data[row[0]][category][year] = str(tmp)
                else:
                    data[row[0]][category][year] = tmp
    return data, countries, years


#   Will build an empty tree like a kd-tree
#
#   -----Country1------Year1------GNI : None
#   \            \          \
#    \            \          \
#     \            \          \
#      \            Year2...   HDI : None  
#       \
#        Country2------Year1
#
def build_empty_tree(countries: dict, years: set, ages: set, genders: set) -> dict:
    
    tree = dict()

    for country in countries:
        tree[country] = dict()

        for year in years:
            tree[country][year] = dict()
            tree[country][year]["HDI"] = None
            tree[country][year]["GNI"] = None 
            tree[country][year]["GNI_F"] = None 
            tree[country][year]["GNI_M"] = None 
            tree[country][year]["CO2"] = None
            tree[country][year]["POP"] = dict()

            for age in ages:
                tree[country][year]["POP"][age] = dict()

                for gender in genders:
                    tree[country][year]["POP"][age][gender] = None
    
    return tree


#   Will fill the data tree with population data from the dataset
def fill_tree_with_pop_data(tree_to_fill: dict, data_tree: dict) -> dict:
    for country in data_tree.keys():
        for year in data_tree[country].keys():
            for age in data_tree[country][year].keys():
                for gender in data_tree[country][year][age].keys():
                    tree_to_fill[country][year][age][gender] = data_tree[country][year][age][gender]


    return tree_to_fill


#   Will fill the data tree with HDI/GNI/CO² data from the dataset
def fill_tree_with_hdi_gni_co2_data(tree_to_fill: dict, data_tree: dict) -> dict:
    for country in data_tree.keys():
        for type in data_tree[country].keys():
            for year in data_tree[country][type].keys():
                tree_to_fill[country][year][type] = data_tree[country][type][year]


    return tree_to_fill


#   Will create SQL Insert files for facts table
def build_sql_facts(file_path: str, data_tree: dict, ages: list):
    insert_request_to_format = "INSERT INTO FACTS VALUES ('{}', {}, {}, {}, {}, {}, {});\n"

    current_file_number = 0
    nb_lines_written_in_file = 0

    file = open(file_path.format(current_file_number), "w")

    def write_request(_country: str, _year: int, _hdi: float|None, _gni: float|None, _co2: float|None, _pop: int|None, _age_id: int):
        nonlocal file
        nonlocal current_file_number
        nonlocal nb_lines_written_in_file

        if(_hdi is None):
            _hdi = "NULL"

        if(_gni is None):
            _gni = "NULL"

        if(_co2 is None):
            _co2 = "NULL"

        if(_pop is None):
            _pop = "NULL"
        
        file.write(str(insert_request_to_format).format(_country, _year, _hdi, _gni, _co2, _age_id, _pop))
        nb_lines_written_in_file+=1

        if(nb_lines_written_in_file >= nb_lines_per_files):
            file.close()
            current_file_number += 1
            nb_lines_written_in_file = 0
            file = open(file_path.format(current_file_number), "w")
            
    #   Scan each ends of the provided tree
    for country in data_tree.keys():  
        for year in data_tree[country].keys():
            for age in data_tree[country][year]["POP"].keys():
                write_request(country,
                              year,
                              data_tree[country][year]["HDI"],
                              data_tree[country][year]["GNI"],
                              data_tree[country][year]["CO2"],
                              data_tree[country][year]["POP"][age]["T"],
                              ages[age])                
    file.close()


#   Will create SQL Insert files for countries table
def build_sql_countries(file_path: str, countries: dict):
    insert_request_to_format = "INSERT INTO COUNTRY VALUES ('{}', '{}');\n"

    current_file_number = 0
    nb_lines_written_in_file = 0

    file = open(file_path.format(current_file_number), "w")

    def write_request(country_code: str, country_name: str):
        nonlocal file
        nonlocal current_file_number
        nonlocal nb_lines_written_in_file
        
        file.write(str(insert_request_to_format).format(country_code, country_name))
        nb_lines_written_in_file+=1

        if(nb_lines_written_in_file >= nb_lines_per_files):
            file.close()
            current_file_number += 1
            nb_lines_written_in_file = 0
            file = open(file_path.format(current_file_number), "w")
            
    #   Scan each ends of the provided tree
    for country_code in countries.keys():  
        write_request(country_code, countries[country_code])      
    file.close()


#   Will create SQL Insert files for age_groups table
def build_sql_age_groups(file_path: str, age_groups: list):
    insert_request_to_format = "INSERT INTO AGE_GROUPS VALUES ({}, '{}');\n"

    current_file_number = 0
    nb_lines_written_in_file = 0

    file = open(file_path.format(current_file_number), "w")

    def write_request(age_id: int, age_name: str):
        nonlocal file
        nonlocal current_file_number
        nonlocal nb_lines_written_in_file
        
        file.write(str(insert_request_to_format).format(age_id, age_name))
        nb_lines_written_in_file+=1

        if(nb_lines_written_in_file >= nb_lines_per_files):
            file.close()
            current_file_number += 1
            nb_lines_written_in_file = 0
            file = open(file_path.format(current_file_number), "w")
            
    #   Scan each ends of the provided tree
    for age in age_groups.keys():
        if(re.search("^[0-9]{1,2}_[0-9]{1,2}$", age)):
            write_request(age_groups[age], age.replace("_", " - "))
        else:
            write_request(age_groups[age], age.replace("-", " - "))
    file.close()



if __name__ == '__main__':
    if(len(sys.argv) < 5):
        raise Exception("Not enought parameters")
    if(len(sys.argv) > 5):
        raise Exception("Too many parameters")

    csv_pop_path = str(sys.argv[1])
    csv_hdi_gni_co2_path = str(sys.argv[2])
    sql_folder_path = str(sys.argv[3])

    nb_lines_per_files = int(sys.argv[4])
    if(nb_lines_per_files < 1):
        raise Exception("Size limit cannot be null or negative !")
    #   Just to avoid potential catastrophic errors
    if(nb_lines_per_files < 1000):
        print("\n\033[93m WARNING : The size limit is set to {} ! \033[0m".format(nb_lines_per_files))
        if(input("Type \"yes\" to continue or anything else to abort : ") != "yes"):
            exit()

    print("\n")

    file_pop = get_file(csv_pop_path)
    file_hdi_gni_co2 = get_file(csv_hdi_gni_co2_path)
    if not (file_pop.readable() or file_hdi_gni_co2.readable()):
        raise IOError("File isn't readable !")

    pop_data = None
    hdi_gni_co2_data = None


    #   Work on population dataset
    print("Open & process csv of Population dataset")
    csv_pop_data = open_csv_file(file_pop)
    pop_data, countries_pop_data, years_pop_data, ages_pop_data, genders_pop_data = process_pop_data(csv_pop_data[1::])


    #   Work on HDI GNI CO² Emissions dataset
    print("Open & process csv of HDI/GNI/CO² dataset")
    csv_hdi_gni_co2_data = open_csv_file(file_hdi_gni_co2)
    categories = process_header_line(csv_hdi_gni_co2_data[0], 
                                    {"HDI": "^(Human Development Index) \([0-9]{4}\)", 
                                    "GNI": "^(Gross National Income Per Capita) \([0-9]{4}\)",
                                    "GNI_F": "^(Gross National Income Per Capita, female) \([0-9]{4}\)",
                                    "GNI_M": "^(Gross National Income Per Capita, male) \([0-9]{4}\)",
                                    "CO2": "^(Carbon dioxide emissions per capita \(production\) \(tonnes\)) \([0-9]{4}\)"})
    hdi_gni_co2_data, countries_hdi_gni_co2_data, years_hdi_gni_co2_data = process_hdi_gni_co2_data(csv_hdi_gni_co2_data[1::], categories, {"HDI": "float", "GNI": "float", "GNI_F": "float", "GNI_M": "float", "CO2": "float"})

    print("Creation of the empty tree")
    tree = build_empty_tree(countries_pop_data | countries_hdi_gni_co2_data,
                            years_pop_data | years_hdi_gni_co2_data,
                            ages_pop_data, genders_pop_data)
    
    print("Fill the tree with HDI/GNI/CO² dataset")
    tree = fill_tree_with_hdi_gni_co2_data(tree, hdi_gni_co2_data)

    print("Fill the tree with Population dataset")
    tree = fill_tree_with_pop_data(tree, pop_data)

    age_tmp = list(ages_pop_data)
    age_tmp.sort()
    age_ids = {age_tmp[i] : i for i in range(len(age_tmp))}

    print("Building SQL files")

    build_sql_facts(sql_folder_path + "/INS_FACTS_DATA_{}.sql", tree, age_ids)
    build_sql_countries(sql_folder_path + "/INS_COUNTRIES_DATA_{}.sql", countries_pop_data | countries_hdi_gni_co2_data)
    build_sql_age_groups(sql_folder_path + "/INS_AGE_GROUPS_DATA_{}.sql", age_ids)

    print("Cleanning memory")
    
    del csv_hdi_gni_co2_data
    del csv_hdi_gni_co2_path
    del csv_pop_data
    del csv_pop_path
    del tree

    print("\nDone")