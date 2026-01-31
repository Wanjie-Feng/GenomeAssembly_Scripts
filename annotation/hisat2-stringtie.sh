#!/bin/bash

set -x
# 获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
start_time=$(date +"%Y-%m-%d %H:%M:%S")

# genomeFile=$1
# for i in A1_1 A2_1 A3_1 B12_1 B1_3 B17_2 C21_1 D2_2 F1_1 G19_3 J2_2
# do
#     echo "Starting processing $i..."
#     # 运行你的命令或脚本，这里只是示例
# 	hisat2 -p 60 --dta -x ../genome/1 \
#         --summary-file bam/${i}_summary.txt \
#         -1 /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/cleanRNAseq/zs11/${i}_R1.fastp.fq.gz \
#         -2 /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/cleanRNAseq/zs11/${i}_R2.fastp.fq.gz |samtools view \
#         -bS -| samtools sort -@ 60 -o bam/${i}.sorted.bam && \
#         samtools view -h -b -q 20 -F 260 -@ 60  bam/${i}.sorted.bam > bam/${i}.sorted.fiilter.bam && \
#         samtools index -@ 60 bam/${i}.sorted.fiilter.bam && echo "${i} is ok "

# done
# -----------------------------------------------------------------------------------------------------------------
# stringtie -p 60 -v -o stringtie/1.gtf bam/merge.sorted.bam
# if [ $? -eq 0 ]; then
#   echo "stringtie is ok"
# else
#   echo "stringtie is error"
# fi
# -----------------------------------------------------------------------------------------------------------------
# Transdecoder使用
###分析开始
# 从stringtie_merged.gtf中提取FASTA序列
cd stringtie/
gtf_genome_to_cdna_fasta.pl 1.gtf ../../genome/1.final.fa.new.masked.softmask.fa > transcripts.fasta  |tee 1.log
# 将stringtie_merged.gtf转成GFF3格式
gtf_to_alignment_gff3.pl 1.gtf > transcripts.gff3
# 预测开放阅读框
TransDecoder.LongOrfs -m 50 -t transcripts.fasta
# 使用diamond与Swissport数据库同源比对(非必须)，也可以使用hmmscan与pfam数据库比对
cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/Transcription/TransDecoder_blast_pfam
ln -s ../stringtie/transcripts.fasta.transdecoder_dir/ .
nohup bash t.sh > t.log &

# 预测编码区
cd ../stringtie/
TransDecoder.Predict \
    -t transcripts.fasta \
    --retain_pfam_hits ../TransDecoder_blast_pfam/pfam.domtblout \
    --retain_blastp_hits ../TransDecoder_blast_pfam/blastp.outfmt6
# 把预测的编码区和基因组对应起来
cdna_alignment_orf_to_genome_orf.pl \
    transcripts.fasta.transdecoder.gff3 \
    transcripts.gff3 \
    transcripts.fasta > transcripts.fasta.transdecoder.genome.gff3


# 再次获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
end_time=$(date +"%Y-%m-%d %H:%M:%S")

# 打印开始时间和结束时间
echo "--------------------------------------------------"
echo "Script started at $start_time."
echo "Script finished at $end_time."
