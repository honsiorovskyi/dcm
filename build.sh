#!/bin/sh

STANDALONE_RUNNERS=1
DCM_SOURCE=dcm.sh
DCM_OUTPUT=dcm
PREFIX=/usr
RUNNERS=(app cls cluster dns)

build() {
    target=$1

    if [ -z $target ]; then
        target=all
    fi
    
    echo "building $target..."
    
    case $target in
    all)
            build runners
            ;;
            
    dcm)
        # truncate output
        truncate --size 0 $DCM_OUTPUT

        # rewrite output
        while read line; do
            # matches only lines in format 'source ...'
            src=$(echo $line | sed -e 's/^\s*source\s*\(.*\)$/\1/gp;d')

            if [ -z $src ]; then
                # copy string 'as is'
                echo $line >> $DCM_OUTPUT
            else
                # replace string with the file contents
                cat $src | grep -v '^#!' >> $DCM_OUTPUT
            fi
        done < $DCM_SOURCE
        ;;
    
    runners)
        build dcm
        
        for (( i = 0; i < ${#RUNNERS[@]}; i++ )) ; do
            runner=${RUNNERS[$i]}

            echo "#!/bin/bash" > $runner            
            if [ -z $STANDALONE_RUNNERS ]; then
                echo "source ${PREFIX}/lib/dcm" >> $runner
            else
                cat ${DCM_OUTPUT} >> $runner
            fi
            echo "$runner \$@" >> $runner
            
            chmod +x $runner
        done
        ;;
        
    clean)
        rm $DCM_OUTPUT ${RUNNERS[*]}
        ;;
        
    install)
        
    *)
        echo "No rule to make target '$target'.  Stop."
        return 1
        ;;
        
    esac    
}

build $1