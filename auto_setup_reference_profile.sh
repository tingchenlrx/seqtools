#!/bin/bash
#
# Installation script for automatically setting up reference genome files.
#
# This script has two arguments. The first one is genomebuild and the second one is the full path of a folder to which user want to save the downloade files. 
#

function checkfile {
	if [ ! -f "${1}" ] 
	then 
		echo "Error: ${1} could not be found."
		exit 5 
	fi
}

function checkmulfiles {
	if ! ls "${1}"/${2} >/dev/null;
	then 
		echo "Error: ${1}/${2} could not be found."
		exit 5 
	fi
}

function downloadIGenomes {

LINK="ftp://igenome:G3nom3s4u@ussd-ftp.illumina.com/Homo_sapiens/${1}/${2}/Homo_sapiens_${1}_${2}.tar.gz"
wget -c --load-cookie /tmp/cookie.txt --save-cookie /tmp/cookie.txt $LINK -O Homo_sapiens_${1}_${2}.tar.gz
checkfile Homo_sapiens_${1}_${2}.tar.gz

dir="Homo_sapiens/${1}/${2}/Sequence/WholeGenomeFasta"
if [ ! -d $dir ]; then mkdir -p $dir; fi;
cp -RLp ~/.avfs"$PWD/Homo_sapiens_${1}_${2}.tar.gz#"/$dir/genome.fa $PWD/$dir
checkfile $PWD/$dir/genome.fa
echo "genome.fa has been downloaded successfully."


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
dirGene="Homo_sapiens/${1}/${2}/Annotation/Genes"
if [ ! -d $dirGene ]; then mkdir -p $dirGene; fi;
cp -RLp ~/.avfs"$PWD/Homo_sapiens_${1}_${2}.tar.gz#"/$dir/genes.gtf $PWD/$dirGene
checkfile $PWD/$dirGene/genes.gtf
echo "genes.gtf has been downloaded successfully."

dir="Homo_sapiens/${1}/${2}/Sequence/BWAIndex/version0.6.0"
dirBWA="Homo_sapiens/${1}/${2}/Sequence/BWAIndex"
if [ ! -d $dirBWA ]; then mkdir -p $dirBWA; fi;
cp -RLp ~/.avfs"$PWD/Homo_sapiens_${1}_${2}.tar.gz#"/$dir/*.bwt $PWD/$dirBWA
checkmulfiles $PWD/$dirBWA *.bwt
echo "BWA pre-built index files have been downloaded successfully."

dir="Homo_sapiens/${1}/${2}/Sequence/Bowtie2Index"
if [ ! -d $dir ]; then mkdir -p $dir; fi;
cp -RLp ~/.avfs"$PWD/Homo_sapiens_${1}_${2}.tar.gz#"/$dir/*.bt2 $PWD/$dir
checkmulfiles $PWD/$dir *.bt2
echo "Bowtie2 pre-built index files have been downloaded successfully."

}

set -x
echo $1
echo $2
echo $PWD

mountavfs

cd $2

#Create a folder
mkdir -p ./BRB_SeqTools_autosetup_reference_genome_files
mkdir -p ./BRB_SeqTools_autosetup_reference_genome_files/dbSNP_VCF
case $1 in
	"Ensembl_GRCh37") 
		cd ./BRB_SeqTools_autosetup_reference_genome_files
		downloadIGenomes Ensembl GRCh37
		rm ./Homo_sapiens_Ensembl_GRCh37.tar.gz
		cd ./dbSNP_VCF
		mkdir -p ./Ensembl_GRCh37
		cd ./Ensembl_GRCh37
		wget -c -O common_all_20160601.vcf.gz ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh37p13/VCF/common_all_20160601.vcf.gz
		wget -c -O common_all_20160601.vcf.gz.tbi ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh37p13/VCF/common_all_20160601.vcf.gz.tbi
		checkfile common_all_20160601.vcf.gz
		checkfile common_all_20160601.vcf.gz.tbi
		;;
	"NCBI_GRCh38")
		cd ./BRB_SeqTools_autosetup_reference_genome_files
		downloadIGenomes NCBI GRCh38
		rm ./Homo_sapiens_NCBI_GRCh38.tar.gz
		cd ./dbSNP_VCF
		mkdir -p ./NCBI_GRCh38
		cd ./NCBI_GRCh38
		wget -c -O common_all_20160527.vcf.gz ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh38p2/VCF/GATK/common_all_20160527.vcf.gz
		wget -c -O common_all_20160527.vcf.gz.tbi ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh38p2/VCF/GATK/common_all_20160527.vcf.gz.tbi
		checkfile common_all_20160527.vcf.gz
		checkfile common_all_20160527.vcf.gz.tbi
		;;
	"UCSC_hg38")
		cd ./BRB_SeqTools_autosetup_reference_genome_files
		downloadIGenomes UCSC hg38
		rm ./Homo_sapiens_UCSC_hg38.tar.gz
		cd ./dbSNP_VCF
		mkdir -p ./UCSC_hg38
		cd ./UCSC_hg38
		wget -c -O common_all_20160527.vcf.gz ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh38p2/VCF/GATK/common_all_20160527.vcf.gz
		wget -c -O common_all_20160527.vcf.gz.tbi ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh38p2/VCF/GATK/common_all_20160527.vcf.gz.tbi
		checkfile common_all_20160527.vcf.gz
		checkfile common_all_20160527.vcf.gz.tbi
		;;
	"UCSC_hg19") 
		cd ./BRB_SeqTools_autosetup_reference_genome_files		
		(downloadIGenomes UCSC hg19
		rm ./Homo_sapiens_UCSC_hg19.tar.gz
		cd ./dbSNP_VCF
		mkdir -p ./UCSC_hg19
		cd ./UCSC_hg19
		wget -c -O common_all_20160601.vcf.gz ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh37p13/VCF/GATK/common_all_20160601.vcf.gz
		wget -c -O common_all_20160601.vcf.gz.tbi ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh37p13/VCF/GATK/common_all_20160601.vcf.gz.tbi
		checkfile common_all_20160601.vcf.gz
		checkfile common_all_20160601.vcf.gz.tbi
		;;
esac

echo
read -p "Press [Enter] key to quit."
