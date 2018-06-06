#!/usr/bin/env bash

#
# Copyright 2018 New Vector Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#######################################################################################################################
# Check drawable quantity
#######################################################################################################################

echo "Check drawable quantity"

numberOfFiles1=`ls -1U ./vector/src/main/res/drawable-hdpi | wc -l | sed  "s/ //g"`
numberOfFiles2=`ls -1U ./vector/src/main/res/drawable-mdpi | wc -l | sed  "s/ //g"`
numberOfFiles3=`ls -1U ./vector/src/main/res/drawable-xhdpi | wc -l | sed  "s/ //g"`
numberOfFiles4=`ls -1U ./vector/src/main/res/drawable-xxhdpi | wc -l | sed  "s/ //g"`
numberOfFiles5=`ls -1U ./vector/src/main/res/drawable-xXxhdpi | wc -l | sed  "s/ //g"`

if [ ${numberOfFiles1} -eq ${numberOfFiles5} ] && [ ${numberOfFiles2} -eq ${numberOfFiles5} ] && [ ${numberOfFiles3} -eq ${numberOfFiles5} ] && [ ${numberOfFiles4} -eq ${numberOfFiles5} ]; then
   resultNbOfDrawable=0
   echo "OK"
else
   resultNbOfDrawable=1
# DISABLE for the moment
   resultNbOfDrawable=0
   echo "ERROR, missing drawable alternative."
fi

echo

#######################################################################################################################
# Search forbidden pattern
#######################################################################################################################

searchForbiddenStringsScript=./tmp/search_forbidden_strings.pl

if [ -f ${searchForbiddenStringsScript} ]; then
  echo "${searchForbiddenStringsScript} already there"
else
  mkdir tmp
  echo "Get the script"
  wget https://raw.githubusercontent.com/matrix-org/matrix-dev-tools/develop/bin/search_forbidden_strings.pl -O ${searchForbiddenStringsScript}
fi

echo

if [ -x ${searchForbiddenStringsScript} ]; then
  echo "${searchForbiddenStringsScript} is already executable"
else
  echo "Make the script executable"
  chmod u+x ${searchForbiddenStringsScript}
fi

echo
echo "Search for forbidden patterns in code..."

${searchForbiddenStringsScript} ./tools/check/forbidden_strings_in_code.txt \
    ./vector/src/app/java \
    ./vector/src/appfdroid/java \
    ./vector/src/main/java

resultForbiddenStringInCode=$?

echo
echo "Search for forbidden patterns in resources..."

${searchForbiddenStringsScript} ./tools/check/forbidden_strings_in_resources.txt \
    ./vector/src/main/res/layout \
    ./vector/src/main/res/menu \
    ./vector/src/main/res/values \
    ./vector/src/main/res/values-v21 \
    ./vector/src/main/res/values-w820dp

resultForbiddenStringInResource=$?

#######################################################################################################################
# Check files with long lines
#######################################################################################################################

checkLongFilesScript=./tmp/check_long_files.pl

if [ -f ${checkLongFilesScript} ]; then
  echo "${checkLongFilesScript} already there"
else
  mkdir tmp
  echo "Get the script"
  wget https://raw.githubusercontent.com/matrix-org/matrix-dev-tools/develop/bin/check_long_files.pl -O ${checkLongFilesScript}
fi

echo

if [ -x ${checkLongFilesScript} ]; then
  echo "${checkLongFilesScript} is already executable"
else
  echo "Make the script executable"
  chmod u+x ${checkLongFilesScript}
fi

echo
echo "Search for long files..."

${checkLongFilesScript} 3000 \
    ./vector/src/app/java \
    ./vector/src/appfdroid/java \
    ./vector/src/main/java \
    ./vector/src/main/res/layout \
    ./vector/src/main/res/menu \
    ./vector/src/main/res/values \
    ./vector/src/main/res/values-v21 \
    ./vector/src/main/res/values-w820dp

resultLongFiles=$?

#######################################################################################################################
# search png in drawable folder
#######################################################################################################################

echo
echo "Search for png files in /drawable..."

ls -1U ./vector/src/main/res/drawable/*.png
resultTmp=$?

# Inverse the result, cause no file found is an error for ls but this is what we want!
if [ ${resultTmp} -eq 0 ]; then
   echo "ERROR, png files detected in /drawable"
   resultPngInDrawable=1
else
   echo "OK"
   resultPngInDrawable=0
fi

echo

if [ ${resultNbOfDrawable} -eq 0 ] && [ ${resultForbiddenStringInCode} -eq 0 ] && [ ${resultForbiddenStringInResource} -eq 0 ] && [ ${resultLongFiles} -eq 0 ] && [ ${resultPngInDrawable} -eq 0 ]; then
   echo "MAIN OK"
else
   echo "MAIN ERROR"
   exit 1
fi
