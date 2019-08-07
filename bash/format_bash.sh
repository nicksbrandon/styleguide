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
# will run shfmt, shellcheck and line length script on bash file to ensure it 
# conforms to coding standards

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

repeat () {

  local output=""
  local start=1
  local end=$2

  for i in $(seq $start $end); do
      output="${1}${output}"
  done

  echo "${output}"

}
#######################################
# Check first par begins with second par
# Globals:
# Arguments:
#  * par 1 : whole string
#  * par 2 : start string
# Returns:
#   true/false
#######################################
endswith() 
{ 
  case $2 in *"$1") true;; *) false;; esac; 
}

comment_out_exclusions() {
  local script_in="$1"
  local script_out="$2"
  local start_exclusion="## START EXCLUSION"
  local end_exclusion="## END EXCLUSION"
  local exclude_line="FALSE"
  local char_count="0"
  local padding="0"
  local prefix=""
  
  delete_file "${script_out}"
  while IFS= read -r line
  do
    if endswith "${start_exclusion}" "${line}"; then
      exclude_line="TRUE"
      ## get number of characters in line
      char_count=$(echo -n "${line}" | wc -c)
      ## This determines how many spaces prefix the start_exclusion
      $((padding=char_count-18))
      prefix=$(repeat " " "${padding}")
    fi
    if endswith "${end_exclusion}" "${line}"; then
      exclude_line="FALSE"
    fi
    if [ "${exclude_line}" = "TRUE" ];then
      ## just insert a commented line with prefix of spaces
      ## if you don't have this the formatter attempts to format the comment
      ## so the lint process will generate error even though it should be skipped
      line="${prefix}# EXCLUDED LINE"
    fi
    echo "${line}" >> "${script_out}"
  done < "${script_in}"
    
}

check_script() {
  local script_to_check="$1"
  local change_file="$2"
  
  local temp_file="__temp.sh"

  local throw_error_on_issue="TRUE"

  echo "*** checking: ${script_to_check}"
  
  ## if no change to be made to the script then create a temp copy to run the tests on
  delete_file "${temp_file}"
  if [ "${change_file}" = "FALSE" ];then
    comment_out_exclusions "${script_to_check}" "${temp_file}"
    script_to_check="${temp_file}"
  fi
  
  local line_number=0
  local shfmt_file="shfmt_log.txt"
  local linecheck_file="linecheck_log.txt"
  local shellcheck_file="shellcheck_log.txt"
  local log_output_digest="log_output_digest.txt"
  
  local file_size="0"
  
  local log_line=""
  
  delete_file "${shfmt_file}"
  delete_file "${linecheck_file}"
  delete_file "${shellcheck_file}"
  delete_file "${log_output_digest}"
  
  echo "==========================================================" >> "${log_output_digest}"
  echo "== running shfmt" >> "${log_output_digest}"
  echo "==========================================================" >> "${log_output_digest}"
  shfmt -l -ln bash -i 2 -d -ci -kp -w "${script_to_check}" > "${shfmt_file}"
  cat "${shfmt_file}" >> "${log_output_digest}"
  echo "==========================================================" >> "${log_output_digest}"
  echo "== running shellcheck" >> "${log_output_digest}"
  echo "==========================================================" >> "${log_output_digest}"
  shellcheck "${script_to_check}" > "${shellcheck_file}"
  cat "${shellcheck_file}" >> "${log_output_digest}"
  echo "==========================================================" >> "${log_output_digest}"
  echo "== checking linelengths <= 100 " >> "${log_output_digest}"
  echo "==========================================================" >> "${log_output_digest}"
  touch "${linecheck_file}"
  while IFS= read -r line || [ -n "$line" ];
  do 
      line_number=$((line_number+1))
      [ "${#line}" -gt 100 ] && printf "LINE: ${line_number}, CHARS: ${#line} : %s\n" "$line" \
      >> "${linecheck_file}"
  done < "${script_to_check}"
  cat "${linecheck_file}" >> "${log_output_digest}"


  ## loop through logs
  list_of_logs="${shfmt_file}
${shellcheck_file}
${linecheck_file}"

  ## if any of the log files are greater than 0 bytes then exit
  for log_file in ${list_of_logs}
  do
    ## now check the the file size
    file_size=$(wc -c "${log_file}" | awk '{print $1}')
    if [ "${file_size}" != "0" ];then
      cat "${log_output_digest}"
      echo "There are errors (${log_file})."
      exit 1
    fi  
  done
  
  echo "no errors"

}

main() {
  check_script "$1" "$2"
}


## handle input parameters
if [ "$#" -eq  "0" ];then
  echo "You must provide a script to check"
  exit 1
fi
if [ "$#" -eq  "1" ];then
  main "$1" "TRUE"
fi
if [ "$#" -eq  "2" ];then
  main "$1" "$2"
fi
