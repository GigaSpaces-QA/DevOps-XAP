#!/bin/bash
#
# run this script on branches since 12.0.0
#
#
#This script clones a specific branch from https://github.com/Gigaspaces/xap-dotnet.git repo to a temp folder under the current working directory.
#Then it replaces the old bucket name with the new one
#Then it shows the user the changes that were made and asks for confirmation
#Then it commits the changes and pushes the changes to the remote repository
#Finally it prompts the user for deleting the temp folder
#
# return codes:
# 0 - OK
# 1 - canceled
# 2 - error
workdir="$(pwd)/xap-dotnet-$(date +%s)"

function handle_error {
	local res=$?
	if [ "$res" = "1" ]; then
	    echo "$1: Canceled by user"
	elif [ "$res" = "2" ]; then
		echo "$1: Error occurred, please review"
	else
		echo "$1: result code $res"
	fi

	prompt_for_cleaning
    exit 1
}

function clone_repo {
    echo "Cloning branch $1"
	git clone --single-branch -b "$1" --depth 1 https://github.com/Gigaspaces/xap-dotnet.git
	if [ "$?" != "0" ]; then
		return 2
	else
		return 0
	fi
}

function update_deployS3 {
	local license_location=`find -name "deployS3.bat"`
	if [ -e "${license_location}" ]; then
		sed  -i "s|gigaspaces-repository-eu|gigaspaces-releases-eu|g" ${license_location}
		if [ "$?" != "0" ]; then
			return 2
		else
			return 0
		fi		
	fi

	echo "Could not find deployS3.bat file. Exiting..."
	return 2
}

function commit_push {
	local modifiedFiles=$(git status | grep 'modified:' | wc -l)
	if [ "$modifiedFiles" != 1 ]; then
		echo "No files were modified."
		return 0
	fi
	
	echo "Showing diff"
	git diff

	while true; do
		read -p "Continue (y/n)?" choice
		case "$choice" in 
		  y|Y ) break;;
		  n|N ) return 1;;
		  * ) echo "invalid" ;;
		esac
	done

	echo "Committing changes"
	git commit -am "Updating S3 bucket name"
	if [ "$?" != "0" ]; then
	    echo "Commit failed"
		return 2
	fi

	echo "Pushing changes to remote repository"
	git push
	if [ "$?" != "0" ]; then
		echo "Push failed"
		return 2
	else
		return 0
	fi
}

function prompt_for_cleaning {
	while true; do
		read -p "Delete working directory ($workdir) (y/n)?" choice
		case "$choice" in 
		  y|Y ) rm -rf "$workdir" ; break;;
		  n|N ) break;;
		  * ) echo "invalid" ;;
		esac
	done
}

function start {
    local branch_name="$1"

    if [ -z "$branch_name" ]; then
    	echo "branch name must be specified"
    	exit 1
    fi
    
    echo "xap-dotnet will be cloned into $workdir"
    mkdir "$workdir"

    cd "$workdir"
	clone_repo "$branch_name" || handle_error "Clone failed"

	cd xap-dotnet

	update_deployS3 || handle_error "Updating license failed"

	commit_push || handle_error "Commit/Push failed"
	
	echo "Script finished without errors"

	prompt_for_cleaning
}


start "$1"