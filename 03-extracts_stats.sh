#!/bin/bash -e
export DIRSCRIPT="$(dirname "$(readlink -f "$0")")"
source $DIRSCRIPT/.env

DIR=${PREPROC_DIR}
LISTSUBJS=$DIR/all_subjects.txt

# Removendo lista de sujeitos, caso exista
[ -f $LISTSUBJS ] && rm -f $LISTSUBS

# Identificando as pastas que precisam ser processadas
for SUBJDIR in $DIR/SUBJ???; do
    SUBJ=$(basename $SUBJDIR)

    # Identificando todas as sesões do sujeito
    for SESS in $SUBJDIR/SUBJ???_ses-?*/; do
        SESS=`basename -a $SESS`

        # Check se o processamento ainda está rodando
        if [ -e "$SUBJDIR/${SESS}/scripts/IsRunning.lh+rh" ]; then
            echo "$SUBJDIR/${SESS}" em processamento. Ignorando
            continue
        fi
        
        ## COMMANDS

        set -x
        export SUBJECTS_DIR=$SUBJDIR
        SESS_STATS=$SUBJDIR/${SESS}/stats

        # Checking if file doesn't exist to then builds it if necessary. 
        [ ! -f $SESS_STATS/lh.pial.stats ] && \
    		mris_anatomical_stats -f $SESS_STATS/lh.pial.stats ${SESS} lh pial &

        [ ! -f $SESS_STATS/rh.pial.stats ] && \
    		mris_anatomical_stats -f $SESS_STATS/rh.pial.stats ${SESS} rh pial &

        [ ! -f $SESS_STATS/lh.lgi.stats ] && \
    		mris_anatomical_stats -t pial_lgi -f $SESS_STATS/lh.lgi.stats ${SESS} lh &

        [ ! -f $SESS_STATS/rh.lgi.stats ] && \
    		mris_anatomical_stats -t pial_lgi -f $SESS_STATS/rh.lgi.stats ${SESS} rh &

        { set +x; } 2>/dev/null
        echo "$SUBJ/$SESS" >> $LISTSUBJS
    done
    # Only continues when previous subject is completed
    wait
done


## EXTRACTING TABLES
OUTTABLES=$STATSDIR/long_tables
export SUBJECTS_DIR=$DIR

set -x
# hemisphere gray matter area
# lh
aparcstats2table --hemi lh --subjectsfile ${LISTSUBJS} --meas area --parc=pial --parcid-only --skip --tablefile $OUTTABLES/lh_pial_surfarea.txt
# rh
aparcstats2table --hemi rh --subjectsfile ${LISTSUBJS} --meas area --parc=pial --parcid-only --skip --tablefile $OUTTABLES/rh_pial_surfarea.txt

# hemisphere white matter area
# lh
aparcstats2table --hemi lh --subjectsfile ${LISTSUBJS} --meas area --parcid-only --skip --tablefile $OUTTABLES/lh_white_surfarea.txt
# rh
aparcstats2table --hemi rh --subjectsfile ${LISTSUBJS} --meas area --parcid-only --skip --tablefile $OUTTABLES/rh_white_surfarea.txt

# hemisphere gray matter volume
# lh
aparcstats2table --hemi lh --subjectsfile ${LISTSUBJS} --meas volume --parc=pial --parcid-only --skip --tablefile $OUTTABLES/lh_pial_volume.txt
# rh
aparcstats2table --hemi rh --subjectsfile ${LISTSUBJS} --meas volume --parc=pial --parcid-only --skip --tablefile $OUTTABLES/rh_pial_volume.txt

# hemisphere gray matter volume
# lh
aparcstats2table --hemi lh --subjectsfile ${LISTSUBJS} --meas thickness --parc=pial --parcid-only --skip --tablefile $OUTTABLES/lh_pial_thickness.txt
# rh
aparcstats2table --hemi rh --subjectsfile ${LISTSUBJS} --meas thickness --parc=pial --parcid-only --skip --tablefile $OUTTABLES/rh_pial_thickness.txt

# white matter volume for multiple regions - independe do hemisfério
asegstats2table --subjectsfile ${LISTSUBJS} --all-segs --skip --tablefile $OUTTABLES/aseg_vol.txt

# hemisphere local gyrification index (fica descrito na tabela como thickness)
# lh
aparcstats2table --hemi lh --subjectsfile ${LISTSUBJS} --meas thickness --parc=lgi --parcid-only --skip --tablefile $OUTTABLES/lh_lgi.txt
# rh
aparcstats2table --hemi rh --subjectsfile ${LISTSUBJS} --meas thickness --parc=lgi --parcid-only --skip --tablefile $OUTTABLES/rh_lgi.txt

