#!/bin/bash

files=`cat samfiles_v2.txt`
#files=`ls CMb3_wt33_C_1_2_S3_R1_001_hg19Aligned.out_filt.sam`

#########################
###### FOURWISE
#########################


### Step 1: Add a tag to each sam file saying which species mapped to
for file in $files
	do
		echo "Tagging $file"
		##Tag human
		sed 's/$/ hg19/' $file > tmp1.txt

		##Tag chimp
		file2=`echo $file | sed s/_filt//`
		newfile=`echo $file2 | sed 's/hg19/pantro4/'`
		echo `ls $newfile`
		sed 's/$/ pantro4/' $newfile > tmp2.txt

		##Tag gorilla
                newfile=`echo $file2 | sed 's/hg19/gorgor3/'`
		echo `ls $newfile`
		sed 's/$/ gorgor3/' $newfile > tmp3.txt

		##Tag rhesus
                newfile=`echo $file2 | sed 's/hg19/rhemac/'`
		echo `ls $newfile`
		sed 's/$/ rhemac/' $newfile > tmp4.txt

		##CAT AND SORT
		echo "Sorting $file"
		joinfile=`echo $file2 | sed 's/hg19/4join/'`
		cat tmp1.txt tmp2.txt tmp3.txt tmp4.txt > tmp5.txt
		sort -k1 tmp5.txt > $joinfile
#		gzip $joinfile
	done


#rm tmp1.txt tmp2.txt tmp3.txt tmp4.txt

