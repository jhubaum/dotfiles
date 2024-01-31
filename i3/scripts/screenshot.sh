if ! [ -d $1 ]; then mkdir $1; fi

dt=$(date '+%d-%m-%Y_%H:%M:%S');
scrot $1/$dt.png
