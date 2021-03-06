#!/bin/bash

cd $2

echo "  making a directory hello"
mkdir hello
if [ ! -d hello ]; then exit 5; fi;

echo "  to the directory hello"
cd hello

echo "  downloading a file"

(wget -c -O common_all_20160601.vcf.gz.tbi ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b147_GRCh37p13/VCF/GATK/common_all_20160601.vcf.gz.tbi) | tee -a "$2/BRB_SeqTools_autosetup_reference_genome_files/wget_log.txt"

exit 7
