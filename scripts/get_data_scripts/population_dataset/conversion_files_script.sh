#!/bin/bash

#
#   Advanced Databases Project
#
#   Bash script used format and prepare population dataset
#	files downloaded after running the script "download_script.sh"
#	
#	Note: Make sure that the script "download_script.sh" have been
#			executed properly
#
#   Author: Quentin GOMES DOS REIS
#

mkdir csv_processed

# Find all directories with CSV files and loop over the results
find ./csv* -type d -name "[0-9]*" -print | while read dir; do

  find $dir -type f -name "*.csv" -print | while read file; do
	  echo "Found file: $file"
	  if grep -q '"footnoteSeqID","Footnote"' $file
	  then
		  #	Remove footnotes that aren't needed in our case
		  head -n $(($(grep -n '"footnoteSeqID","Footnote"' $file | head -n 1 | cut -d: -f1) - 2)) $file > "./csv_processed/$(basename "$dir").csv"
      else
        cp $file "./csv_processed/$(basename "$dir").csv"
      fi
  done
done
