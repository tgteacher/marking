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
total_tests=24 # don't parse the logs when status is 'green'

# Change that with each assignment
repo_prefix="tgteacher/bigdata-la1-w2019-"

echo -e "# GitHub\tRepo\tPassed\tFailed"
for github in $(cat "${github_accounts}")
do
    repo="${repo_prefix}${github}"
    status=$(travis status -r "${repo}" --pro | awk '{print $NF}')
    if [[ "${status}" = "passed" ]]
    then
        mark="${total_tests}\t0"
    else
        temp_name="travis_mark.log"
        # hacky due to https://github.com/travis-ci/travis.rb/issues/578
        log_url=$(travis logs -r "${repo}" --pro --debug-http 2>/dev/null | grep ^Location: | cut -d \" -f 2)
        rm ${temp_name} -f
        wget -O ${temp_name} "${log_url}" 2>/dev/null
        mark=$(grep -P "= [0-9]* failed, [0-9]* passed in [0-9]*\.[0-9]* seconds =" ${temp_name}\
               | awk '{print $4"\t"$2}')
    fi
    echo -e "${github}\t${repo}\t${mark}"
done
