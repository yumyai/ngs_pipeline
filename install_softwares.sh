## Create Tools Directory
tools_dir="$HOME/colorectal_study/software"
if [ ! -d "$tools_dir" ]; then
 echo "Create Directory $tools_dir ."
 mkdir $tools_dir
fi


## samtools
cd $tools_dir
wget http://downloads.sourceforge.net/project/samtools/samtools/0.1.19/samtools-0.1.19.tar.bz2
tar -xvf samtools-0.1.19.tar.bz2
mv samtools-0.1.19 samtools
cd samtools
make

## bwa
cd $tools_dir
wget http://downloads.sourceforge.net/project/bio-bwa/bwa-0.7.10.tar.bz2
tar -xvf bwa-0.7.10.tar.bz2
mv bwa-0.7.10 bwa
cd bwa
make

## GATK
cd $tools_dir
wget https://dl.dropboxusercontent.com/content_link/Mp3rYXiX8r1Xds7CnDlrbc88D7STMhvUktFHCZ0iQDRWm2FQdbmoU5MTsKUib3p7?dl=1
tar -xvf GenomeAnalysisTK-3.1-1.tar.bz2

## picard
cd $tools_dir
wget http://downloads.sourceforge.net/project/picard/picard-tools/1.117/picard-tools-1.117.zip
unzip picard-tools-1.117.zip
mv picard-tools-1.117 picard-tools

