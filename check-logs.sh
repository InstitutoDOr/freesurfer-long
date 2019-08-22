#!/bin/bash
export DIRSCRIPT="$(dirname "$(readlink -f "$0")")"
source $DIRSCRIPT/.env

# Listing files without message 'finished without error'
echo "# LOGS INCOMPLETOS (ainda estão em execução?)"
find $LOGSDIR  -name 'SUBJ*.out' -exec  egrep  -L  "finished without error|exited with ERRORS" {} \; | sort | grep 0 

echo
echo "# LOGS FINALIZADOS COM ERRO"
find $LOGSDIR  -name 'SUBJ*.out' -exec  grep  -l  "exited with ERRORS"  {} \; | sort | grep 0 
