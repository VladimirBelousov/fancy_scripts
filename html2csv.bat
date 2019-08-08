echo off

echo Copyright 2012 Vladimir Belousov (vlad.belos@gmail.com)
echo https://github.com/VladimirBelousov/fancy_scripts
echo.
echo Licensed under the Apache License, Version 2.0 (the "License");
echo you may not use this file except in compliance with the License.
echo You may obtain a copy of the License at
echo.
echo    http://www.apache.org/licenses/LICENSE-2.0
echo.
echo Unless required by applicable law or agreed to in writing, software
echo distributed under the License is distributed on an "AS IS" BASIS,
echo WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
echo See the License for the specific language governing permissions and
echo limitations under the License.
echo.
echo Converts html tables from html file to csv file
echo.
echo Depends on sed.exe, which have to be in the script directory
echo or in the directory from the PATH system variable.
echo Sed is available here: https://github.com/mbuilov/sed-windows/raw/master/sed-4.7.exe
echo and has to be renamed to sed.exe
echo.

IF %1""=="" (
echo Usage:
echo html2csv [html file to convert to csv]
pause
exit 1
)
sed " /<\/*[A-Za-z]\+/s/<\/*[A-Za-z]\+/\n&/g" %1 | sed " /^<[Tt][Dd] /{:a;N;s/\(<[Tt][Dd][ >][^<]\+\)\(\n\)/\1/g;ta};/<\/[Tt][Dd]>/s/<\/[Tt][Dd]>/;/g;/&nbsp;/s/&nbsp;//g" | sed -r " :a;N;s/(<[^>]*)(\n)([^>]*>)/\1\3/g;ba" | sed " /<\/*[Bb][Rr]>\|<[Tt][Rr][ >]/s/<\/*[Bb][Rr]>\|<[Tt][Rr] *[^>]*>/=0DH=/g" | sed " :a;N;s/<[^>]*>//g;s/\n//;ba" | sed " s/=0DH=/\n/g" > %1.csv
