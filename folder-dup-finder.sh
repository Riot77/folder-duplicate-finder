<<<<<<< HEAD
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
=======
#!/bin/bash
#IFS=$(echo -en "\n\b")
IFS="
"

[[ "${@}" == *help* || "${#}" -eq "0" ]] && {
   echo This is help of usage
   echo " $0 [options] folder/path"
   echo "    options (!order): debug hidden"
   exit 0
}

Debug=false
echo -n "Debug mode with verbose output: "
[[ "${1}" == *debug* ]] && {
   Debug=true
   echo yes
   shift
} || echo no

echo -n "Listing hidden files: "
[[ "${1}" == *hidden* ]] && {
   shopt -s dotglob #without ! nullglob 
   echo yes
   shift
} || echo no

#RED='\033[0;31m'
BLUE='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
mainDir="${@}"
line=0
step=1
##LogFile=folder-`date +%Y%m%d-%H%M%S`.log        # Correct log file - contains list of folders with "same" content
##LogFile=folder.log                             # Debug log file
##echo "" > ${LogFile}                            # Reset log file

echo -n "Assembling the list of all folders ... "
allFolders="`find "${mainDir}" -type d`"        # Get list of all folders
echo "done".
CountAllFolders=`echo "${allFolders}" | wc -l`  # Count the number of all folder (for the progress bar)
AllSteps=`echo "scale=0; ${CountAllFolders} * (${CountAllFolders} - 1) / 2" | bc -l`  # Count the number of all folder (for the progress bar)
echo "${CountAllFolders} folders - there will be ${AllSteps} comparisons"

function foldersCompare(){
   ##DIFF=`diff -q --ignore-file-name-case "${origfolder}" "${comparefolder}" | grep -vE "^Common subdirectories:"`
   ( `ls -A "${1}/*" 2>/dev/null` || `ls -A "${2}/*" 2>/dev/null` ) || Similarity=0 
   #(( "`ls -A1 "${1}" |wc -l`" || "`ls -A1 "${2}" |wc -l`" )) || Similarity=0
   CountDiff=`diff -q --ignore-file-name-case "${origfolder}" "${comparefolder}" | grep -vE "^Common subdirectories:" | wc -l`
   ##Rsync1=`rsync -vudlptgoD -n --delete ${1}/* ${2}/ | wc -l`
   ##Rsync2=`rsync -vudlptgoD -n --delete ${2}/* ${1}/ | wc -l`
   ##FilesInSrcFld=`ls -a1 "${1}" | wc -l` # Two extra lines for "." and ".." folders
   ##FilesInDstFld=`ls -a1 "${2}" | wc -l` # Two extra lines for "." and ".." folders
   ##TotalFiles=`echo "${FilesInSrcFld} + ${FilesInDstFld} - 4" | bc -l` # Sum minus 2 lines from both count - the "." and ".."
   TotalFiles=`{ ls -A1 ${1} && ls -A1 ${2} ; } | wc -l`
   [[ "${TotalFiles}" -eq "0" ]] && Dissimilarity=1.0 || Dissimilarity=`echo "${CountDiff}/${TotalFiles}" | bc -l`
   Similarity=`echo "scale=3; 100 * (1.0 - ${Dissimilarity})" | bc -l` # Rsync outputs 4 extra lines that cannot be suppresed
   ##echo -n "   second folder contains files with same size "
   ##FoldersAreSame=false
   ##FilesInFolder=`ls -1 "${1}" | wc -l`
   ##SameFiles=0
   ##DIFF="`diff --ignore-file-name-case \"${1}\" \"${2}\"`"
   ##[[ "$?" -eq "0" ]] && echo "diff +" || echo "diff -"
   ##for eachFileInOrig in "${1}"/*; do
   ##   for eachFileInCompare in "${2}"/*; do
   ##      #echo -n "Comparing ${1}/$eachFileInOrig and ${2}/$eachFileInCompare"
   ##      SizeOrig=`stat --printf="%s" "${eachFileInOrig}"`
   ##      SizeComp=`stat --printf="%s" "${eachFileInCompare}"`
   ##      [[ "${SizeOrig}" -eq "${SizeComp}" ]] && { SameFiles=$((SameFiles+1)); continue; }
   ##   done
   ##done
   ##[[ "${SameFiles}" -eq "${FilesInFolder}" ]] && { echo -n "+, "; FoldersAreSame=true; return 1; } || { echo "-"; FoldersAreSame=false; return 0; }
   ##
   ##echo Similarity: $Similarity
   ##DIFF=`diff --ignore-file-name-case "${1}" "${2}"`
   ##cmp -n 1024 -s "${1}" "${2}"
   ( ${Debug} ) && {
      echo -------
      echo Dissimilarity = CountDiff/TotalFiles = ${CountDiff}/${TotalFiles} = ${Dissimilarity:0:5}
   }
   if (( `echo "${Similarity} == 100" | bc -l` )); then
      echo -e "${GREEN}100% ${NC}\t${1}/ ${2}/"
      ##| tee -a ${LogFile}
   elif (( `echo "${Similarity} > 0" | bc -l` )); then
      echo -e "${BLUE}${Similarity:0:5}%${NC}\t${1}/ ${2}/"
      ##| tee -a ${LogFile}
   else
      echo -e "${Similarity:0:5}%\t${1}/ ${2}/"
   fi
   ( ${Debug} ) && {
      echo "Total files $TotalFiles, similarity: $Similarity"
      echo CountDiff ${CountDiff}
      diff -q --ignore-file-name-case "${origfolder}" "${comparefolder}"
      echo -------
   }
}



SECONDS=0
for origfolder in ${allFolders}; do
   # echo $i
   lineMinusOne=${line}
   line=$((line+1))
   [[ "${line}" -eq "1" ]] && continue; #skip first folder, compare next folders with previus ones f.e. B -> A, C -> BA, D -> CBA ...
   #echo -n ${line}
   RemainingTime=`echo "scale=4; ${AllSteps}/${step}*${SECONDS}" | bc -l`
   for comparefolder in `echo "${allFolders}" | head -n ${lineMinusOne}`; do
      Percentage=`echo "scale=0; 100 * ${step}/${AllSteps}" | bc -l`
      step=$((step+1))
      echo -n "${Percentage}% (~${RemainingTime}s) "
      [[ "${origfolder}" != "${comparefolder}" ]] && {
         foldersCompare "${origfolder}" "${comparefolder}"
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
>>>>>>> restructured working
