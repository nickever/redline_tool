#!/usr/bin/env bash

#Tool to extract lens, accelerometer and gyro metadata from R3D files, and output to .csv files.
#Requires RedCineX to be installed. MacOSX only.
#usage: redmeta.sh <directory>
#Nick Everett 2018

#This tool uses the command line program 'REDline'. The following is from the --help:
#--i <filename>        - input file (required)
#--useMeta             - Use look metadata and frame guides in R3D as defaults (alt --useRMD)
#--printMeta <int>     - Print out metadata settings
                            # 0 = header,
                            # 1 = normal,
                            # 2 = csv,
                            # 3 = header + csv,
                            # 4 = 3D rig,
                            # 5 = per-frame lens + acc + gyro,
                            # 6 = per-frame external metadata

echo 'Welcome to the Redline automator tool. For a given directory path, it will recurrsively search for R3D files,
extract the lens, accelerometer and gyro metadata and output it to a csv in the same directory.'

if [[ $# -ne 1 ]]; then
    echo "Please supply a directory containing R3D files"
    exit
fi

#file path to folder containing R3Ds in subfolders
r3d_dir=$1

cd ${r3d_dir}

#create the array
declare -a file_list

#first create array of file paths for all files in dir and subdir
file_list=$(ls -R ${r3d_dir} | awk '/:$/&&f{s=$0;f=0}/:$/&&!f{sub(/:$/,"");s=$0;f=1;next}NF&&f{ print s"/"$0 }')

#list all found R3Ds and add them to array
echo 'Found:'
declare -a r3d_list
for f in ${file_list}; do
    if [[ $f =~ .R3D ]]; then
        r3d_list=("${r3d_list[@]}" "${f}")
        echo ${f}
    fi
done

#yes no to continue
read -p 'Extract metadata from these files? (y|n)' -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
else
    echo -e /n
fi

#extract metadata using redline
for r3d in ${r3d_list[@]}; do             #for items in the array
    if [[ $r3d =~ .R3D ]]; then       #if matches regex R3D
        echo $r3d
        REDline --i ${r3d} --useMeta --printMeta 5 > ${r3d%.*}.csv       #redline tool to extract metadata, '5' = gyro, pipe to csv file
    fi
done

