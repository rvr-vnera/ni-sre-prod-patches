#!/bin/bash

#!/bin/bash
  
scandir=$1

SCRATCH_DIR="/var/lib/scratch-l4"
mkdir -p $SCRATCH_DIR
echo "" > $SCRATCH_DIR/anamolies.txt

check_jar() {
        local j=$1
        local d=$2
        echo "Checking $j"
        jar -tf $j | grep -q JndiLookup.class
        if [[ $? == 0 ]]; then
                echo "Anamoly found in $j in $d" 
                echo "Anamoly found in $j in $d" >> $SCRATCH_DIR/anamolies.txt
        fi
        jar -tf $j | grep -q "\.jar$"
        if [[ $? == 0 ]]; then
                echo "Jar with packaged jars $j"
                echo "Extracting to $SCRATCH_DIR/$j.d"
                mkdir -p $SCRATCH_DIR/$j.d
                cd $SCRATCH_DIR/$j.d
                jar -xf $j
                cd -

                find_all_jars $SCRATCH_DIR/$j.d
                echo "Done processing $j.d"
                rm -r /var/lib/scratch-l4/$j.d
        fi
}       


find_all_jars() {
        local d=$1

        for f in `find $d | grep "\.jar$"`; do
                check_jar $f $d
        done
}


find_all_jars / 