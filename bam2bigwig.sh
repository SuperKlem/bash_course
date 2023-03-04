#!/bin/bash

input_dir="$1"
output_dir="$2"
extension=".bam"

if [ ! -d "$output_dir" ]
then
  mkdir $output_dir
  echo "Created directory: $output_dir"
else
  echo "$output_dir already exists"
fi

# Create a name for the log file
log_file="$output_dir/log.txt"

touch $log_file
echo "Creat log file" >> $log_file

source $(dirname $(dirname $(which mamba)))/etc/profile.d/conda.sh

# Create the environment if it does not yet exist
conda env list | grep bam2bigwig || conda create -n bam2bigwig samtools deeptools --yes

# Activate the environment
conda activate bam2bigwig

echo "Current Conda environment: $CONDA_DEFAULT_ENV" >> $log_file

if [ ! -d "temp" ]
then
  mkdir "temp"
  echo "Created directory: temp" >> $log_file
else
  echo "temp already exists" >> $log_file
fi

for file in $input_dir/*.bam; do 
  temp_file=temp/$(basename $file)
  echo "Copy file to a temporary location ($temp_file)" >> $log_file
  cp $file $temp_file

  echo "Processing $file" >> $log_file
  samtools index $temp_file
  echo "Created index for $file" >> $log_file

  filename=$(basename $temp_file .bam)
  output_path="$output_dir/$filename.bw"
  echo "output_path: $output_path"  >> $log_file
  #nice bamCoverage --bam $temp_file -o $output_path
  bamCoverage --version  # quickly check if deeptools is available
  touch $output_path  # fake the output

  echo "Deleting index file, not needed anymore"  >> $log_file
  rm $temp_file.bai

done

# Remove temporary file location
rm -rf temp

# Print name to terminal
echo "esiteur"
