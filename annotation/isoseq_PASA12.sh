#!/bin/bash

set -x
# 获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
start_time=$(date +"%Y-%m-%d %H:%M:%S")

# ------------------------------------------------------------------------------------------------------------------------

# cd isoseq 
# echo "current dir: $PWD"
# cp ../../genome/1.final.fa.new.masked.softmask.fold60.fa ./
# zcat /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/data/ZH/isoseq3_rapeseed/isoseq3/zs11/zs11.polished.hq.fasta.gz |fold -w 100|sed "s/\//-/g"   > isoseq.fulltrans.fa
# singularity exec \
#     -B $PWD:$PWD pasapipeline.v2.5.3.simg /usr/local/src/PASApipeline/Launch_PASA_pipeline.pl \
#     -c sqlite.confs/alignAssembly.config -C -R \
#     --ALIGNER blat,gmap,minimap2 \
#     --CPU 100 \
#     -g 1.final.fa.new.masked.softmask.fold60.fa \
#     -t isoseq.fulltrans.fa


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

cd PASA/PASAupdate2/
echo "current dir: $PWD"

cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/genome/1.final.fa.new.masked.softmask.fold60.fa ./
cp ../PASAupdate1/sample_mydb_pasa.sqlite.gene_structures_post_PASA_updates.415167.gff3 ./PASA1.update.gff3

singularity exec \
    -B $PWD pasapipeline.v2.5.3.simg  /usr/local/src/PASApipeline/Launch_PASA_pipeline.pl  \
    -c sqlite.confs/annotCompare.config -A -L \
    --CPU 100 \
    -g 1.final.fa.new.masked.softmask.fold60.fa \
    --annots PASA1.update.gff3 \
    -t isoseq.fulltrans.fa

if [ $? -eq 0 ]; then
    echo "PASA2 update  success, ${i}"
else
    echo "PASA2 update failed, ${i}"
fi

cd ../../
echo "再次返回上级目录: $PWD"




# 再次获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
end_time=$(date +"%Y-%m-%d %H:%M:%S")

# 打印开始时间和结束时间
echo "--------------------------------------------------"
echo "Script started at $start_time."
echo "Script finished at $end_time."
