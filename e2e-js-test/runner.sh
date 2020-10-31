#!/bin/sh

code=0
testfile=$1
files=$testfile
pwd
ls
if [ -z $testfile ]
then
  files=$(ls ./source/e2e-js-test/*_test.js)
fi

for test in $files
do
  casperjs test $test
  ret=$?
  if [ ! $ret == "0" ]; then code=1; fi
done

exit $code