#!/bin/bash
set -u
#
#  ECHOBOX CONFIDENTIAL
#
#  All Rights Reserved.
#
#  NOTICE: All information contained herein is, and remains the property of
#  Echobox Ltd. and itscheck_environment_selection suppliers, if any. The
#  intellectual and technical concepts contained herein are proprietary to
#  Echobox Ltd. and its suppliers and may be covered by Patents, patents in
#  process, and are protected by trade secret or copyright law. Dissemination
#  of this information or reproduction of this material, in any format, is
#  strictly forbidden unless prior written permission is obtained
#  from Echobox Ltd.
#
# Loop through all .sh files in a folder and call 

#######################################
# Delete file if exists
# Globals:
# Arguments:
#  * par 1 : file to delete
# Returns:
#   None
#######################################
delete_file() {
  if [ -f "$1" ]; then
    rm "$1"
  fi
}

#######################################
# If exclusion file in the same directory - and lists the script then it will be 
# excluded from checks
# Globals:
# Arguments:
#  * par 1 : script to check eg test.sh
#  * par 2 : full path to the exclusion file
# Returns:
#   TRUE if to be excluded - else FALSE
#######################################
check_if_script_excluded() {
  local script_name="$1"
  local exclusion_file="$2"
    
  local script_name_find=""
  local return_value="FALSE"
  
  ## check if the exclusion file exists  
  if [ -f "${exclusion_file}" ]; then
    script_name_find=$(grep -Fx "${script_name}" "${exclusion_file}")
    if [ "${script_name}" = "${script_name_find}" ];then
      return_value="TRUE"
    fi
  fi
  
  echo "${return_value}"
}

#######################################
# Find all .sh scripts in specified directory
# check to see if excluded from checks
# if not then call format_bash.sh on script
# will check all the files even if error met on early file
# will return error if any script has errors 
# Globals:
# Arguments:
#  * par 1 : directory to check
#  * par 2 : whether or not to modify the scripts the file
# Returns:
#   exit script with non zero code if any problems met
#######################################
call_format_bash_on_files_in_directory() {
  
  local base_dir="$1"
  local change_file="$2"
  local exit_code="0"
  local errors_returned="FALSE"
  
  local exclusion_file="${base_dir}/${EXCLUSION_FILE}"
  local exclude_file="FALSE"
  
  file_path="${base_dir}/*.sh"
  ## note file_path should not have quotes around it
  for file in $file_path
  do
    base_file=$(basename $file)
    exclude_file=$(check_if_script_excluded "${base_file}" "${exclusion_file}")
    
    echo "Processing ${file}"
    if [ "${exclude_file}" = "FALSE" ];then
      #echo "base name: ${base_file}"
      sh format_bash.sh "${file}" "${change_file}"
      exit_code="$?"
      
      ## if hit error then exit the wrapper with error
      if [ "$exit_code" != "0" ];then
        echo "FAILED"
        errors_returned="TRUE"
      else
        echo "SUCCESS"
      fi
    else
      echo "file excluded - skipping"
    fi
    echo "==========================================="
  done
  
  ## now check if any errors - if so then throw error
  if [ "${errors_returned}" = "TRUE" ];then
    echo "THERE WERE ERRORS IN THE BASH SCRIPTS."
    exit 1
  fi
}

#######################################
# Find directories from a root down which have .sh scripts
# call call_format_bash_on_files_in_directory for each directory
# In this way can check all .sh files in one call
# Globals:
# Arguments:
#  * par 1 : directory to check
#  * par 2 : whether or not to modify the scripts the file
# Returns:
#   exit script with non zero code if any problems met
#######################################
get_all_directories_with_sh_scripts() {
  local base_dir="$1"
  local change_file="$2"  
  
  echo "base dir: ${base_dir}"
  file_list_file="file_list.txt"
  directory_list_file="directory_list.txt"
  directory_list_file_no_dups="directory_list_no_dups.txt"

  delete_file "${directory_list_file_no_dups}"

  find "${base_dir}" -type f -name '*.sh' > "${file_list_file}"
  while IFS= read -r line
  do
    base_directory=${line%/*}
    echo "$base_directory" >> "${directory_list_file}"
  done < "${file_list_file}"

  ## remove duplicate lines
  ## sort "${directory_list_file}" | uniq -u > "${directory_list_file_no_dups}"
  sort -u "${directory_list_file}" > "${directory_list_file_no_dups}"
  
  ## cleanup
  delete_file "${directory_list_file}"
  delete_file "${file_list_file}"
  
  ## now loop through the directories checking scripts
  ## if there are errors in a directory then will fail for that directory
  while IFS= read -r line
  do
    call_format_bash_on_files_in_directory "${line}" "${change_file}"
  done < "${directory_list_file_no_dups}"
}

main() {
  ## should always be ran in readonly mode - ie.  dont change th scripts.
  clear
  local change_file="FALSE"
  get_all_directories_with_sh_scripts "$1" "${change_file}"
}

## global variable
## if this file is in the same directory and lists the script then it will be excluded from checks
readonly EXCLUSION_FILE="bash_style_exclude.txt"

## handle input parameters
if [ "$#" -eq "0" ];then
  echo "You must provide a folder to check"
  exit 1
fi

if [ "$#" -eq "1" ];then
  main "$1"
fi

