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

main() {
  clear
  local script_to_check="$1"
  local line_number=0
  local shfmt_file="shfmt_log.txt"
  local linecheck_file="linecheck_log.txt"
  local shellcheck_file="shellcheck_log.txt"
  
  local log_line=""
  
  delete_file "${shfmt_file}"
  delete_file "${linecheck_file}"
  delete_file "${shellcheck_file}"
  
  echo "=========================================================="
  echo "== running shfmt"
  echo "=========================================================="
  shfmt -l -ln bash -i 2 -d -ci -kp -w "${script_to_check}" > "${shfmt_file}"
  cat "${shfmt_file}"
  echo "=========================================================="
  echo "== running shellcheck"
  echo "=========================================================="
  shellcheck "${script_to_check}" > "${shellcheck_file}"
  cat "${shellcheck_file}"
  echo "=========================================================="
  echo "== checking linelengths <= 100 "
  echo "=========================================================="
  touch "${linecheck_file}"
  while IFS= read -r line || [ -n "$line" ];
  do 
      line_number=$((line_number+1))
      [ "${#line}" -gt 100 ] && printf "LINE: ${line_number}, CHARS: ${#line} : %s\n" "$line" \
      >> "${linecheck_file}"
  done < "${script_to_check}"
  cat "${linecheck_file}"
 
  
}


main "$1"
