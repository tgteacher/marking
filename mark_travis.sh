#!/usr/bin/env bash

# Before running the script
# gem install travis
# travis login --pro

# Known bugs:
# - only tests the last build, even if on a different branch.
# - when all tests fail, mark is unknown
# - missing repos aren't well reported
# - only tests the last build: if it was canceled, previous one isn't looked at

# A simple file containing 1 GH username per line
github_accounts=$1
total_tests=11 # don't parse the logs when status is 'green'

# Change that with each assignment
repo_prefix="tgteacher/la3-"

echo -e "# GitHub\tRepo\tPassed\tFailed"
for github in $(cat "${github_accounts}")
do
    repo="${repo_prefix}${github}"
    status=$(travis status -r "${repo}" --pro | awk '{print $NF}')
    if [[ "${status}" = "passed" ]]
    then
        mark="${total_tests}\t0"
    else
        if [[ "${status}" = "failed" ]]
        then
            temp_name="travis_mark.log"
            travis logs -r "${repo}" --pro > ${temp_name}
            # When pytest isn't called with -q
            mark=$(grep -P "= [0-9]* failed, [0-9]* passed in [0-9]*\.[0-9]* seconds =" ${temp_name}\
                | awk '{print $4"\t"$2}' | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")
            # When pytest is called with -q
            # mark=$(grep -P "[0-9]* failed, [0-9]* passed in [0-9]*\.[0-9]* seconds" ${temp_name}\
            #    | awk '{print $3"\t"$1}' | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")
            else
                mark="${status}"
        fi
    fi
    echo -e "${github}\t${repo}\t${mark}"
done
