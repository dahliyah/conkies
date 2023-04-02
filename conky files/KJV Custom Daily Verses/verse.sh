#!/bin/bash

############################################################
# 
# This is a script to output bible verses from
# Diatheke for use in a conky script.
# 
# This script depends on diatheke and $RANDOM.
# In Ubuntu and it's derivatives use:
# sudo apt-get install diatheke $RANDOM
# 
# Visit http://www.crosswire.org/sword/diatheke/
# to learn more about Diatheke and the Sword Project.
# 
# Usage:
# When called by itself this script will choose
# a verse at $RANDOMom from the list at $List.  The
# list should be plain text with one verse or a
# group of verses per line.  Examples of
# acceptable lines are as follows:
# 
#     Jn 3:16
#     1 Corinthians 12:8-10,12
#     Revelation 22:20
# 
# When called with an argument this script will
# attempt to use the argument as a verse and
# display the results.
# 
# Feeding the script any other input will give 
# unpredictable results.
# 
# A suitable list of verses can be found at:
# http://www.gnpcb.org/esv/share/rss2.0/?show-verses=true
# 
# The sample conkyrc can be invoked with
# conky -c verse.conkyrc
# 
# Help with configuring conky can be found at:
# http://conky.sourceforge.net/documentation.html
# 
# To learn about Jesus visit:
# http://www.christianity.com/Essentials/
# 
############################################################

# Module must be an installed Sword Module.
# Install new modules with bibletime.
Module=KJVPCE

# Location of plain text file with verses to choose from.
List=~/.conky/Cepher/verse.list

# Height and Width of output to keep the conky display sane.
OutputHeight=10
OutputWidth=60
Output=plain

# When set to true padding will be added to top of output.
# Otherwise the padding will be added to the bottom.
AlignBottom=false

# We use a temp file to speed up the script run time.
TempFile=/tmp/conky-verse

getVerse (){

        case $1 in
       "")    ListLength=`wc -l $List | cut -d " " -f 1`
        RandomNumber=`rand -M $ListLength -N 1`
        VerseNumber=`expr $RandomNumber + 1`
        Verse=`cat $List | head -n $VerseNumber | tail -n 1` ;;
        *)  Verse=$@ ;;
    esac
    
    
}


printVerse (){

    Verse=$1

    Chapter=`diatheke -b $Module -k $Verse -f $Output | head -n 1 | cut -d : -f 1`

   # Print book chapter:verse(s)
    echo '${color1}'$Verse'${color0}'

    # Print the verse(s)
    diatheke -b $Module -f $Output -k $Verse| \
    sed 's/'"$Chapter:"'//' | \
    sed 's/('$Output')//' | \
    sed 's/('$Module')//' | \
    sed 's/ ^[ \t]*//' | \
    sed '/./!d' | \
    sed 's/\t/ /g' | \
    sed 's/^/        /' | \
    fold -sw $OutputWidth | \
    sed 's/^ /${color1} /' | \
    sed 's/:/${color0}/'
}

padVerse (){

    Lines=`cat $TempFile | wc -l | cut -d " " -f 1`
    LinesAdd=`expr $OutputHeight - $Lines`

    let i=0
    while [ $i -lt $LinesAdd ]; do
        echo
        let i=$i+1
    done
}

displayVerse (){
    cat $TempFile
}

getVerse "$@"
printVerse "$Verse" > $TempFile

case $AlignBottom in
  true|True)    padVerse
        displayVerse ;;
          *)    displayVerse
        padVerse ;;
esac

exit 0
