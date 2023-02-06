#!bin/bash

module load samtools


Help() {
    echo "usage: CG_ratio [-i|h]"
    echo "description: CG_ratio is a bash script that is use for counting CG-pattern content"
    echo "             at 1,2 and 2,3 residues of cfDNA"
    echo "optional argruments:"
    echo "    -i              Input file path (BAM file)"
    echo "    -c              CG-counting (YES/NO)"
    echo "    -h              Show this help message and exit"
    echo
    echo "author's email:"
    echo "    songphon_sutthittha@cmu.ac.th"
    echo
    echo "** Please contact us if you have any questions or problems with this script."
    echo "------------------------------------------------------------------------------------------"
}

while getopts ":hi:c:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      i) # default [Current directory]
         name=${OPTARG};;
      c) # default [Current directory]
         cg_ratio=${OPTARG};;
     \?) # Invalid option
         echo "Error: Unrecognized arguments"
         exit;;
   esac
done

NAME=`echo ${name}| cut -d. -f1`

if [ -f SORT_BAM ]
then
   mkdir SORT_BAM
fi

if [ -f SORT_BAM/CG_ratio ]
then
   mkdir SORT_BAM/CG_ratio
fi

if [ -f SORT_BAM/CG_ratio/SORT_150 ]
then
   mkdir SORT_BAM/CG_ratio/SORT_150
fi

if [ -f SORT_BAM/CG_ratio/SORT_167 ]
then
   mkdir SORT_BAM/CG_ratio/SORT_167
fi

if [ -f SORT_BAM/CG_ratio/MORE_150 ]
then
   mkdir SORT_BAM/CG_ratio/MORE_150
fi

if [ -f SORT_BAM/CG_ratio/MORE_167 ]
then
   mkdir SORT_BAM/CG_ratio/MORE_167
fi

cd SORT_BAM

echo "***Sorting process is starting!"
echo ">>Sorting process -------------------------------------------------- (0%)"

if (( ` ls -l | grep ".bam" | wc -l` < 4 ))
then

   #BAM sort
   if [ ! -f ${NAME}_SORT_150.bam ]
   then
      samtools view -h ../${NAME}.bam | \
      awk 'substr($0,1,1)=="@" || ($9 >= -150 && $9 <= 150 && $9 != 0)' | \
      samtools view -b > ${NAME}_SORT_150.bam
      echo "***Success; ${NAME}_SORT_150.bam is sorted!"
   fi
   echo ">>Sorting process ===========>-------------------------------------- (25%)"
   if [ ! -f ${NAME}_SORT_167.bam ]
   then
      samtools view -h ../${NAME}.bam | \
      awk 'substr($0,1,1)=="@" || ($9 > -167 && $9 < 167 && $9 != 0)' | \
      samtools view -b > ${NAME}_SORT_167.bam
      echo "***Success; ${NAME}_SORT_167.bam is sorted!"
   fi
   echo ">>Sorting process ========================>------------------------- (50%)"
   if [ ! -f ${NAME}_MORE_150.bam ]
   then
      samtools view -h ../${NAME}.bam | \
      awk 'substr($0,1,1)=="@" || ($9 < -150 ) || ($9 > 150)' | \
      samtools view -b > ${NAME}_MORE_150.bam
      echo "***Success; ${NAME}_MORE_150.bam is sorted!"
   fi
   echo ">>Sorting process ====================================>------------- (75%)"
   if [ ! -f ${NAME}_MORE_167.bam ]
   then
      samtools view -h ../${NAME}.bam | \
      awk 'substr($0,1,1)=="@" || ($9 <= -167) || ($9 >= 167)' | \
      samtools view -b > ${NAME}_MORE_167.bam
      echo "***Success; ${NAME}_MORE_167.bam is sorted!"
   fi
   echo ">>Sorting process =================================================> (100%)"
else
   echo "***All sorted BAM is exist"
   echo ">>Sorting process =================================================> (100%)"
fi

sort150="${NAME}_SORT_150"
sort167="${NAME}_SORT_167"
more150="${NAME}_MORE_150"
more167="${NAME}_MORE_167"

FLAGSTAT() {
   if [ ! -f ${sort150}_flag.txt ]
   then
      samtools flagstat ${sort150}.bam > ${sort150}_flag.txt
      echo "***Success; ${sort150}_flag.txt is extracted!"
   else
      echo "***PASS; ${sort150}_flag.txt file is exist"
   fi
   if [ ! -f ${sort167}_flag.txt ]
   then
      samtools flagstat ${sort167}.bam > ${sort167}_flag.txt
      echo "***Success; ${sort167}_flag.txt is extracted!"
   else
      echo "***PASS; ${sort167}_flag.txt file is exist"
   fi
   if [ ! -f ${more150}_flag.txt ]
   then
      samtools flagstat ${more150}.bam > ${more150}_flag.txt
      echo "***Success; ${more150}_flag.txt is extracted!"
   else
      echo "***PASS; ${more150}_flag.txt file is exist"
   fi
   if [ ! -f ${more167}_flag.txt ]
   then
      samtools flagstat ${more167}.bam > ${more167}_flag.txt
      echo "***Success; ${more167}_flag.txt is extracted!"
   else
      echo "***PASS; ${more167}_flag.txt file is exist"
   fi
}

CG_SEP() {
   if [ ! -f CG_ratio/SORT_150/${sort150}_CG_2_3.txt ]
   then
      samtools view ${sort150}.bam | cut -f10 | cut -c 2,3 | grep "CG" > CG_ratio/SORT_150/${sort150}_CG_2_3.txt
      if [ ! -f CG_ratio/SORT_150/${sort150}_CG_1_2.txt ]
      then
         samtools view ${sort150}.bam | cut -f10 | cut -c 1,2 | grep "CG" > CG_ratio/SORT_150/${sort150}_CG_1_2.txt
      fi
      echo "***Success; CG count at 1,2 & 2,3 of ${sort150} is extracted!"
   else
      echo "***PASS; ${sort150} CG count is exist"
   fi
   if [ ! -f CG_ratio/SORT_167/${sort167}_CG_2_3.txt ]
   then
      samtools view ${sort167}.bam | cut -f10 | cut -c 2,3 | grep "CG" > CG_ratio/SORT_167/${sort167}_CG_2_3.txt
      if [ ! -f CG_ratio/SORT_167/${sort167}_CG_1_2.txt ]
      then
         samtools view ${sort167}.bam | cut -f10 | cut -c 1,2 | grep "CG" > CG_ratio/SORT_167/${sort167}_CG_1_2.txt
      fi
      echo "***Success; CG count at 1,2 & 2,3 of ${sort167} is extracted!"
   else
      echo "***PASS; ${sort167} CG count is exist"   
   fi
   if [ ! -f CG_ratio/MORE_150/${more150}_CG_2_3.txt ]
   then
      samtools view ${more150}.bam | cut -f10 | cut -c 2,3 | grep "CG" > CG_ratio/MORE_150/${more150}_CG_2_3.txt
      if [ ! -f CG_ratio/MORE_150/${more150}_CG_1_2.txt ]
      then
         samtools view ${more150}.bam | cut -f10 | cut -c 1,2 | grep "CG" > CG_ratio/MORE_150/${more150}_CG_1_2.txt
      fi
      echo "***Success; CG count at 1,2 & 2,3 of ${more150} is extracted!"
   else
      echo "***PASS; ${more150} CG count is exist"
   fi
   if [ ! -f CG_ratio/MORE_167/${more167}_CG_2_3.txt ]
   then
      samtools view ${more167}.bam | cut -f10 | cut -c 2,3 | grep "CG" > CG_ratio/MORE_167/${more167}_CG_2_3.txt
      if [ ! -f CG_ratio/MORE_167/${more167}_CG_1_2.txt ]
      then
         samtools view ${more167}.bam | cut -f10 | cut -c 1,2 | grep "CG" > CG_ratio/MORE_167/${more167}_CG_1_2.txt
      fi
      echo "***Success; CG count at 1,2 & 2,3 of ${more167} is extracted!"
   else
      echo "***PASS; ${more167} CG count is exist"
   fi
}

CG_COUNT() {
   if [ -f ${sort150}.bam ]
   then
      wc -l CG_ratio/SORT_150/${sort150}_CG_1_2.txt
      wc -l CG_ratio/SORT_150/${sort150}_CG_2_3.txt
   fi
   
   if [ -f ${sort167}.bam ]
   then
      wc -l CG_ratio/SORT_167/${sort167}_CG_1_2.txt
      wc -l CG_ratio/SORT_167/${sort167}_CG_2_3.txt
   fi
   
   if [ -f ${more150}.bam ]
   then
      wc -l CG_ratio/MORE_150/${more150}_CG_1_2.txt
      wc -l CG_ratio/MORE_150/${more150}_CG_2_3.txt
   fi
   
   if [ -f ${more167}.bam ]
   then
      wc -l CG_ratio/MORE_167/${more167}_CG_1_2.txt
      wc -l CG_ratio/MORE_167/${more167}_CG_2_3.txt
   fi  
}

if (( "${cg_ratio}" == "YES" ))
then

   echo "***Counting process is starting!"
   echo ">>Counting process -------------------------------------------------- (0%)"
   echo ">>Counting process ===========>-------------------------------------- (25%)"

   FLAGSTAT

   echo ">>Counting process ========================>------------------------- (50%)"

   CG_SEP

   echo ">>Counting process ====================================>------------- (75%)"

   CG_COUNT

   echo ">>Counting process =================================================> (100%)"

   cd ../
   echo "***Your CG counting process is already finish!"

elif (( "${cg_ratio}" == "NO" ))
then
   exit
fi
