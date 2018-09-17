files=`cat 4join_human.txt`

#files=`cat 4join_human_37CM.txt`

for file in $files;
do
input=`echo $file | awk '{ split($0,a,","); print a[1] }'`
output=`echo $file | awk '{ split($0,a,","); print a[1] }' | sed 's/_4joinAligned.out_filt.sam/_fourwise_hg19_pantro4_gorgor3_rhemac_uniq.sam/'`
species=`echo $file | awk '{ split($0,a,","); print a[2] }'`
date=`date`
echo "Performing fourwise sam filter on $input with output file $output | Species: $species | Date: $date"
python /raid/LOG-G/slinker/python/SamFilterAfterSort_jyh023_v4_removehapchr.py --f $input --outf $output --RefSpecies hg19 --SameSpecies $species --SpeciesToCheck hg19,pantro4,gorgor3,rhemac --Same_method unique --Dif_method unique --minbp 50
echo "Done"
done
