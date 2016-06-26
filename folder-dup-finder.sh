#!/bin/bash
#IFS=$(echo -en "\n\b")
IFS="
"
#shopt -s dotglob
#RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
mainDir="${@}"
allFolders="`find "${mainDir}" -type d`"        # Get list of all folders
CountAllFolders=`echo "${allFolders}" | wc -l`  # Count the number of all folder (for the progress bar)
line=0
LogFile=folder-`date +%Y%m%d-%H%M%S`.log        # Correct log file - contains list of folders with "same" content
#LogFile=folder.log                             # Debug log file
echo "" > ${LogFile}                            # Reset log file
for origfolder in ${allFolders}; do
   # echo $i
   line=$((line+1))
   echo -n ${line}
   for comparefolder in `echo "${allFolders}" | tail -n +${line}`; do
      [[ "${origfolder}" != "${comparefolder}" ]] && {
         DIFF=`diff "${origfolder}" "${comparefolder}"`
         [[ "$?" -eq "0" ]] && {
            echo -e "${GREEN} 100% same ${origfolder} ${comparefolder} ${NC}"
            echo "100% same ${origfolder} ${comparefolder}" >> ${LogFile}
         } || {
            LinesInDiff=`echo "${DIFF}" | wc -l` # Number of lines is equal to different files 
            FilesInOrigFolder=`ls -1 "${origfolder}" | wc -l`
            FilesInCompareFolder=`ls -1 "${comparefolder}" | wc -l`
            TotalFiles=`echo "${FilesInOrigFolder} + ${FilesInCompareFolder}" | bc -l`
            Similarity=`echo "1 - (${LinesInDiff} / ${TotalFiles})" | bc -l`
            Percentage=`echo "scale=4; ${line}/${CountAllFolders}" | bc -l`
            #echo "Total files: $TotalFiles, difffiles: $LinesInDiff, similarity: $Similarity"
            echo -e "${Percentage}% - similar ${Similarity}% \t ${origfolder} \t ${comparefolder}"
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
