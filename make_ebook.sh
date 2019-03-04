#!/bin/bash


function scrape {
	echo "Scraping " $1 
	ruby serial_scrape.rb -s $1 -b $2 -e $3 > ${1}.html
	ebook-convert ${1}.html ${1}.mobi --authors "John McCrae" --title "${1}" --max-toc-links 500
	rm ${1}.html
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
