#!/usr/bin/sh

# 获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
start_time=$(date +"%Y-%m-%d %H:%M:%S")


#run
# singularity exec -B $PWD:$PWD braker3.sif braker.pl \
# docker run \
#     --user 1000:100 --rm -v $PWD:$PWD  dockerpull.org/teambraker/braker3:latest braker.pl \


echo "current dir: $PWD"

# mkdir brakerresult
# chmod 777 brakerresult/

docker run \
    --user 1000:100 --rm -v $PWD:$PWD  dockerpull.org/teambraker/braker3:latest braker.pl \
    --gff3 \
    --workingdir=${PWD}/brakerresult/ \
    --threads 48 \
    --genome=${PWD}/1.final.fa.new.masked.softmask.fa \
    --prot_seq=${PWD}/proteins.fa \
    --bam=${PWD}/bam/merge.sorted.bam

##判断上一步的结束状态
if [ $? -eq 0 ]; then
    echo "###################################"
    echo "BRAKER pipeline finished successfully"
else
    echo "BRAKER pipeline failed"
fi



# 再次获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
end_time=$(date +"%Y-%m-%d %H:%M:%S")

# 打印开始时间和结束时间
echo "--------------------------------------------------"
echo "Script started at $start_time."
echo "Script finished at $end_time."
echo "--------------------------------------------------"
