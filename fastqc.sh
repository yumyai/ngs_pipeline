##$1 : sample name
##$2 : sample type
##$3 : Read_1
##$4 : Read_2
export tools_dir=$HOME/software
export fastqc_dir=$HOME/colorectal_study/FastQC_result

if [ ! -d "$fastqc_dir/$1" ]; then
  echo "Create new directory $fastqc_dir/$1"
  mkdir "$fastqc_dir/$1"
fi

if [ ! -d "$fastqc_dir/$1/$2" ]; then
  echo "Create new directory $fastqc_dir/$1/$2"
  mkdir "$fastqc_dir/$1/$2"
fi

$tools_dir/FastQC/fastqc --threads 10 --outdir $fastqc_dir/$1/$2 $3 $4
