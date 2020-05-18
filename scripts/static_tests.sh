#!/usr/bin/env bash
HELP_USAGE="usage: $(basename "$0")  [-h] help
                        [-r] Rebase to master
                        [-c] Only run c specific tests
                        [-p] Only run python specific tests"
FAIL_OCCURED=0
LANG="c,py"

function run_test() {
    printf '============================================\n'
    printf '%-40s' "$1"
    if (($# == 1)); then
        printf 'SKIP\n'
        return
    fi

    CMD_OUTPUT=$(eval $2 2>&1)
    ECODE=$?
    if (($ECODE == 0)); then
        printf '\033[0;32mPASS\e[m\n> %s\n' "$2"
    else
        printf '\033[0;31mFAIL\e[m\n> %s\n' "$2"
        FAIL_OCCURED=1
    fi
    printf "%s\n" "$CMD_OUTPUT"
}

# Find config file
if [ -z "$1" ]
then
    echo "$HELP_USAGE"
    exit
fi

case "$1" in
  /*) STATIC_TEST_CONF_PATH=$1 ;;
  -*) echo "$HELP_USAGE"
  exit;;
  *) STATIC_TEST_CONF_PATH="${PWD}/${1}" ;;
esac

# Get flags
while getopts "hrcp" opt; do
  case $opt in
    h) echo "$HELP_USAGE"
    exit ;;
    c) LANG="c" ;;
    p) LANG="py" ;;
    r) REBASE=1 ;;
    *) echo 'error' >&2
       exit 1
  esac
done

source $STATIC_TEST_CONF_PATH
CUR_PRJ_ROOT="`cd "${STATIC_TEST_CONF_PATH%/*}/${PRJ_ROOT}";pwd`"

cd $CUR_PRJ_ROOT

if [ -n "$REBASE" ]; then
    run_test "REBASE" "git rebase master"
else
    run_test "REBASE"
fi

if [[ $LANG == "c,py" ]] || [[ $LANG == "py" ]]; then
  CMD_OUTPUT=$(flake8)
  run_test "FLAKE8" "flake8 ${FLAKE8_ARGS}"
fi

run_test "CODESPELL" "codespell ${CODESPELL_ARGS}"

if [[ $LANG == "c,py" ]] || [[ $LANG == "c" ]]; then
  cd "${CUR_PRJ_ROOT}/${FW_DIR}"
  run_test "CPPCHECK" "cppcheck ${CPPCHECK_ARGS}"
  run_test "DOC_CHECK" "make doc"

  make clean
  run_test "DEFAULT_MAKE" "make"
  make clean

  for i in "${BOARDS[@]}"
  do
      BOARD=i make clean
      run_test "${i}_MAKE" "BOARD=${i} make"
      BOARD=i make clean
  done

  cd "${CUR_PRJ_ROOT}"
fi

exit $FAIL_OCCURED
