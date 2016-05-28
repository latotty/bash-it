#!/usr/bin/env bash

# This variable describes whether we are currently in "interactive mode";
# i.e. whether this shell has just executed a prompt and is waiting for user
# input.  It documents whether the current command invoked by the trace hook is
# run interactively by the user; it's set immediately after the prompt hook,
# and unset as soon as the trace hook is run.
et_preexec_interactive_mode=""

# Default do-nothing implementation of preexec.
function et_preexec () {
    true
}

# Default do-nothing implementation of precmd.
function et_precmd () {
    true
}

# Default do-nothing implementation of precmd.
function et_preprompt () {
    true
}

# This function is installed as the PROMPT_COMMAND; it is invoked before each
# interactive prompt display.  It sets a variable to indicate that the prompt
# was just displayed, to allow the DEBUG trap, below, to know that the next
# command is likely interactive.
function et_preexec_invoke_cmd () {
    et_precmd
    et_preexec_interactive_mode="yes"
}

# This function is installed as the PROMPT_COMMAND; it is invoked before each
# interactive prompt display.  It sets a variable to indicate that the prompt
# was just displayed, to allow the DEBUG trap, below, to know that the next
# command is likely interactive.
function et_preprompt_invoke_cmd () {
    et_preprompt
    et_preexec_interactive_mode="yes"
}

# This function is installed as the DEBUG trap.  It is invoked before each
# interactive prompt display.  Its purpose is to inspect the current
# environment to attempt to detect if the current command is being invoked
# interactively, and invoke 'preexec' if so.
function et_preexec_invoke_exec () {
    if [[ -n "$COMP_LINE" ]]
    then
        # We're in the middle of a completer.  This obviously can't be
        # an interactively issued command.
        return
    fi
    if [[ -z "$et_preexec_interactive_mode" ]]
    then
        # We're doing something related to displaying the prompt.  Let the
        # prompt set the title instead of me.
        return
    else
        # If we're in a subshell, then the prompt won't be re-displayed to put
        # us back into interactive mode, so let's not set the variable back.
        # In other words, if you have a subshell like
        #   (sleep 1; sleep 2)
        # You want to see the 'sleep 2' as a set_command_title as well.
        if [[ 0 -eq "$BASH_SUBSHELL" ]]
        then
            et_preexec_interactive_mode=""
        fi
    fi
    if [[ "et_preexec_invoke_cmd" == "$BASH_COMMAND" ]]
    then
        # Sadly, there's no cleaner way to detect two prompts being displayed
        # one after another.  This makes it important that PROMPT_COMMAND
        # remain set _exactly_ as below in preexec_install.  Let's switch back
        # out of interactive mode and not trace any of the commands run in
        # precmd.

        # Given their buggy interaction between BASH_COMMAND and debug traps,
        # versions of bash prior to 3.1 can't detect this at all.
        et_preexec_interactive_mode=""
        return
    fi

    # In more recent versions of bash, this could be set via the "BASH_COMMAND"
    # variable, but using history here is better in some ways: for example, "ps
    # auxf | less" will show up with both sides of the pipe if we use history,
    # but only as "ps auxf" if not.
    local this_command=`history 1 | sed -e "s/^[ ]*[0-9]*[ ]*//g"`;

    # If none of the previous checks have earlied out of this function, then
    # the command is in fact interactive and we should invoke the user's
    # preexec hook with the running command as an argument.
    et_preexec "$this_command"
}

# Execute this to set up preexec and precmd execution.
function et_preexec_install () {

    # *BOTH* of these options need to be set for the DEBUG trap to be invoked
    # in ( ) subshells.  This smells like a bug in bash to me.  The null stderr
    # redirections are to quiet errors on bash2.05 (i.e. OSX's default shell)
    # where the options can't be set, and it's impossible to inherit the trap
    # into subshells.

    set -o functrace > /dev/null 2>&1
    shopt -s extdebug > /dev/null 2>&1

    # Finally, install the actual traps.
    PROMPT_COMMAND="et_preprompt_invoke_cmd;${PROMPT_COMMAND};et_preexec_invoke_cmd"
    trap 'et_preexec_invoke_exec' DEBUG
}

TIMER_SHOW=0

function execute_time () {
  echo -e "${TIMER_SHOW}s"
}

function last_status () {
  echo -e $LAST_STATUS
}

# These functions are defined here because they only make sense with the
# preexec_install below.
function et_precmd () {
  unset TIMER
}

function et_preprompt () {
  LAST_STATUS="$?"
  if [[ $TIMER ]]; then
    TIMER_SHOW=$(($SECONDS - $TIMER))
  fi
}

function et_preexec () {
  TIMER=${TIMER:-$SECONDS}
}

et_preexec_install
