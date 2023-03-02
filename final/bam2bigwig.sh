x#!/bin/bash

input_dir="$1"
output_dir="$2"
extension=".bam"

# Create a name for the log file
log_file="$output_dir/log.txt"

# Create the log file
touch $log_file

# Open log file for writing
exec >> $log_file

# Redirect standard error to the same file
exec 2>&1

echo "Input directory: $input_dir"
echo "Output directory: $output_dir"

if [ ! -d "$output_dir" ]
then
  mkdir -m 777 $output_dir
  echo "Created directory: $output_dir"
else
  echo "$output_dir already exists"
fi

source $(dirname $(dirname $(which mamba)))/etc/profile.d/conda.sh
conda activate bam2bigwig

echo "Current Conda environment: $CONDA_DEFAULT_ENV"

if [ ! -d "temp" ]
then
  mkdir -m 777 "temp"
  echo "Created directory: temp"
else
  echo "temp already exists"
fi

for file in $input_dir/*.bam; do 
  temp_file=temp/$(basename $file)
  echo "Copy file to a temporary location ($temp_file)"
  cp $file $temp_file

  echo "Processing $file"
  samtools index $temp_file
  echo "Created index for $file"

  filename=$(basename $temp_file .bam)
  output_path="$output_dir/$filename.bw"
  echo "output_path: $output_path" 
  nice bamCoverage --bam $temp_file -o $output_path

  echo "Deleting index file, not needed anymore" 
  rm $temp_file.bai

done

# Echo final message and close log file
echo "Script complete."
exec >> /dev/null
