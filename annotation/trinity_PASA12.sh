#!/bin/bash

set -x
# 获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
start_time=$(date +"%Y-%m-%d %H:%M:%S")

# ------------------------------------------------------------------------------------------------------------------------
# (1)组装转录本
# cd trinity 
# echo "current dir: $PWD"
# cp ../bam/merge.sorted.bam ./
# singularity exec -B $PWD trinityrnaseq.v2.15.1.simg Trinity --genome_guided_bam ./merge.sorted.bam \
#     --max_memory 100G \
#     --genome_guided_max_intron 10000 \
#     --CPU 100 \
#     --output trinity_out_dir
# ##判断上一步退出状态是否等于0
# if [ $? -eq 0 ]; then
#     echo "Trinity success"
# else
#     echo "Trinity failed"
# fi
# cd ../
# echo "再次返回上级目录: $PWD"

# cd trinity 
# echo "current dir: $PWD"
# # cp ../../genome/1.final.fa.new.masked.softmask.fa ./
# singularity exec \
#     -B $PWD:$PWD pasapipeline.v2.5.3.simg /usr/local/src/PASApipeline/Launch_PASA_pipeline.pl \
#     -c sqlite.confs/alignAssembly.config -C -R \
#     --ALIGNER blat,gmap \
#     --CPU 100 \
#     -g 1.final.fa.new.masked.softmask.fa \
#     -t trinity_out_dir/Trinity-GG.fasta


# #判断上一步退出状态是否等于0
# if [ $? -eq 0 ]; then
#        echo "PASA align success"
# else
#        echo "PASA align failed"
# fi

# singularity exec \
#     -B $PWD:$PWD pasapipeline.v2.5.3.simg /usr/local/src/PASApipeline/scripts/pasa_asmbls_to_training_set.dbi \
#     --pasa_transcripts_fasta sample_mydb_pasa.sqlite.assemblies.fasta \
#     --pasa_transcripts_gff3 sample_mydb_pasa.sqlite.pasa_assemblies.gff3


# ##判断上一步退出状态是否等于0
# if [ $? -eq 0 ]; then
#         echo "PASA predict success"
# else
#         echo "PASA predict failed"
# fi

# cd ../
# echo "再次返回上级目录: $PWD"
# ------------------------------------------------------------------------------------------------------------------------
# # # (2)导入PASA流程进行更新注释

cd PASA/PASAupdate1/
echo "current dir: $PWD"

cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/genome/1.final.fa.new.masked.softmask.fold60.fa ./
cp ../../../EVMmerge/youcai3braker2.EVM.gff3 ./EVM.gff3

singularity exec \
    -B $PWD pasapipeline.v2.5.3.simg  /usr/local/src/PASApipeline/Launch_PASA_pipeline.pl  \
    -c sqlite.confs/annotCompare.config -A -L \
    --CPU 100 \
    -g 1.final.fa.new.masked.softmask.fold60.fa \
    --annots EVM.gff3 \
    -t trinity_out_dir/Trinity-GG.fasta

if [ $? -eq 0 ]; then
    echo "PASA1 update  success, ${i}"
else
    echo "PASA1 update failed, ${i}"
fi

cd ../../
echo "再次返回上级目录: $PWD"


# 再次获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
end_time=$(date +"%Y-%m-%d %H:%M:%S")

# 打印开始时间和结束时间
echo "--------------------------------------------------"
echo "Script started at $start_time."
echo "Script finished at $end_time."
