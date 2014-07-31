##$1 : sample name.
##$2 : Read_1.
##$3 : Read_2.
##$4 : Output alignment File name.

## Example
## bwa_align.sh \
## patient1 \
## raw_seqs/patient1/normal/seq1.fastq
## raw_seqs/patient1/normal/seq2.fastq \
## normal

 
new_dir="$HOME/colorectal_study/alignment_result/$1"
if [ ! -d "$new_dir" ]; then
  echo "Create new directory $new_dir"
  mkdir "$new_dir"
fi

echo "BWA mem : $2 , $3"
bwa mem -M -t 16 \
/storage/home/pitithat.pur/colorectal_study/ref_genome/ucsc.hg19.fasta \
$2 \
$3 | \
samtools view -bSu - | \
samtools sort - $new_dir/$4
