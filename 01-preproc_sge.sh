#!/bin/bash -e
DIR="$(dirname "$(realpath "$0")")"
source $DIR/.env

# Finding each subject
for SUBJDIR in $BIDS_DIR/sub-*/; do
    SUBJ=$(basename $SUBJDIR)
    SUBJ=${SUBJ/sub-/}
    
    # Preparing SUBJ folder
    SUBJDIR=$PREPROC_DIR/${SUBJ}
    [ ! -d $SUBJDIR ] && mkdir $SUBJDIR

    export SUBJECTS_DIR="$SUBJDIR"

    ## EACH SESSION
    # Filling timepoints
    SGE_NAMES=""
    BASE_TPNIDS=""
    for SESS in $BIDS_DIR/sub-$SUBJ/ses-*; do
        SESS=$(basename $SESS)
        TPNID="${SUBJ}_${SESS}"
        
        # Ignoring if the directory exists
        [ -d "$SUBJECTS_DIR/$TPNID" ] && continue
        
        ANAT=( $BIDS_DIR/sub-$SUBJ/$SESS/anat/*T1w.nii.gz )
        SGE_NAME="${SUBJ}${SESS}_recon"
        SGE_NAMES="${SGE_NAMES},${SGE_NAME}"
        BASE_TPNIDS="${BASE_TPNIDS} -tp $TPNID"
        ( set -x; \
          idor_sub -q long.q -N ${SGE_NAME} recon-all -all -s $TPNID -i $ANAT )
    done
    
    ## TEMPLATE
    TEMPLATEID=${SUBJ}_tmpl
    # Ignoring if the directory exists
    if [ ! -d "$SUBJECTS_DIR/$TEMPLATEID" ]; then
        ( set -x; \
          idor_sub -q long.q -N ${TEMPLATEID} -j ${SGE_NAMES##,} recon-all -base $TEMPLATEID ${BASE_TPNIDS} -all )
    fi

    ## LONG
    for SESS in $BIDS_DIR/sub-$SUBJ/ses-*; do
        SESS=$(basename $SESS)
        TPNID="${SUBJ}_${SESS}"

        # Ignoring if the directory exists        
        [ -d "$SUBJECTS_DIR/${TPNID}.long.${TEMPLATEID}" ] && continue
        ( set -x; \
          idor_sub -q long.q -N ${TPNID}_long -j ${TEMPLATEID} recon-all -long $TPNID $TEMPLATEID -all )
    done
done


