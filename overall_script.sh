##$1 : sample name.
##$2 : sample type.
##$3 : Read_1.
##$4 : Read_2.

## Example
## bwa_align.sh \
## patient1 \
## normal \
## raw_seqs/patient1/normal/seq1.fastq \
## raw_seqs/patient1/normal/seq2.fastq \

export RGID="patient2"
export RGLB="CGATGT"
export RGPL="illumina"
export RGSM="adenoma"
export RGPU="C3W95ACXX"
export tools_dir=$HOME/software
export alignment_dir=$HOME/colorectal_study/alignment_result
export realign_dir=$HOME/colorectal_study/local_realign_result
export baseRecal_dir=$HOME/colorectal_study/baseRecalibrate_result
export knownsites=$HOME/colorectal_study/knownsites
export target_region=$HOME/colorectal_study/exon_target/SureSelectHMExonV4_UTR.bed
export ref_genome=$HOME/colorectal_study/ref_genome/ucsc.hg19.fasta


if [ ! -d "$alignment_dir/$1" ]; then
  echo "Create new directory $alignment_dir/$1"
  mkdir "$alignment_dir/$1"
fi

if [ ! -d "$realign_dir/$1" ]; then
  echo "Create New Directory $realign_dir/$1"
  mkdir "$realign_dir/$1"
fi

if [ ! -d "$baseRecal_dir/$1" ]; then
  echo "Create New Directory $baseRecal_dir/$1"
  mkdir "$baseRecal_dir/$1"
fi

echo "BWA mem : $3 , $4"
bwa mem -M -t 16 \
$ref_genome \
$3 \
$4 | \
samtools view -bSu - | \
samtools sort - $alignment_dir/$1/$2

echo "Done Read Alignment: BWA MEM and samtools sort" 


java -Xmx16G -jar \
$tools_dir/picard-tools-1.115/MarkDuplicates.jar \
INPUT=$alignment_dir/$1/$2.bam \
OUTPUT=$alignment_dir/$1/$2_rmdup.bam \
METRICS_FILE=$alignment_dir/$1/$2_dup.txt \
VALIDATION_STRINGENCY=LENIENT \
REMOVE_DUPLICATES=true

java -Xmx16G -jar \
$tools_dir/picard-tools-1.115/AddOrReplaceReadGroups.jar \
INPUT=$alignment_dir/$1/$2_rmdup.bam \
OUTPUT=$alignment_dir/$1/$2_rmdup_readgroup.bam \
RGID=$RGID RGLB=$RGLB RGPL=$RGPL RGSM=$RGSM RGPU=$RGPU \
VALIDATION_STRINGENCY=LENIENT

$tools_dir/samtools/samtools index $alignment_dir/$1/$2_rmdup_readgroup.bam

java -Xmx8G -jar \
$tools_dir/gatk/GenomeAnalysisTK.jar \
-T RealignerTargetCreator \
-R $ref_genome \
-I $alignment_dir/$1/$2_rmdup_readgroup.bam \
-o $realign_dir/$1/$2.intervals \
-nt 16 \
-known $knownsites/Mills_and_1000G_gold_standard.indels.hg19.vcf \
-known $knownsites/1000G_phase1.indels.hg19.vcf

echo "Done RealignerTargetCreator"


java -Xmx8G -jar \
$tools_dir/gatk/GenomeAnalysisTK.jar \
-T IndelRealigner \
-I $alignment_dir/$1/$2_rmdup_readgroup.bam \
-R $ref_genome \
-targetIntervals $realign_dir/$1/$2.intervals \
--out $realign_dir/$1/$2_realigned.bam \
-known $knownsites/Mills_and_1000G_gold_standard.indels.hg19.vcf \
-known $knownsites/1000G_phase1.indels.hg19.vcf \
-L $target_region

echo "Done : IndelRealigner"

## BaseRecalibration

java -Xmx8G -jar \
$tools_dir/gatk/GenomeAnalysisTK.jar \
-T BaseRecalibrator \
-I $realign_dir/$1/$2_realigned.bam \
-R $ref_genome \
-o $baseRecal_dir/$1/$2_recalibrate.grp \
-knownSites $knownsites/1000G_phase1.indels.hg19.vcf \
-knownSites $knownsites/Mills_and_1000G_gold_standard.indels.hg19.vcf \
-knownSites $knownsites/dbsnp_138.hg19.vcf \
-L $target_region \
-nct 16

echo "Done : BaseRecalibrator"

java -Xmx8G -jar \
$tools_dir/gatk/GenomeAnalysisTK.jar \
-T PrintReads \
-R $ref_genome \
-I $realign_dir/$1/$2_realigned.bam \
-BQSR $baseRecal_dir/$1/$2_recalibrate.grp \
-o $baseRecal_dir/$1/$2_realigned_recal.bam \
-L $target_region \
-nct 10

echo "Done : PrintReads"

