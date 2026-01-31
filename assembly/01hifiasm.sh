#!/bin/bash

set -x
# 获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
start_time=$(date +"%Y-%m-%d %H:%M:%S")

# 01hifiasm组装contig级别基因组
# mkdir 1
/Data7/wanjie/software/hifiasm0.25/hifiasm \
    -o 1/a.asm \
    -t 150 \
    --dual-scaf --telo-m TTTAGGG --write-ec \
    --ont /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626/BC2025060144-ONT-ul-1samples-20250619-3159/1-1/1-1.pass.all.fq.gz
# # ##查看上一个命令返回状态是否为0
# if [ $? -eq 0 ];then
#     echo "hifiasm success"
# else
#     echo "hifiasm fail"
# fi

# #02转为fasta格式
# samplename=a
# awk '/^S/{print ">"$2;print $3}' ${samplename}.asm.bp.p_ctg.gfa > ${samplename}.contig.fa
# assembly-stats *contig.fa > contig.stats.txt
# seqkit fx2tab --length --name *contig.fa |sort -k2,2nr > contig.length.tsv

# mkdir 2copy
# /Data7/wanjie/software/hifiasm0.25/hifiasm \
#     -o 2copy/b.asm \
#     -t 150 \
#     --dual-scaf --telo-m TTTAGGG \
#     --hom-cov 19  \
#     --ont /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626/BC2025060222-ONT-ul-1samples-20250619-3158/2-2/2-2.pass.all.fq.gz
# # ##查看上一个命令返回状态是否为0
# if [ $? -eq 0 ];then
#     echo "hifiasm success"
# else
#     echo "hifiasm fail"
# fi

# #02转为fasta格式
# samplename=b
# awk '/^S/{print ">"$2;print $3}' ${samplename}.asm.bp.p_ctg.gfa > ${samplename}.contig.fa
# assembly-stats *contig.fa > contig.stats.txt
# seqkit fx2tab --length --name *contig.fa |sort -k2,2nr > contig.length.tsv
# # ---------------------------------------------------------------------------------------------------------------
# 04 检测telomeric repeat
mkdir telomeric && cd telomeric
# 方法1
micromamba activate quarTeTdependencies
python /Data7/wanjie/software/quarTeT/quartet.py TeloExplorer -i ../b.contig.fa -c plant -m 50
# 方法2
micromamba activate genome_annotation
tidk search -s TTTAGGG  -o 2 -d . ../b.contig.fa
tidk plot -t 2_telomeric_repeat_windows.tsv -o 2
# 检测centromeric
python /Data7/wanjie/software/quarTeT/quartet.py CentroMiner -i ../HN48.asm.hic.p_ctg.gfa.fa -t 200 
# # ---------------------------------------------------------------------------------------------------------------

# 03 scaffolding
# cd 1
# # 先去除小于1Mb的序列再运行 ragtag
# awk '$2>1000000' contig.length.tsv |cut -f1 > forscaffold.id
# seqkit grep -f forscaffold.id *.contig.fa > forscaffold.fa
# ragtag.py scaffold /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/ZS11.genome.fa forscaffold.fa -t 200
# if [ $? -eq 0 ];then
#     echo "contig.fa success"
# else
#     echo "contig.fa fail"
# fi
# cd ..

cd 2copy
# 先去除小于1Mb的序列再运行 ragtag
awk '$2>1000000' contig.length.tsv |cut -f1 > forscaffold.id
seqkit grep -f forscaffold.id *.contig.fa > forscaffold.fa
ragtag.py scaffold /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/WE.genome.fa forscaffold.fa -t 200
if [ $? -eq 0 ];then
    echo "contig.fa success"
else
    echo "contig.fa fail"
fi
cd ..
# assembly-stats ragtag.scaffold.fasta > scaffold.stats.txt
# seqkit fx2tab --length --name ragtag.scaffold.fasta |sort -k2,2nr > scaffold.length.tsv

# busco
busco \
    -i ragtag.scaffold.fasta \
    -c 200 \
    -o busco \
    -m geno \
    -l /Data7/wanjie/software/embryophyta_odb10 --offline

# 04 检测telomeric repeat
mkdir telomeric && cd telomeric
micromamba activate quarTeTdependencies
python /Data7/wanjie/software/quarTeT/quartet.py TeloExplorer -i ../ragtag.scaffold.fasta -c plant -m 50

micromamba activate genome_annotation
tidk search -s TTTAGGG  -o 2 -d . ../ragtag.scaffold.fasta
tidk plot -t 2_telomeric_repeat_windows.tsv -o 2
# 检测centromeric
# python /Data7/wanjie/software/quarTeT/quartet.py CentroMiner -i ../HN48.asm.hic.p_ctg.gfa.fa -t 200 


# 再次获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
end_time=$(date +"%Y-%m-%d %H:%M:%S")
# 打印开始时间和结束时间
echo "--------------------------------------------------"
echo "Script started at $start_time."
echo "Script finished at $end_time."
echo "--------------------------------------------------"
