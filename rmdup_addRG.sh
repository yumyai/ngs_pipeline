##1 Input alignment file
##2 sample name
##3 sample type
export tools_dir=$HOME/software
export alignment_dir=$HOME/colorectal_study/alignment_result
export RGID="patient1"
export RGLB="CGATGT"
export RGPL="illumina"
export RGSM="patient"
export RGPU="C3W95ACXX"

java -Xmx16G -jar \
$tools_dir/picard-tools-1.115/MarkDuplicates.jar \
INPUT=$1 \
OUTPUT=$alignment_dir/$2/$3_rmdup.bam \
METRICS_FILE=$alignment_dir/$2/$3_dup.txt \
VALIDATION_STRINGENCY=LENIENT \
REMOVE_DUPLICATES=true

java -Xmx16G -jar \
$tools_dir/picard-tools-1.115/AddOrReplaceReadGroups.jar \
INPUT=$alignment_dir/$2/$3_rmdup.bam \
OUTPUT=$alignment_dir/$2/$3_rmdup_readgroup.bam \
RGID=$RGID RGLB=$RGLB RGPL=$RGPL RGSM=$RGSM RGPU=$RGPU \
VALIDATION_STRINGENCY=LENIENT

$tools_dir/samtools/samtools index $alignment_dir/$2/$3_rmdup_readgroup.bam
