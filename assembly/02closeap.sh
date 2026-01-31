#!/bin/bash

set -x
# 获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
start_time=$(date +"%Y-%m-%d %H:%M:%S")

# 1
cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/1/ragtag_output/closegap
# for i in ZS11_A01_RagTag ZS11_A02_RagTag ZS11_C07_RagTag ;do
#     echo "${i}" > ${i}.id
#     seqkit grep -f ${i}.id ../ragtag.scaffold.fasta > ${i}.fa
# done

for i in ZS11_C01_RagTag ;do
    echo "${i}" > ${i}.id
    seqkit grep -f ${i}.id ../ragtag.scaffold.fasta > ${i}.fa
done

# zcat /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626/BC2025060144-ONT-ul-1samples-20250619-3159/1-1/1-1.pass.all.fq.gz |sed -n '1~4s/^@/>/p;2~4p'  > ont.all.fa
tgsgapcloser  \
        --scaff ZS11_A01_RagTag.fa_part2.fa \
        --reads  /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/flye/1/flyeResult/assembly.fasta \
        --output ont_ne_A01 \
        --ne \
        --tgstype ont \
        --thread 100 \
        --min_nread 3  \
        >pipe_ont.log 2>pipe_ont.err

tgsgapcloser  \
        --scaff ZS11_C01_RagTag.fa_part2.fa \
        --reads  /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/flye/1/flyeResult/assembly.fasta \
        --output ont_ne_C01 \
        --ne \
        --tgstype ont \
        --thread 100 \
        --min_nread 3  \
        >pipe_ont.log 2>pipe_ont.err


tgsgapcloser  \
        --scaff 1.fa \
        --reads  ../ont.all.fa \
        --output ont_ne_A01 \
        --ne \
        --tgstype ont \
        --thread 100 \
        --min_nread 3  \
        >pipe_ont.log 2>pipe_ont.err

tgsgapcloser  \
        --scaff ../ont_ne_A01.scaff_seqs \
        --reads   /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/flye/1/flyeResult/assembly.fasta \
        --output ont_ne_A01 \
        --ne \
        --tgstype ont \
        --thread 100 \
        --min_nread 3  \
        >pipe_ont.log 2>pipe_ont.err





mkdir finalGenome
cut -f1 /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/1/ragtag_output/scaffold.length.tsv |sort > finalGenome/nogap.id
# 删除有gap的id
seqkit grep -f finalGenome/nogap.id ../ragtag.scaffold.fasta > finalGenome/nogap.fa

cd  A02
cat ZS11_A02_RagTag.fa_part1.fa >> final.A02.fa
seqkit seq ont_ne_A01.scaff_seqs -s >> final.A02.fa
seqkit seq ZS11_A02_RagTag.fa_part3.fa -s >> final.A02.fa
cp final.A02.fa /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/1/ragtag_output/closegap/finalGenome

cd A01
cat ZS11_A01_RagTag.fa_part1.fa >> final.A01.fa
seqkit seq ont_ne_A01.scaff_seqs -s >> final.A01.fa
seqkit seq ZS11_A01_RagTag.fa_part3.fa -s >> final.A01.fa
cp final.A01.fa /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/1/ragtag_output/closegap/finalGenome

cd C07/again
cat ont_ne_A01.scaff_seqs >> final.C07.fa
seqkit seq ../2.fa -s >> final.C07.fa
cp final.C07.fa /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/1/ragtag_output/closegap/finalGenome


cd C01
cat ZS11_C01_RagTag.fa_part1.fa >> final.C01.fa
seqkit seq ont_ne_C01.scaff_seqs -s >> final.C01.fa
seqkit seq ZS11_C01_RagTag.fa_part3.fa -s >> final.C01.fa
cp final.C01.fa /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/1/ragtag_output/closegap/finalGenome


cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/1/ragtag_output/closegap/finalGenome
cat nogap.fa final.*.fa |seqkit seq -w 60  > 1.final.fa

busco \
    -i 1.final.fa \
    -c 200 \
    -o busco \
    -m geno \
    -l /Data7/wanjie/software/embryophyta_odb10 --offline
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# 2copy
cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/2copy/ragtag_output/closegap
# zcat /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626/BC2025060222-ONT-ul-1samples-20250619-3158/2-2/2-2.pass.all.fq.gz |sed -n '1~4s/^@/>/p;2~4p'  > ont.all.fa 
for i in WE_A01_RagTag WE_A09_RagTag WE_C04_RagTag WE_C08_RagTag ;do
        mkdir  ${i}
        echo "${i}" > ${i}/${i}.id
        seqkit grep -f ${i}/${i}.id ../ragtag.scaffold.fasta > ${i}/${i}.fa
done

tgsgapcloser  \
        --scaff WE_C08_RagTag.fa_part2.fa \
        --reads  ../ont.all.fa \
        --output ont_ne_A01 \
        --ne \
        --tgstype ont \
        --thread 100 \
        --min_nread 5  \
        >pipe_ont.log 2>pipe_ont.err

mkdir finalGenome
cut   -f1 /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/2copy/ragtag_output/scaffold.length.tsv | sort >  finalGenome/nogap.id
# 删除有gap的id
seqkit grep -f finalGenome/nogap.id ../ragtag.scaffold.fasta > finalGenome/nogap.fa

cd  WE_A01_RagTag
cat WE_A01_RagTag.fa_part1.fa >> final.A01.fa
seqkit seq ont_ne_A01.scaff_seqs -s >> final.A01.fa
seqkit seq WE_A01_RagTag.fa_part3.fa -s >> final.A01.fa
cp final.A01.fa /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/2copy/ragtag_output/closegap/finalGenome/

cd WE_A09_RagTag
cat WE_A09_RagTag.fa_part1.fa >> final.A09.fa
seqkit seq ont_ne_A01.scaff_seqs -s >> final.A09.fa
seqkit seq WE_A09_RagTag.fa_part3.fa -s >> final.A09.fa
cp final.A09.fa /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/2copy/ragtag_output/closegap/finalGenome/

cd WE_C04_RagTag
cat WE_C04_RagTag.fa_part1.fa >> final.C04.fa
seqkit seq ont_ne_A01.scaff_seqs -s >> final.C04.fa
seqkit seq WE_C04_RagTag.fa_part3.fa -s >> final.C04.fa
cp final.C04.fa /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/2copy/ragtag_output/closegap/finalGenome/

cd WE_C08_RagTag
cat WE_C08_RagTag.fa_part1.fa >> final.C08.fa
seqkit seq ont_ne_A01.scaff_seqs -s >> final.C08.fa
seqkit seq WE_C08_RagTag.fa_part3.fa -s >> final.C08.fa
cp final.C08.fa /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/2copy/ragtag_output/closegap/finalGenome/

cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/2copy/ragtag_output/closegap/finalGenome
cat *fa > 2.final.fa
cat nogap.fa final.*.fa |seqkit seq -w 60  > 2.final.fa


busco \
    -i 2.final.fa \
    -c 200 \
    -o busco \
    -m geno \
    -l /Data7/wanjie/software/embryophyta_odb10 --offline
# 再次获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
end_time=$(date +"%Y-%m-%d %H:%M:%S")
# 打印开始时间和结束时间
echo "--------------------------------------------------"
echo "Script started at $start_time."
echo "Script finished at $end_time."
echo "--------------------------------------------------"

