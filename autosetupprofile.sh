#!/bin/bash

##check if a file exists
#{1}: file path; {2} log file
function checkfile {
	if [ ! -f "${1}" ] 
	then 
		echo "Error: ${1} could not be found." | tee -a "${2}"
		exit 5 
	fi
}

##check if multiple files exist
#{1}: file upper directory; {2} file name; {3}log file
function checkmulfiles {
	if ! ls "${1}"/${2} >/dev/null;
	then 
		echo "Error: ${1}/${2} could not be found." | tee -a "${3}"
		exit 5 
	fi
}

## download igenomes tarball
#{1}: source, e.g., NCBI; {2}: genome build, e.g., GRCh38; {3} log file
function downloadIGenomes {

echo "  Downloading iGenomes tarball..." | tee -a "log_${1}_${2}.txt"

LINK="ftp://igenome:G3nom3s4u@ussd-ftp.illumina.com/Homo_sapiens/${1}/${2}/Homo_sapiens_${1}_${2}.tar.gz"
(wget -c --load-cookie /tmp/cookie.txt --save-cookie /tmp/cookie.txt $LINK -O Homo_sapiens_${1}_${2}.tar.gz) >> "${3}" 2>&1
checkfile Homo_sapiens_${1}_${2}.tar.gz ${3}

echo "  Copying the reference genome fasta file (genome.fa)..." | tee -a "log_${1}_${2}.txt" 
dir="Homo_sapiens/${1}/${2}/Sequence/WholeGenomeFasta"
if [ ! -d $dir ]; then mkdir -p $dir; fi;
(cp -RLp ~/.avfs"$PWD/Homo_sapiens_${1}_${2}.tar.gz#"/$dir/genome.fa $PWD/$dir) >> "log_${1}_${2}.txt" 2>&1
checkfile $PWD/$dir/genome.fa ${3}

if [ ${2} == "GRCh37" ]; then
	dir="Homo_sapiens/${1}/${2}/Annotation/Archives/archive-2015-07-17-14-31-42/Genes"
fi
if [ ${2} == "GRCh38" ]; then
	dir="Homo_sapiens/${1}/${2}/Annotation/Archives/archive-2015-08-11-09-31-31/Genes"
fi
if [ ${2} == "hg19" ]; then
	dir="Homo_sapiens/${1}/${2}/Annotation/Archives/archive-2015-07-17-14-32-32/Genes"
fi
if [ ${2} == "hg38" ]; then
	dir="Homo_sapiens/${1}/${2}/Annotation/Archives/archive-2015-08-14-08-18-15/Genes"
fi

echo "  Copying the gene transfer file (gene.gtf)..." | tee -a "log_${1}_${2}.txt"
dirGene="Homo_sapiens/${1}/${2}/Annotation/Genes"
if [ ! -d $dirGene ]; then mkdir -p $dirGene; fi;
(cp -RLp ~/.avfs"$PWD/Homo_sapiens_${1}_${2}.tar.gz#"/$dir/genes.gtf $PWD/$dirGene) >> "log_${1}_${2}.txt" 2>&1
checkfile $PWD/$dirGene/genes.gtf "${3}"

echo "  Copying pre-built BWA index files (*.bwt)..." | tee -a "log_${1}_${2}.txt"
dir="Homo_sapiens/${1}/${2}/Sequence/BWAIndex/version0.6.0"
dirBWA="Homo_sapiens/${1}/${2}/Sequence/BWAIndex"
if [ ! -d $dirBWA ]; then mkdir -p $dirBWA; fi;
(cp -RLp ~/.avfs"$PWD/Homo_sapiens_${1}_${2}.tar.gz#"/$dir/*.bwt $PWD/$dirBWA) >> "log_${1}_${2}.txt" 2>&1
checkmulfiles $PWD/$dirBWA *.bwt ${3}

echo "  Copying pre-built Bowtie2 index files (*.bt2)..." | tee -a "log_${1}_${2}.txt"
dir="Homo_sapiens/${1}/${2}/Sequence/Bowtie2Index"
if [ ! -d $dir ]; then mkdir -p $dir; fi;
(cp -RLp ~/.avfs"$PWD/Homo_sapiens_${1}_${2}.tar.gz#"/$dir/*.bt2 $PWD/$dir) >> "log_${1}_${2}.txt" 2>&1
checkmulfiles $PWD/$dir *.bt2 ${3}

}



mountavfs

cd $2

#Create a folder
mkdir -p ./BRB_SeqTools_autosetup_reference_genome_files
mkdir -p ./BRB_SeqTools_autosetup_reference_genome_files/dbSNP_VCF

if [ -f "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt" ]; then rm "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt"; fi;
touch "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt"
echo `date +'%Y-%m-%d %T'` >> "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt"
case $1 in
	"Ensembl_GRCh37") 
		cd ./BRB_SeqTools_autosetup_reference_genome_files
		downloadIGenomes Ensembl GRCh37 $2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt
		rm ./Homo_sapiens_Ensembl_GRCh37.tar.gz
		cd ./dbSNP_VCF
		mkdir -p ./Ensembl_GRCh37
		cd ./Ensembl_GRCh37
		echo "  Downloading dbSNP VCF files..." | tee -a "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt"
		(wget -c -O common_all_20160601.vcf.gz ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh37p13/VCF/common_all_20160601.vcf.gz) >> "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt" 2>&1
		(wget -c -O common_all_20160601.vcf.gz.tbi ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh37p13/VCF/common_all_20160601.vcf.gz.tbi) >> "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt" 2>&1
		checkfile common_all_20160601.vcf.gz $2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt
		checkfile common_all_20160601.vcf.gz.tbi $2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt
		;;
	"NCBI_GRCh38")
		cd ./BRB_SeqTools_autosetup_reference_genome_files
		downloadIGenomes NCBI GRCh38 $2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt
		rm ./Homo_sapiens_NCBI_GRCh38.tar.gz
		cd ./dbSNP_VCF
		mkdir -p ./NCBI_GRCh38
		cd ./NCBI_GRCh38
		echo "  Downloading dbSNP VCF files..." | tee -a "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt"
		(wget -c -O common_all_20160527.vcf.gz ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh38p2/VCF/GATK/common_all_20160527.vcf.gz) >> "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt" 2>&1
		(wget -c -O common_all_20160527.vcf.gz.tbi ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh38p2/VCF/GATK/common_all_20160527.vcf.gz.tbi) >> "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt" 2>&1
		checkfile common_all_20160527.vcf.gz $2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt
		checkfile common_all_20160527.vcf.gz.tbi $2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt
		;;
	"UCSC_hg38")
		cd ./BRB_SeqTools_autosetup_reference_genome_files
		downloadIGenomes UCSC hg38 $2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt
		rm ./Homo_sapiens_UCSC_hg38.tar.gz
		cd ./dbSNP_VCF
		mkdir -p ./UCSC_hg38
		cd ./UCSC_hg38
		echo "  Downloading dbSNP VCF files..." | tee -a "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt"
		(wget -c -O common_all_20160527.vcf.gz ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh38p2/VCF/GATK/common_all_20160527.vcf.gz) >> "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt" 2>&1
		(wget -c -O common_all_20160527.vcf.gz.tbi ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh38p2/VCF/GATK/common_all_20160527.vcf.gz.tbi) >> "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt" 2>&1
		checkfile common_all_20160527.vcf.gz $2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt
		checkfile common_all_20160527.vcf.gz.tbi $2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt
		;;
	"UCSC_hg19") 
		cd ./BRB_SeqTools_autosetup_reference_genome_files		
		downloadIGenomes UCSC hg19 $2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt
		rm ./Homo_sapiens_UCSC_hg19.tar.gz
		cd ./dbSNP_VCF
		mkdir -p ./UCSC_hg19
		cd ./UCSC_hg19
		echo "  Downloading dbSNP VCF files..." | tee -a "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt"
		(wget -c -O common_all_20160601.vcf.gz ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh37p13/VCF/GATK/common_all_20160601.vcf.gz) >> "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt" 2>&1
		(wget -c -O common_all_20160601.vcf.gz.tbi ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh37p13/VCF/GATK/common_all_20160601.vcf.gz.tbi) >> "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt" 2>&1
		checkfile common_all_20160601.vcf.gz $2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt
		checkfile common_all_20160601.vcf.gz.tbi $2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt
		;;
esac
echo `date +'%Y-%m-%d %T'` >> "$2/BRB_SeqTools_autosetup_reference_genome_files/log_$1.txt"

exit 7
