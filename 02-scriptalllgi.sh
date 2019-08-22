#!/bin/bash
DIR="$(dirname "$(realpath "$0")")"
source $DIR/.env

export DIRSCRIPT="$(dirname "$(readlink -f "$0")")"
export LOGDIR=$(realpath $DIRSCRIPT/../logs)
DIR=${PREPROC_DIR}

# Input
read -p "Quantidade de processos em paralelo (Ex: 4): " NUM_PAR
if ! [[ $NUM_PAR =~ ^[0-9]+$ ]]; then # Se entrada não for número
    NUM_PAR=1
fi

# Identificando as pastas que precisam ser processadas
i=0
for SUBJDIR in $DIR/SUBJ???; do
    SUBJ=$(basename $SUBJDIR)

    for SESS in $SUBJDIR/SUBJ???_ses-?*/; do
        SESS=`basename -a $SESS`
        # Skipping some subjects
        [[ -e "$LOGDIR/${SESS}.sh.out" ]] && continue

        if [ -e "$SUBJDIR/${SESS}/scripts/IsRunning.lh+rh" ]; then
            echo "$SUBJDIR/${SESS}" em processamento. Ignorando
            continue
        fi

        FOLDERS[$i]="$LOGDIR/${SESS}"
        i=$(($i+1))
    done
done

# Preparando arquivo
# Adicionando data e hora no nome do script dos comandos para evitar conflitos
SHFILE=$LOGDIR/run_$(date +%Y%m%d_%H%M%S).sh

echo $SHFILE
echo "cd $DIRSCRIPT" >> $SHFILE
echo "source ~/.bash_profile" >> $SHFILE

# Inserindo comandos no arquivo
LASTSUBJ=
counter=1
for FOLDER in "${FOLDERS[@]}"; do
    DIRNAME=`basename -a $FOLDER`
    SUBJ=${DIRNAME/_ses-*/}
    SUBJDIR="$DIR/$SUBJ"

    if [ "$SUBJ" != "$LASTSUBJ" ]; then
        LASTSUBJ="$SUBJ"
        printf "\n### $SUBJ\n" >> $SHFILE
        echo "export SUBJECTS_DIR=$SUBJDIR" >> $SHFILE
    fi

    # Comando ajustado para atender os templates, quando necessário
    if [[ $DIRNAME == *".long."* ]]; then
        TPNID=${DIRNAME/.long.*/}
        TMPLID=${DIRNAME#*.long.}
        echo "recon-all -localGI -s $DIRNAME -long $TPNID $TMPLID >> $LOGDIR/$DIRNAME.sh.out &" >> $SHFILE
    else
        echo "recon-all -localGI -s $DIRNAME >> $LOGDIR/$DIRNAME.sh.out &" >> $SHFILE
    fi
    
    counter=$((counter+1))
    # Adding break after $NUM_PAR
    if [[ "$counter" -gt $NUM_PAR ]]; then
        echo "wait" >> $SHFILE
        counter=1
    fi
done

# Finaliza arquivo com auto-exclusão
echo "rm -- \"\$0\"" >> $SHFILE

echo "nohup su -c \"sh $SHFILE\" iproject &"
nohup su -c "sh $SHFILE" iproject &


