#files=`cat list.txt`

########################
## 1) Download the files
########################
#for file in $files;
#do
#    wget $file
#done

########################
## 2) Trim the files
########################
#files=`ls ./*.gz`

#for file in $files;
#do
#        prefix=`echo $file | sed s/.gz//`
#        /raid/LOG-G/slinker/tools/SolexaQA++/SolexaQA++ dynamictrim $file
#done


########################
## 3) Unzip trimmed files
########################

#gunzip *.trimmed.gz

########################
## 4) Align with STAR
########################

#files=`ls ./*trimmed`

#for file1 in $files; 
#do
	##########
	## HUMAN
	##########

##	genome=`echo /raid/LOG-G/slinker/tools/star/genomes/hg38`
#	genome=`echo /raid/LOG-G/slinker/tools/star/genomes/hg19`
#        date=`date`
#        prefix=`echo $file1 | awk '{split ($0,b,".fastq"); print b[1]}'`
##	prefix=`echo $prefix"_hg38"`
#	prefix=`echo $prefix"_hg19"`
#        echo "Running STAR on $file1 with prefix $prefix"
#        /raid/LOG-G/slinker/tools/star/STAR --genomeDir $genome --readFilesIn $file1 --runThreadN 4 --outFileNamePrefix $prefix
#        date=`date`
        ########## 
        ## GORILLA
        ##########

#	genome=`echo /raid/LOG-G/slinker/tools/star/genomes/gorgor3`
#        prefix=`echo $file1 | awk '{split ($0,b,".fastq"); print b[1]}'`
#        prefix=`echo $prefix"_gorgor3"`
#        echo "Running STAR on $file1 with prefix $prefix"
#        /raid/LOG-G/slinker/tools/star/STAR --genomeDir $genome --readFilesIn $file1 --runThreadN 4 --outFileNamePrefix $prefix
#        date=`date`

        ########## 
        ## CHIMP
        ##########

#	genome=`echo /raid/LOG-G/slinker/tools/star/genomes/pantro4`
#        prefix=`echo $file1 | awk '{split ($0,b,".fastq"); print b[1]}'`
#        prefix=`echo $prefix"_pantro4"`
#        echo "Running STAR on $file1 with prefix $prefix"
#        /raid/LOG-G/slinker/tools/star/STAR --genomeDir $genome --readFilesIn $file1 --runThreadN 4 --outFileNamePrefix $prefix
#        date=`date`


        ########## 
        ##  RHESUS
        ##########
#	genome=`echo /raid/LOG-G/slinker/tools/star/genomes/rhemac`
#        prefix=`echo $file1 | awk '{split ($0,b,".fastq"); print b[1]}'`
#        prefix=`echo $prefix"_rhemac"`
#        echo "Running STAR on $file1 with prefix $prefix"
#        /raid/LOG-G/slinker/tools/star/STAR --genomeDir $genome --readFilesIn $file1 --runThreadN 4 --outFileNamePrefix $prefix
#        date=`date`



#done


#######################
# Remove duplicated chr1 from human files (creates hg19_filt file)
#####################
#echo "Removing duplicated chr1 reads from human files"

#files=`ls *hg19Aligned.out.sam`

#for file in $files;
#	do
#		file2=`echo $file| sed s/.sam/_filt.sam/`
#		awk -F"\t" '{ if($3 != "chr1") {print $0}; if($3 == "chr1"){print $0; getline}  }' $file > $file2
#	done
    
#######################
# MergeSort
#####################
#echo "Running merge sort"


ls *hg19Aligned.out_filt.sam > samfiles_v2.txt
bash /raid/LOG-G/slinker/shell/shell/MergeAndSort.sh

 
   
#######################
# Remove reads with underscores (creates 4joinAligned.out_filt.sam)
#####################
#echo "Removing reads with underscores from merged and sorted file"

#files=`ls *4joinAligned.out.sam`

#for file in $files;
#	do
#		file2=`echo $file| sed s/.sam/_filt.sam/`
#		awk -F"\t" '{ if($3 !~ "_" && NF > 2) {print $0}}' $file > $file2
#	done
    
#######################
# Get the unique reads
#####################
#echo "Uniqueing the reads"

#ls *4joinAligned.out_filt.sam | awk '{printf $0 ",hg19,pantro4,gorgor3,rhemac\n" }' > 4join_human.txt
#bash /raid/LOG-G/slinker/shell/shell/sam_fourwise_uniq.sh 

########################
## 5) Run HtseqCount
########################
echo "Entering Htseq count portion"

bash /raid/LOG-G/slinker/shell/shell/htseq2.sh
#output currently saved in /raid/LOG-G/slinker/nhp/allcounts





