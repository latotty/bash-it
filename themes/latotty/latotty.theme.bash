#!/usr/bin/env bash
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" |"
SCM_THEME_PROMPT_SUFFIX="${green}|"

GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${green}|"
GIT_THEME_PROMPT_SUFFIX="${green}|"

function last_command {
  ETIME=$(execute_time)
  LSTATUS=$(last_status)
  case "$LSTATUS" in
    0)
      echo -e "${green}${ETIME}"
      ;;
    *)
      echo -e "${red}${ETIME} ($LSTATUS)"
      ;;
  esac
}

function current_aws_profile {
  if [ -n "$AWS_DEFAULT_PROFILE" ]; then
    echo -e " [${AWS_DEFAULT_PROFILE}@AWS]"
  fi
}

function prompt_command() {
  PS1="\n${green}\w ${bold_cyan}$(scm_char)${green}$(scm_prompt_info)$(current_aws_profile) $(last_command)\n ${green}→${reset_color} "
}

PROMPT_COMMAND=prompt_command;
