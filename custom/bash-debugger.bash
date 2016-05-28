function bash-script-debugger () {
  PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }' \
    bash -x $1 2>&1 | \
      ts -i %.s | \
      perl -0pe 's/( (\+.+)\n(\d\.\d{6}))/\3 \2\n/g' | \
      perl -0pe 's/^\d\.\d{6}//' | \
      sed '$s/^/????????/g'
}
