# 0.准备近缘物种的gff3文件
cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/data/ZH/20250704_some_genomes/TAIR10
awk '!/^#/ {a[$3]=1} END {for (i in a) print i}' Arabidopsis_thaliana.TAIR10.57.gff3 |sort
awk '
    BEGIN { 
        # 定义要排除的feature类型
        exclude["chromosome"]=1; exclude["miRNA"]=1; 
        exclude["ncRNA"]=1; exclude["ncRNA_gene"]=1; 
        exclude["rRNA"]=1; exclude["snoRNA"]=1; 
        exclude["snRNA"]=1; exclude["rRNA"]=1; 
        exclude["snoRNA"]=1; exclude["tRNA"]=1; 
    }
    !/^#/ && !exclude[$3]  # 非注释行且不在排除列表中
'  Arabidopsis_thaliana.TAIR10.57.gff3 > gene.gff3
grep "#" -v |awk '{print $3}' gene.gff3 |sort|uniq

cd ../Brana_Dar_V10
# grep "#" -v |awk '{print $3}' BnapusDarmor-bzh_annotation.gff |sort|uniq
awk '!/^#/ {a[$3]=1} END {for (i in a) print i}' BnapusDarmor-bzh_annotation.gff

cd ../Braol_JZS_V2.0
awk '!/^#/ {a[$3]=1} END {for (i in a) print i}' Brassica_oleracea_JZS_v2.gene.gff3

cd ../Brara_Chiifu_V4.0
gffread Brapa_genome_v4.0_gene.gff3 -g Brapa_genome_v4.0_chrom.fasta -y pep.fa

cat TAIR10/Arabidopsis_thaliana.TAIR10.pep.all.fa Brana_Dar_V10/pep.fa Braol_JZS_V2.0/pep.fa Brara_Chiifu_V4.0/pep.fa > protein.fa
# ------------------------------------------------------------------------------------------------------------------------------------
# 1.EDTA注释
cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/genome
ln -s /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/1/ragtag_output/closegap/finalGenome/1.final.fa ./

cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/EDTA 
cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/1/ragtag_output/closegap/finalGenome/1.final.fa  ./
nohup bash EDTA.sh 1.final.fa > 1.log &

cd  /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/2copy/EDTA 
cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/2copy/ragtag_output/closegap/finalGenome/2.final.fa ./
nohup bash EDTA.sh 2.final.fa > 2.log &

# 获取soft-mask的fasta
sed \
    -e 's/ZS11_A01_RagT/ZS11_A01_RagTag_part1/' \
    -e 's/ZS11_A02_RagT/ZS11_A02_RagTag_part1/' \
    -e 's/ZS11_A03_RagT/ZS11_A03_RagTag/' \
    -e 's/ZS11_A04_RagT/ZS11_A04_RagTag/' \
    -e 's/ZS11_A05_RagT/ZS11_A05_RagTag/' \
    -e 's/ZS11_A06_RagT/ZS11_A06_RagTag/' \
    -e 's/ZS11_A07_RagT/ZS11_A07_RagTag/' \
    -e 's/ZS11_A08_RagT/ZS11_A08_RagTag/' \
    -e 's/ZS11_A09_RagT/ZS11_A09_RagTag/' \
    -e 's/ZS11_A10_RagT/ZS11_A10_RagTag/' \
    -e 's/ZS11_C01_RagT/ZS11_C01_RagTag_part1/' \
    -e 's/ZS11_C02_RagT/ZS11_C02_RagTag/' \
    -e 's/ZS11_C03_RagT/ZS11_C03_RagTag/' \
    -e 's/ZS11_C04_RagT/ZS11_C04_RagTag/' \
    -e 's/ZS11_C05_RagT/ZS11_C05_RagTag/' \
    -e 's/ZS11_C06_RagT/ZS11_C06_RagTag/' \
    -e 's/ZS11_C07_RagT/ZS11_C07_RagTag:0-4000000/' \
    -e 's/ZS11_C08_RagT/ZS11_C08_RagTag/' \
    -e 's/ZS11_C09_RagT/ZS11_C09_RagTag/' \
    -e 's/ptg000035l/ptg000035l/' \
    -e 's/ptg000036l/ptg000036l/' \
    -e 's/scaffold0035_/scaffold0035_RagTag/' \
    -e 's/scaffold0417_/scaffold0417_RagTag/' 1.final.fa.mod.EDTA.anno/1.final.fa.mod.EDTA.TEanno.out > 1.final.fa.mod.EDTA.TEanno.rename.out


sudo perl /Data7/wanjie/software/edta2.2.2/EDTA-2.2.2/bin/make_masked.pl \
    -genome 1.final.fa \
    -minlen 500 -hardmask 0 -t 10 \
    -rmout 1.final.fa.mod.EDTA.TEanno.rename.out
cat 1.final.fa.new.masked |fold -w 60 > 1.final.fa.new.masked.softmask.fold60.fa



# ------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------
# 2.转录组
cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/Transcription
cd ../genome

# 2.1 hiisat2-striingtie-transdecoder
##建立索引
hisat2-build -p 60 \
    1.final.fa.new.masked 1 \
    1> hisat2-build.log 2> hisat2-build.err

cd ../Transcription/
nohup bash hisat2-stringtie.sh > log/hisat2.log &

cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/Transcription/bam
ls *.sorted.fiilter.bam > bam.list
samtools merge -O BAM -b bam.list -@ 60 -o merge.sorted.bam
nohup bash hisat2-stringtie.sh > log/stringtie.log &

# Transdecoder使用
###分析开始
# 从stringtie_merged.gtf中提取FASTA序列
cd stringtie/
gtf_genome_to_cdna_fasta.pl 1.gtf ../../genome/1.final.fa.new.masked.softmask.fa > transcripts.fasta 
# 将stringtie_merged.gtf转成GFF3格式
gtf_to_alignment_gff3.pl 1.gtf > transcripts.gff3
# 预测开放阅读框
TransDecoder.LongOrfs -m 50 -t transcripts.fasta
# 使用diamond与Swissport数据库同源比对(非必须)，也可以使用hmmscan与pfam数据库比对
cd ../TransDecoder_blast_pfam/
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

# 2.2 trinity-PASA
nohup bash trinity_PASA12.sh > log/trinity.log &

nohup bash trinity_PASA12.sh > log/pasaalign.log &

# 2.3 isoseq-PASA
nohup bash isoseq_PASA12.sh > log/iso1.log &
nohup bash isoseq_PASA12.sh > log/iso2.log  &
# ------------------------------------------------------------------------------------------

# 2.从头注释
cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/denovo
cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/EDTA/1.final.fa.new.masked ./
cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/data/ZH/20250704_some_genomes/protein.fa ./

mkdir bam && cd bam
cp  ../../Transcription/bam/*.sorted.fiilter.bam ./
cd ../

cat /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/data/ZH/20250704_some_genomes/protein.fa /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/data/ZH/20250714_Bna_Bra_Bol_genomes/protein2.fa > proteinTotal.fa
cat proteinTotal.fa |seqkit rmdup -n -i -o proteinTotal.uniq.fa
nohup bash braker3.sh 1.final.fa.new.masked.softmask.fa > run1.log &

sed -i '/^>/! s/\.//g' protein.fa
nohup bash braker3.sh > 2.log &

# ------------------------------------------------------------------------------------------
#  3.同源注释
cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/homo

nohup bash gomema.sh ../genome/1.final.fa.new.masked.softmask.fa > 1.log &

# ------------------------------------------------------------------------------------------
# 4. 合并注释结果
cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/EVMmerge
mkdir log

# (1)denovo从头注释
cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/denovo/brakerresult/braker.gff3 ./
# sed 's/;$//g' braker.gff3 |awk '$1=="Chr1"' > braker.Chr1.gff3  #denovo type
# cut -f2 braker.gff3 |sort|uniq #检查第二列是不是和weights.txt文件匹配
# 检查格式正确否？
perl /Data7/wanjie/software/EVidenceModeler-master/EvmUtils/gff3_gene_prediction_file_validator.pl braker.gff3
awk '{print $3}' braker.gff3 |sort|uniq -c

cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/denovo/brakerresul2/braker.gff3 ./braker2.gff3
perl /Data7/wanjie/software/EVidenceModeler-master/EvmUtils/gff3_gene_prediction_file_validator.pl braker2.gff3

# (2)protein同源比对
cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/homo/filtered_predictions1.gff ./
cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/homo/result/final_annotation.gff ./
perl /Data7/wanjie/software/EVidenceModeler-master/EvmUtils/misc/GeMoMa_gff_to_gff3.pl filtered_predictions1.gff > GeMoMa.gff3
perl /Data7/wanjie/software/EVidenceModeler-master/EvmUtils/misc/GeMoMa_gff_to_gff3.pl final_annotation.gff  > GeMoMa2.gff3
grep "#" -v GeMoMa.gff3 |cut -f2 |sort|uniq
awk '{print $3}' GeMoMa2.gff3 |sort|uniq -c

# (3) 转录组
# 3.1 hisat2-stringtie-transdecoder
cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/Transcription/stringtie/transcripts.fasta.transdecoder.genome.gff3 ./
awk '{print $3}' transcripts.fasta.transdecoder.genome.gff3 |sort|uniq -c


# 3.2trinity-PASA
##PASA +ORF预测 other type
cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/Transcription/trinity/sample_mydb_pasa.sqlite.assemblies.fasta.transdecoder.genome.gff3 ./ 
cut -f2 sample_mydb_pasa.sqlite.assemblies.fasta.transdecoder.genome.gff3 |sort|uniq
awk '{print $3}' sample_mydb_pasa.sqlite.assemblies.fasta.transdecoder.genome.gff3 |sort|uniq -c
# TRANSCRIPT type
cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/Transcription/trinity/sample_mydb_pasa.sqlite.pasa_assemblies.gff3 ./ 
cut -f2 sample_mydb_pasa.sqlite.pasa_assemblies.gff3 |sort|uniq
awk '{print $3}' sample_mydb_pasa.sqlite.pasa_assemblies.gff3 |sort|uniq -c

# 3.3 isoseq-PASA
# other type
cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/Transcription/isoseq/sample_mydb_pasa.sqlite.assemblies.fasta.transdecoder.genome.gff3 ./isoseq_sample_mydb_pasa.sqlite.assemblies.fasta.transdecoder.genome.gff3
cut -f2 isoseq_sample_mydb_pasa.sqlite.assemblies.fasta.transdecoder.genome.gff3 |sort|uniq
awk '{print $3}' isoseq_sample_mydb_pasa.sqlite.assemblies.fasta.transdecoder.genome.gff3 |sort|uniq -c
# TRANSCRIPT type
cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/Transcription/isoseq/sample_mydb_pasa.sqlite.pasa_assemblies.gff3 ./isoseq_sample_mydb_pasa.sqlite.pasa_assemblies.gff3
cut -f2 isoseq_sample_mydb_pasa.sqlite.pasa_assemblies.gff3 |sort|uniq
awk '{print $3}' isoseq_sample_mydb_pasa.sqlite.pasa_assemblies.gff3 |sort|uniq -c

# (4)合并不同类型
## transcript 
cat sample_mydb_pasa.sqlite.pasa_assemblies.gff3  \
    transcripts.fasta.transdecoder.genome.gff3 \
    sample_mydb_pasa.sqlite.assemblies.fasta.transdecoder.genome.gff3 \
    isoseq_sample_mydb_pasa.sqlite.pasa_assemblies.gff3 \
    isoseq_sample_mydb_pasa.sqlite.assemblies.fasta.transdecoder.genome.gff3 > transcript_total_type_total.gff3

cat sample_mydb_pasa.sqlite.pasa_assemblies.gff3  \
    transcripts.fasta.transdecoder.genome.gff3 \
    sample_mydb_pasa.sqlite.assemblies.fasta.transdecoder.genome.gff3 > transcript_total_type_total_noiso.gff3


cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/genome/1.final.fa.new.masked.softmask.fold60.fa ./
nohup bash EVM.sh  > log/evm.log &
nohup bash evm3.sh > log/evm33.log &
nohup bash evm3.braker2.sh > log/evm3.braker2.log &


# ------------------------------------------------------------------------------------------
# 5.更新注释结果
# PASA两步更新
cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/Transcription/PASA
mkdir PASAupdate1 PASAupdate2

sudo cp -r /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/Transcription/trinity/* ./PASAupdate1
sudo cp -r /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/Transcription/isoseq/* ./PASAupdate2

cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/Transcription

cd PASA/PASAupdate1
sudo chown -R  wanjie:wanjie ./
cd ../../
nohup bash trinity_PASA12.sh > log/trinity_PASA12update1.log &

nohup bash isoseq_PASA12.sh > log/isoseq_PASA12update2.log &
# ------------------------------------------------------------------------------------------
# 6.过滤TE基因
cd /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1
mkdir filterTEgene && cd filterTEgene

# ln -s  /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/EVMmerge/youcai3braker2.EVM.gff3 ./
# ln -s  /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/EVMmerge/youcai3braker2.EVM.pep ./
# ln -s  /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/EVMmerge/youcai3braker2.EVM.cds ./

cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/Transcription/PASA/PASAupdate2/sample_mydb_pasa.sqlite.gene_structures_post_PASA_updates.2277133.gff3 ./final.PASAupdate.gff3
cp /Data8/wanjie/other_data_doing/zhaohu_six_genome/data20250626result/genomeAnno/1/genome/1.final.fa.new.masked.softmask.fold60.fa ./
awk -F "\t" '{print $3}' final.PASAupdate.gff3 |sort|uniq -c
# grep ">" youcai3braker2.EVM.pep |wc -l
# grep ">" youcai3braker2.EVM.cds |wc -l

# 提取cds序列
gffread final.PASAupdate.gff3 -g 1.final.fa.new.masked.softmask.fold60.fa -x cds.fa
# 预测序列中哪些含有TE
TEsorter cds.fa -db rexdb-plant -eval 1e-5 -p 50
# ----------------------------------------------------------

# 获得基因编号（查看tsv文件根据文件具体格式来）
cut -f 1 -d "|" cds.fa.rexdb-plant.dom.tsv |sort|uniq|wc -l
grep "^evm" cds.fa.rexdb-plant.dom.tsv |cut -f 1 -d "|" |sort|uniq  > TE-genes.cdsname.txt
# 去除含有TE的基因序列
mkdir tmp && cd tmp
ln ../TE-genes.cdsname.txt ./
ln -s ../final.PASAupdate.gff3 ./
grep "#" -v final.PASAupdate.gff3|awk '$3=="gene" || $3=="mRNA"' |cut -f9|sed 's/;/\t/g' |sed -e 's/ID=//' -e 's/Parent=//' -e 's/Name=//' > a.tsv
for i in `cat TE-genes.cdsname.txt`
do
    grep -w  "$i" a.tsv |cut -f2  >> TE-genes.genename.txt
done
cat TE-genes.genename.txt |sort|uniq > TE-genes.genename.2.txt
cd ..

grep "#" -v  final.PASAupdate.gff3|awk '$3=="gene"' |cut -f9|cut -f1 -d ";" |sed 's/ID=//' > allgene.txt
grep "#" -v final.PASAupdate.gff3|awk '$3=="mRNA"'  |cut -f9|cut -f1 -d ";" |sed 's/ID=//' > allmRNA.txt 

grep -v -w -f ./tmp/TE-genes.genename.2.txt allgene.txt > noTEgene.txt
# grep -v -w -f TE-genes.cdsname.txt allmRNA.txt > noTEmRNA.txt
# 运行nomrna.ipynb

wc -l ./tmp/TE-genes.genename.2.txt noTEgene.txt #检查一下应该和总基因数目一致
wc -l TE-genes.cdsname.txt noTEmRNA.txt  #mRNA也是一致
# 然后在TBtools使用GXF Select 功能抽取基因和基因的附属信息, 输出名字命名 remainGneme.txt；remainmRNA.txt
micromamba activate genome_annotation 
# 使用gff3tookit对gff3文件排序
# pip3 install gff3tool
awk '$3!="mRNA"' remainGneme.txt |cat - remainmRNA.txt > remain.gff3
gff3_sort -g remain.gff3 -og remain.final.gff3
# grep "#" -v  remain.gff3|sort -k1 -k4,4g -k5,5g > remain.final.gff3

# 修改基因名字

# ------------------------------------------------------------------------------------------
# 7. 评估注释结果
# BUSCO
micromamba activate BUSCO
busco \
    -i youcai3braker2.EVM.pep \
    -c 200 \
    -o busco \
    -m protein \
    -l /Data7/wanjie/software/embryophyta_odb10 --offline
# GO比例等

