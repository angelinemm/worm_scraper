#!/bin/bash


function scrape {
    TITLE=$1
    BEGIN=$2
    END=$3
    if [ "$BEGIN" -eq 0 ]; then BEGINSTR="start"; else BEGINSTR="arc_$BEGIN"; fi
    if [ "$END" -eq 999999 ]; then ENDSTR="end"; else ENDSTR="arc_$END"; fi
    if [ "$BEGIN" -eq 0 ] && [ "$END" -eq 999999 ]; then
        FULL_TITLE=$TITLE
    elif [ "$BEGIN" -eq "$END" ]; then
        FULL_TITLE="${TITLE}_${BEGINSTR}"
    else
        FULL_TITLE="${TITLE}_${BEGINSTR}_to_${ENDSTR}"
    fi
	echo "Scraping " $TITLE
	ruby serial_scrape.rb -s $TITLE -b $BEGIN -e $END > ${FULL_TITLE}.html
	ebook-convert ${FULL_TITLE}.html ${FULL_TITLE}.mobi --authors "John McCrae" --title "${TITLE}" --max-toc-links 500
	rm ${FULL_TITLE}.html
}
BEGIN=0
END=999999

while getopts ":b:e:ahptwr" opt; do
	case $opt in
        b) BEGIN=$OPTARG
        ;;
        e) END=$OPTARG
        ;;
		w) scrape "worm" $BEGIN $END
		   exit 
		;;
		t) scrape "twig" $BEGIN $END
		   exit
		;;
		p) scrape "pact" $BEGIN $END
		   exit
		;;
    r) scrape "ward" $BEGIN $END
       exit
    ;;
		a) scrape "worm" $BEGIN $END
		   scrape "pact" $BEGIN $END
		   scrape "twig" $BEGIN $END
       scrape "ward" $BEGIN $END
		   exit
		;;

		h) echo "options are: -b begin at that arc, -b e end at that arc, -a for all, -h for help, -p for pact, -t for twig, -w for worm, -r for ward"
		exit 1
		;;
	esac
done
