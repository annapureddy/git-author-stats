#! /bin/bash

# Repositories
authors=""
repos=""
since="2015-07-01"
until="2015-10-01"

# For each author,
# For each repo, find number of files, insertions, deletions
# Ignore any contributions above 1000 lines (either insertions or deletions)

for author in $authors; do
    files=0
    insertions=0
    deletions=0
    
    for repo in $repos; do
	cd $repo
	if [ $? = 0 ]; then
	    output=`git log --shortstat --author="$author" --since=$since --until=$until | grep "files\? changed" | awk '{files += $1; insertions += ($4 < 1000 ? $4 : 0); deletions += ($6 < 1000 ? $6 : 0)} END {print files, insertions, deletions}'`
	    read files1 insertions1 deletions1 <<EOF
`echo $output`
EOF
	    if [ -z "$files1" ]; then
		files1=0
	    fi
	    if [ -z "$insertions1" ]; then
		insertions1=0
	    fi
	    if [ -z "$deletions1" ]; then
		deletions1=0
	    fi
	    files=`expr $files + $files1`
	    insertions=`expr $insertions + $insertions1`
	    deletions=`expr $deletions + $deletions1`

	    cd - > /dev/null 2>&1
	fi
    done

    echo "$author $files $insertions $deletions"
done