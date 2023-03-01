#!/usr/bin/env python3

import csv
from io import TextIOWrapper

#
#   Projet de Bases de données évoluées
#
#   Convertisseur CSV vers fichier insertion SQL pour
#   le dataset "avia_tf_ala_linear.csv"
#
#   Source des données: https://ec.europa.eu/eurostat/databrowser/view/AVIA_TF_ALA/default/table
#
#   Auteur: Quentin GOMES DOS REIS
#

def get_file(file_path: str, encoding: str = "ISO-8859-1") -> TextIOWrapper:
    return open(file_path, newline='', encoding=encoding)


def open_csv_file(file: TextIOWrapper) -> list[list]:
    csv_reader = csv.reader(file)
    return [*csv_reader]


def process_data(data_in: list[list], collected_values: list[dict]) -> dict:
    data = {}
    data_values = [i["name"] for i in collected_values]
    data_types = {i["name"]: i["type"] for i in collected_values}
    for row in data_in:
        if(row[2] == "A" and row[4] in data_values and row[5] == "TOTAL" and row[6] == "TOTAL"):
            #   If airport not registered, register it
            if(data.get(row[7]) is None):
                data[row[7]] = {}

            #   If the year isn't registered, register it
            if(data[row[7]].get(row[8]) is None):
                data[row[7]][row[8]] = {}

            if(data[row[7]][row[8]].get(row[4]) is None):
                match(data_types.get(row[4])):
                    case "int":
                        data[row[7]][row[8]][row[4]] = int(row[9])
                    case "float":
                        data[row[7]][row[8]][row[4]] = float(row[9])
                    case _:
                        raise Exception("Unknown data type")
    return data


def build_sql_airport_data(file: TextIOWrapper, processed_data: dict) -> TextIOWrapper:
    if not (file.writable()):
        raise Exception("Provided file isn't writable !")

    a2_to_a3 = {"AT": "AUT", "BE": "BEL", "BG": "BGR", "CH": "CHE", "CY": "CYP",
                "CZ": "CZE", "DE": "DEU", "DK": "DNK", "EE": "EST", "EL": "GRC",
                "ES": "ESP", "FI": "FIN", "FR": "FRA", "HR": "HRV", "HU": "HUN",
                "IE": "IRL", "IS": "ISL", "IT": "ITA", "LT": "LTU", "LU": "LUX",
                "LV": "LVA", "ME": "MNE", "MT": "MLT", "MK": "MKD", "MT": "MLT",
                "NL": "NLD", "NO": "NOR", "PL": "POL", "PT": "PRT", "RO": "ROU",
                "RS": "SRB", "SE": "SWE", "SI": "SVN", "SK": "SVK", "UK": "GBR",
                "TR": "TUR"}

    for x in processed_data.keys():
        airport_data = x.split("_")

        #   Change alpha 2 to alpha 3
        airport_data[0] = a2_to_a3[airport_data[0]]
        file.write("INSERT INTO airports VALUES (`{}`, `{}`);\n".format(*airport_data))
    
    return file


def build_sql_airport_stats(file: TextIOWrapper, processed_data: dict, collected_values: list[dict]) -> TextIOWrapper:
    if not (file.writable()):
        raise Exception("Provided file isn't writable !")

    data_formatting = ""

    for d in collected_values:
        data_formatting += "{} "
            
    data_formatting = data_formatting.replace("} {", "}, {")
    data_formatting = data_formatting.replace("} ", "}")

    insert_request_to_format = "INSERT INTO airports_stats VALUES (`{}`, {}, " + data_formatting + ");\n"

    for x in processed_data.keys():
        icao = x.split("_")[1]

        for y in processed_data[x].keys():

            collected_data = list()

            for d in collected_values:
                if(data[x][y].get(d["name"]) is None):
                    collected_data.append("NULL")
                else:
                    match(d["type"]):
                        case "int":
                            collected_data.append("{:d}".format(data[x][y].get(d["name"])))
                        case "float":
                            collected_data.append("{:.3f}".format(data[x][y].get(d["name"])))
                        case _:
                            raise Exception("Unknown data type")

            file.write(str(insert_request_to_format).format(icao, y, *collected_data))

    return file


selected_values = [{"name":"PAS_BRD", "type": "int"},
                   {"name":"PAS_CRD", "type": "int"},
                   {"name":"ST_PAS", "type": "int"}, 
                   {"name":"FRM_BRD", "type": "float"},
                   {"name":"FRM_LD_NLD", "type": "float"},
                   {"name":"CAF", "type": "int"},
                   {"name":"CAF_PAS", "type": "int"},
                   {"name":"CAF_FRM", "type": "int"}]

if __name__ == '__main__':
    csv_file_path = str(input("Enter the path to the CSV file\n\t --> "))
    sql_folder_path = str(input("Enter the path where sql files will be stored\n(Must to end with a / !)\n\t --> "))

    print("\n")

    file = get_file(csv_file_path)
    if not (file.readable()):
        raise Exception("Selected file isn't readable !")

    print("Deparsing csv file")
    csv_data = open_csv_file(file)

    print("Processing file")
    data = process_data(csv_data, selected_values)
    

    print("Building SQL files")

    build_sql_airport_data(open(sql_folder_path+"INS_AIRPORTS.sql", "w"), data).close()
    build_sql_airport_stats(open(sql_folder_path+"INS_STATS.sql", "w"), data, selected_values).close()

    print("Clean memory")
    del csv_data
    del data

    print("\nDone")