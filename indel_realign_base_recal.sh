##$1 : Input alignment
##$2 : Sample name
##$3 : Sample type
export knownsites=$HOME/colorectal_study/knownsites
export tools_dir=$HOME/software
export target_region=$HOME/colorectal_study/exon_target/SureSelectHMExonV4_UTR.bed
export ref_genome=$HOME/colorectal_study/ref_genome/ucsc.hg19.fasta
export realign_dir=$HOME/colorectal_study/local_realign_result
export baseRecal_dir=$HOME/colorectal_study/baseRecalibrate_result
if [ ! -d "$realign_dir/$2" ]; then
  echo "Create New Directory $realign_dir/$2"
  mkdir "$realign_dir/$2"
fi

if [ ! -d "$baseRecal_dir/$2" ]; then
  echo "Create New Directory $baseRecal_dir/$2"
  mkdir "$baseRecal_dir/$2"
fi


java -Xmx8G -jar \
$tools_dir/gatk/GenomeAnalysisTK.jar \
-T RealignerTargetCreator \
-R $ref_genome \
-I $1 \
-o $realign_dir/$2/$3.intervals \
-nt 16 \
-known $knownsites/Mills_and_1000G_gold_standard.indels.hg19.vcf \
-known $knownsites/1000G_phase1.indels.hg19.vcf

java -Xmx8G -jar \
$tools_dir/gatk/GenomeAnalysisTK.jar \
-T IndelRealigner \
-I $1 \
-R $ref_genome \
-targetIntervals $realign_dir/$2/$3.intervals \
--out $realign_dir/$2/$3_realigned.bam \
-known $knownsites/Mills_and_1000G_gold_standard.indels.hg19.vcf \
-known $knownsites/1000G_phase1.indels.hg19.vcf \
-L $target_region


## BaseRecalibration

java -Xmx8G -jar \
$tools_dir/gatk/GenomeAnalysisTK.jar \
-T BaseRecalibrator \
-I $realign_dir/$2/$3_realigned.bam \
-R $ref_genome \
-o $baseRecal_dir/$2/$3_recalibrate.grp \
-knownSites $knownsites/1000G_phase1.indels.hg19.vcf \
-knownSites $knownsites/Mills_and_1000G_gold_standard.indels.hg19.vcf \
-knownSites $knownsites/dbsnp_138.hg19.vcf \
-L $target_region \
-nct 16

java -Xmx8G -jar \
$tools_dir/gatk/GenomeAnalysisTK.jar \
-T PrintReads \
-R $ref_genome \
-I $realign_dir/$2/$3_realigned.bam \
-BQSR $baseRecal_dir/$2/$3_recalibrate.grp \
-o $baseRecal_dir/$2/$3_realigned_recal.bam \
-L $target_region \
-nct 10

