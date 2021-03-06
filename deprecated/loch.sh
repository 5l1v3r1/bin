#!/bin/sh
#  
#	This script processes all subdirectories of the directroy where it is executed. Each subdirectory
#   is fed to the SLOCCount utility to calculate the lines of code contained. The output from SLOCCount
#   is parsed by a Python script to produce an HTML formatted report.
#   Once all the subdirectories are processed the SLOCCount utility is run against the parent directory
#   to produce an overall total of all the projects. The output of this run is also formatted as HTML.
#
#   who when        what
#   mhn 3.30.2009   initial version of loch.sh
#   mhn 4.3.2009    added CVS update to loop
#	mhn	4.22.2011	added -dA parm to cvs command to force adding missing directories and head
#
#	
if [ "$1" = "-h" ]; then
	echo "Usage $0 [-l | -h] \n   Use -l to produce intermediate log files.\n   Use -h for help." >&2; exit 1
fi
#
# update each project from CVS and then
# count the lines of code in each project
loglocation="/dev/null"
echo "Processing individual project directories..."
for d in *; do
	if [ -d "$d" ]; then # we have a directory
		if [ "$d" != "CVS" ] ; then    # skip CVS entries
			echo "   updating ${d} from CVS..."
			cd ${d}
			cvs -q up -dA
			cd ..
			echo "   ${d} counting SLOC..."
			if [ "$1" = "-l" ]; then # produce log files
				loglocation=${d}.log
			fi
			/usr/local/Cellar/sloccount/bin/sloccount --wide --multiproject $d > ${d}.txt 2>${loglocation}
			/Users/mhn/bin/sloc2html.py ${d}.txt > ${d}.html
			#
			# clean up
			rm ${d}.txt
		fi
	fi
done
#
# publish our results
echo "Publishing individual project html pages..."
cp *.html ~/Sites
#
echo "Removing html files from working directory..."
rm *.html
#
# build the index page and publish
echo "Processing all projects for index page..."
cd ~/Projects
/usr/local/sloccount/bin/sloccount --wide --multiproject sloc_workspace > sloc_workspace.txt 2>sloc_workspace.log
#
echo "Formatting html pages..."
/Users/mhn/bin/sloc2group.py sloc_workspace.txt > index.html
#
echo "Publishing index.html..."
cp index.html ~/Sites
# eof
