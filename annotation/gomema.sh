# 最终使用版本 xtlab
#!/bin/bash
set -x
##这个脚本是用来使用GeMoMa软件加10个物种的注释文件和二代RNAseq数据进行基因组同源比对注释的！
start_time=$(date +"%Y-%m-%d %H:%M:%S")

# micromamba activate genome_annotation

# 判断result文件夹是否存在
if [ -d "./result" ]; then
    echo "result文件夹存在"
else
    echo "result文件夹不存在,即将创建......"
    mkdir ./result
fi

genomeFile=$1
path="/Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/data/ZH/20250704_some_genomes"
/Data7/wanjie/micromamba/envs/bioinfo/bin/java -Xms500g -Xmx900g -jar /Data7/wanjie/software/GeMoMa/GeMoMa-1.9.jar CLI GeMoMaPipeline \
    threads=150 \
    outdir=./result \
    tblastn=false \
    GeMoMa.Score=ReAlign AnnotationFinalizer.r=NO o=true \
    AnnotationFinalizer.u=YES AnnotationFinalizer.a=prime \
    t=${genomeFile} \
    s=own i=TAIR10 a=${path}/TAIR10/gene.gff3 g=${path}/TAIR10/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa \
    s=own i=Brana_Dar_V10 a=${path}/Brana_Dar_V10/BnapusDarmor-bzh_annotation.gff g=${path}/Brana_Dar_V10/BnapusDarmor-bzh_chromosomes.fasta \
    s=own i=Braol_JZS a=${path}/Braol_JZS_V2.0/Brassica_oleracea_JZS_v2.gene.gff3 g=${path}/Braol_JZS_V2.0/Brassica_oleracea_JZS_v2.fasta \
    s=own i=Brara_Chiifu a=${path}/Brara_Chiifu_V4.0/Brapa_genome_v4.0_gene.gff3 g=${path}/Brara_Chiifu_V4.0/Brapa_genome_v4.0_chrom.fasta \
    r=MAPPED \
    ERE.m=../Transcription/bam/A1_1.sorted.fiilter.bam \
    ERE.m=../Transcription/bam/A2_1.sorted.fiilter.bam \
    ERE.m=../Transcription/bam/A3_1.sorted.fiilter.bam \
    ERE.m=../Transcription/bam/B12_1.sorted.fiilter.bam \
    ERE.m=../Transcription/bam/B1_3.sorted.fiilter.bam \
    ERE.m=../Transcription/bam/B17_2.sorted.fiilter.bam \
    ERE.m=../Transcription/bam/C21_1.sorted.fiilter.bam \
    ERE.m=../Transcription/bam/D2_2.sorted.fiilter.bam \
    ERE.m=../Transcription/bam/F1_1.sorted.fiilter.bam \
    ERE.m=../Transcription/bam/G19_3.sorted.fiilter.bam \
    ERE.m=../Transcription/bam/J2_2.sorted.fiilter.bam \
    ERE.c=true
##判断上一步的结束状态
if [ $? -eq 0 ]; then
    echo "#######################################"
    echo "GeMoMa pipeline finished successfully."
else
    echo "GeMoMa pipeline failed."
fi

# # 过滤结果
/Data7/wanjie/micromamba/envs/bioinfo/bin/java -Xms500g -Xmx900g -jar /Data7/wanjie/software/GeMoMa/GeMoMa-1.9.jar CLI GAF \
tf=true \
g=./result/unfiltered_predictions_from_species_0.gff \
g=./result/unfiltered_predictions_from_species_1.gff \
g=./result/unfiltered_predictions_from_species_2.gff \
g=./result/unfiltered_predictions_from_species_3.gff \
f="start=='M' and stop=='*' and score/aa>=1 and (evidence>1 or tpc==1.0)"
# result file will be used for EVM : filtered_predictions.gff


# 再次获取当前时间并格式化为"YYYY-MM-DD HH:MM:SS"
end_time=$(date +"%Y-%m-%d %H:%M:%S")

# 打印开始时间和结束时间
echo "################################################"
echo "Script started at $start_time."
echo "Script finished at $end_time."
