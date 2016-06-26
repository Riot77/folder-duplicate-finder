#!/bin/bash
IFS=$(echo -en "\n\b")
IFS="
"
#shopt -s dotglob
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
mainDir="${@}"
allFolders="`find "${mainDir}" -type d`"
CountAllFolders=`echo "${allFolders}" | wc -l`
line=0
#LogFile=folder-`date +%Y%m%d-%H%M%S`.log
LogFile=folder.log
echo "" > ${LogFile}
for i in ${allFolders}; do
   # echo $i
   line=$((line+1))
   echo -n ${line}
   for j in `echo "${allFolders}" | tail -n +${line}`; do
      [[ "${i}" != "${j}" ]] && {
	 #echo aaa command DIFF=diff "${i}" "${j}"
         DIFF=`diff "${i}" "${j}"`
         [[ "$?" -eq "0" ]] && {
            echo -e "${GREEN} 100% same ${i} ${j} ${NC}"
            echo "100% same ${i} ${j}" >> ${LogFile}
         } || {
            LinesInDiff=`echo "${DIFF}" | wc -l` # Number of lines is equal to different files 
            FilesInFolder1=`ls -1 "${i}" | wc -l`
            FilesInFolder2=`ls -1 "${j}" | wc -l`
            TotalFiles=`echo "${FilesInFolder1} + ${FilesInFolder2}" | bc -l`
            Similarity=`echo "1 - (${LinesInDiff} / ${TotalFiles})" | bc -l`
            Percentage=`echo "scale=4; ${line}/${CountAllFolders}" | bc -l`
            #echo "Total files: $TotalFiles, difffiles: $LinesInDiff, similarity: $Similarity"
            echo -e "${Percentage}% - similar ${Similarity}% \t ${i} \t ${j}"
         }
      }
   done 
done
#
#ExclAlrdyChecked=""
#function subdir(){
#   [[ -d ${1} ]] && {
#      ExclAlrdyChecked=' ! -path "'$1'"'" $ExclAlrdyChecked"
#      content=`ls ${1}`
#       diff -r ${1} {} && [[ "$?" -eq "0" ]] && echo same folders 
#      find ${1} -type d 
#      echo ${1}
#      local EachFile=""
#      for EachFile in ${1}/*; do
#         subdir $EachFile
#      done
#   }
#}
#
#subdir ${1}
