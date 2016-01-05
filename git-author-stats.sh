#! /bin/bash

# Repositories
authors=""
repos=""
#authors=""
#repos=""
since="2015-10-01"
until="2015-12-28"
ignore_commits_with_lines=500

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
	    read cmd <<EOF
git log --shortstat --author="<$author@" --since=$since --until=$until | grep "files\\\? changed" | awk -v ignore_commits_with_lines="$ignore_commits_with_lines" '{files += \$\1; insertions += (\$\4 < ignore_commits_with_lines ? \$\4 : 0); deletions += (\$\6 < ignore_commits_with_lines ? \$\6 : 0); if (1) {print files, insertions, deletions | "cat 1>&2"  }} END {print files, insertions, deletions}'
EOF
	    # echo $cmd
	    output=`eval $cmd`
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

	    if (($files1 > 0)); then
                echo "$repo -> $author $files1 $insertions1 $deletions1"
            fi
            
	    cd - > /dev/null 2>&1
	fi
    done

    echo "$author $files $insertions $deletions"
done
