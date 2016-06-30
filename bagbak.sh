#!/bin/bash

# This script backs up data bags from chef into an encrypted tarball.
# to restore them, decrypt the file, and you should be able to
#  knife data bag from file <blah> 
# in a loop

test_pass() {

    printf "[\e[1m\033[32mPASS\033[0m]\n"

}

test_fail() {

    printf "[\e[1m\033[31mFAIL\033[0m]\n"
    echo "$errmsg"
    exit 1

}

test_knife() {

    echo -n "Knife user check: "
    knife_return=$( knife node list > /dev/null 2>&1 ; echo $? )
    if [ "$knife_return" = "0" ] ;then
        test_pass
    else
        errmsg="This script requires a valid knife user"
        test_fail
    fi

}

test_pgp() {

    echo -n "PGP installed check: "
    pgp_return=$( which pgp > /dev/null 2>&1 ; echo $? )
    if [ "$pgp_return" = "0" ] ;then
        test_pass
    else
        errmsg="This script requires pgp to be installed"
        test_fail
    fi
}

dump_bags() {

    # handle directories
    rundir=$(pwd)
    timestamp=$(date --rfc-3339=seconds | sed 's/\ /_/g')
    dir="$rundir/$timestamp" 
    mkdir -p $dir
    cd $dir

    # dump data bags
    for bag in $(knife data bag list) ;do
        mkdir $dir/$bag
        cd $dir/$bag
        for subbag in $(knife data bag show $bag) ;do
            knife data bag show $bag $subbag -F j > ${subbag}.json
        done
    done
    cd $dir

}

#main

#we require a valid knife user
test_knife
#we require pgp to be installed
test_pgp

# do the needful
dump_bags





