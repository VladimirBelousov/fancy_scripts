#!/bin/bash
cat <<aec7ee2ce709ee82c188a27b2827a751

 Copyright 2012 Vladimir Belousov (vlad.belos@gmail.com)
 https://github.com/VladimirBelousov/fancy_scripts

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 Converts html tables from html file to csv file

aec7ee2ce709ee82c188a27b2827a751

[ $# -ne 1 ]&&echo -e "Usage:\n\n html2csv [html file to convert to csv]"&&exit 1

sed " /<\/*[A-Za-z]\+/s/<\/*[A-Za-z]\+/\n&/g" "$1" | sed " /^<[Tt][Dd] /{:a;N;s/\(<[Tt][Dd][ >][^<]\+\)\(\n\)/\1/g;ta};/<\/[Tt][Dd]>/s/<\/[Tt][Dd]>/;/g;/&nbsp;/s/&nbsp;//g" | sed -r " :a;N;s/(<[^>]*)(\n)([^>]*>)/\1\3/g;ba" | sed " /<\/*[Bb][Rr]>\|<[Tt][Rr][ >]/s/<\/*[Bb][Rr]>\|<[Tt][Rr] *[^>]*>/=0DH=/g" | sed " :a;N;s/<[^>]*>//g;s/\n//;ba" | sed " s/=0DH=/\n/g" > "$1".csv
