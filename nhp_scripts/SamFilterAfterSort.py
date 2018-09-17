#!/usr/bin/env python
#####################
## import libraries
#####################


import sys
import gzip
import re
import argparse

#####################
## Argument handeling
#####################

parser = argparse.ArgumentParser(description = "Filter sam files. Note: Input must be filtered on READ ID. Prior to sort, id must have a species tag added . (Also, get rid of the header)Example: sed \'s/$/ species/\' . Then concatenate and sort with cat file | sort -k1 ", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('--f', default = "test.txt", help='Sorted file that will be filtered.  ')
parser.add_argument('--outf', default = "out.txt", help='Output file')
parser.add_argument('--RefSpecies', default = "hg19", help='Note: USE SAME SPELLING AS IN THE FILE . If aligned to more than one species this variable determines which species is used as the reference for final output. Options, f1, f2, or f3')
parser.add_argument('--SameSpecies', default = "hg19", help = 'The species that the sample came from' )
parser.add_argument('--SpeciesToCheck', default = "hg19", help='Comma delimited list of species. This allows you to merge all species into one file, and just check the ones you.re interested in. Ex: hg19,pantro4.')
parser.add_argument('--maxMSame', type = int, default = 3, help='Maximum number of mismatches from reference (within the same species)')
parser.add_argument('--maxMDif', type = int, default = 5, help='Maximum number of mismatches from reference (across different species)')
parser.add_argument('--minbp', type = int, default = 90, help='Minimum length of a read to pass filter')
parser.add_argument('--maxLocs', type = int, default = 3, help='Maximum number of locations if using pickTop')
parser.add_argument('--Same_method', default = "pickTop", help='Method of keeping/excluding multimappers ( pickTop=Note: restricts multimaps to maxLocs and then picks the best map |  unique = read only maps in one location |  multimap = best location is printed for every read, no min locations. Extra column indicates the number of locations per read | duplicated = only reads that map in multiple locations.Extra column indicates the number of locations per read )')
parser.add_argument('--Dif_method', default = "multimap", help='Method of keeping/excluding multimappers ( Same definitions as Same_method)')

args = parser.parse_args()

#####################
## Define functions
#####################
# This function filters the reads based on the multimap option and decides whether or not to print
def decision(output, RefSpecies, Same_method, Dif_method, maxLocs):
	ToBePrinted = 0
	for species in output:
		if species == RefSpecies:
			if re.match(Same_method ,'unique'):
				if len(output[species]) == 1:
					ToBePrinted += 1
			elif re.match(Same_method ,'pickTop'):
				if len(output[species]) < maxLocs:
					if len(output[species]) > 1:
						check_dup = [x[0][1] for x in output[species]]
						if len(set(check_dup)) == 1: #Make sure length is greater than 1 and if IDs aren't duplicated in sam file
							ToBePrinted += 1
					elif len(output[species]) == 1: #If length is 1, this is basically unique option
						ToBePrinted += 1
			elif re.match(Same_method ,'duplicated'):
				if len(output[species]) > 1:
					ToBePrinted += 1
			elif re.match(Same_method ,'multimap'):
				ToBePrinted += 1
		else:
			if re.match(Dif_method ,'unique'):
				if len(output[species]) == 1:
					ToBePrinted += 1
			elif re.match(Dif_method ,'pickTop'):
				if len(output[species]) < maxLocs:
					if len(output[species]) > 1:
						check_dup = [x[0][1] for x in output[species]]
						if len(set(check_dup)) == 1: #Make sure length is greater than 1 and if IDs aren't duplicated in sam file
							ToBePrinted += 1
					elif len(output[species]) == 1: #If length is 1, this is basically unique option
						ToBePrinted += 1
			elif re.match(Dif_method ,'duplicated'):
				if len(output[species]) > 1:
					ToBePrinted += 1
			elif re.match(Dif_method ,'multimap'):
				ToBePrinted += 1
	return(ToBePrinted)

#####################
## Initialize Variables
#####################
fh = args.f
mmSame = args.maxMSame
mmDif = args.maxMDif
Same_method = args.Same_method
Dif_method = args.Dif_method
minbp = args.minbp
maxLocs = args.maxLocs
RefSpecies = args.RefSpecies
SameSpecies = args.SameSpecies
speciesTocheck= args.SpeciesToCheck
sumofspecies = len(speciesTocheck.split(","))

current_id = []
output = {}
mismatch = 0

with open(args.outf,'w') as of:
	with open(fh,'rb') as files:
		for line in files:
			if line.split()[0] !="@SQ": #Skip header info
				line = line.rstrip('\n')
				full = line.split()
				species = full[-1]
				if re.search(species, speciesTocheck) and len(full[2].split('_')) == 1: #Only filter lines for species of interest and normal chromosome alignments
					current_id.append(full[0])
					newid = full[0]
					if newid != current_id[0]: #Change in ID leads to output of previous IDs sam lines
						if len(output) >= 1: #Make sure output values are present as IDs with no passing reads can't be inputs to our function
							(ToBePrinted) = decision(output, RefSpecies ,Same_method ,Dif_method, maxLocs)
							if ToBePrinted == sumofspecies: #Testing if all the method qualifications are met
								of.write(str(output[RefSpecies][0][1] + "\t" + str(len(output[RefSpecies])) + "\n")) #Choose the first read as this represents highest quality M value (pickTop accounted for with duplicates)	
						current_id = [newid] #Reset all the variables for new ID
						output = {}
						mismatch = 0
					quality = full[5]
					linelength = len(full[9])
					if linelength > minbp: #Check minimum bp filter
						char = [(i.start()) for i in list(re.finditer('[a-zA-Z]', quality))]
						char.append(-1)
						char = sorted(char)
						m = [(i.start()) for i in list(re.finditer('M', quality))]
						if(sum(char) > -1):
							M = []
							for j in range(0,len(char)-1):
								if char[j+1] in m:
									M.append(int(quality[char[j]+1:char[j+1]]))
									totalM = sum(M) #Quality filter by accumulating all M values of particular read
						if (species == SameSpecies and totalM > (linelength - mmSame)) or (species != SameSpecies and totalM > (linelength - mmDif)):
							start_pos = full[3]
							if species in output: #Library for all reads with the same ID, separated by species
								if totalM == output[species][0][0][0]: #Reads with same quality will get appended for later filtering
									output[species].append(((totalM, start_pos), line))
								elif totalM > output[species][0][0][0]: #Reads with better quality will replace the current read with lower quality
									output[species] = [((totalM, start_pos), line)]	
							else:
								output[species] = [((totalM, start_pos), line)] #Initializing the dictionary
			else:
				(ToBePrinted) = decision(output, RefSpecies ,Same_method ,Dif_method, maxLocs)
				if ToBePrinted == sumofspecies: #Testing if all the method qualifications are met
					of.write(str(output[RefSpecies][0][1] + "\t" + str(len(output[RefSpecies])) + "\n"))		

