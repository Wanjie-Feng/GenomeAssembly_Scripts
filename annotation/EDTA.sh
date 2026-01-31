#!/bin/bash

set -x
# 获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
start_time=$(date +"%Y-%m-%d %H:%M:%S")

genomeFile=$1
docker run -v $PWD:/in -w /in quay.io/biocontainers/edta:2.2.2--hdfd78af_1 EDTA.pl --genome ${genomeFile} \
    --species others \
    --overwrite 0 \
    --sensitive 1 \
    --anno 1 \
    --evaluate 0 \
    --threads 100

if [ $? -eq 0 ];then
    echo "EDTA singularity success"
else
    echo "EDTA singularity fail"
fi

# 再次获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
end_time=$(date +"%Y-%m-%d %H:%M:%S")

# 打印开始时间和结束时间
echo "--------------------------------------------------"
echo "Script started at $start_time."
echo "Script finished at $end_time."
