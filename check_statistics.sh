##$1 : sample name
##$2 : sample type
##$3 : Read_1
##$4 : Read_2
export tools_dir=$HOME/software
export fastqc_dir=$HOME/colorectal_study/FastQC_result
export baseRecal_dir=$HOME/colorectal_study/baseRecalibrate_result
export bamstats_dir=$HOME/colorectal_study/bamstats_result

if [ ! -d "$fastqc_dir/$1" ]; then
  echo "Create new directory $fastqc_dir/$1"
  mkdir "$fastqc_dir/$1"
fi

if [ ! -d "$fastqc_dir/$1/$2" ]; then
  echo "Create new directory $fastqc_dir/$1/$2"
  mkdir "$fastqc_dir/$1/$2"
fi

if [ ! -d "$bamstats_dir/$1" ]; then
  echo "Create new directory $bamstats_dir/$1"
  mkdir "$bamstats_dir/$1"
fi

if [ ! -d "$bamstats_dir/$1/$2" ]; then
  echo "Create new directory $bamstats_dir/$1/$2"
  mkdir "$bamstats_dir/$1/$2"
fi

echo "Run FastQC"
$tools_dir/FastQC/fastqc --threads 10 --outdir $fastqc_dir/$1/$2 $3 $4
echo "Done : FastQC"

echo "Run BamStats -> Basic Mapping Stats"
java -jar $tools_dir/BAMStats-1.25/BAMStats-1.25.jar \
-i $baseRecal_dir/$1/$2_realigned_recal.bam \
-q -m -v simple > $bamstats_dir/$1/$2/basic.txt
echo "Done : BamStats"

echo "Run BamUtil -> Summary Mapping Stats"
$tools_dir/bamUtil_1.0.12/bamUtil/bin/bam stats \
--in $baseRecal_dir/$1/$2_realigned_recal.bam \
--basic \
--bamIndex $baseRecal_dir/$1/$2_realigned_recal.bai \
&> $bamstats_dir/$1/$2/summary.txt
echo "Done : BamUtil"
