#!/bin/bash
cat <<7e1e656abd37b5a9c943511659456c4e

 Copyright 2013 Vladimir Belousov (vlad.belos@gmail.com)
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

 Produces hyphenation of monospace text by words

7e1e656abd37b5a9c943511659456c4e

[ -t 0 -o $# -ne 1 ]&&echo -e "Usage:\n\n cat [text file to process] | hyphwords.sh [number of characters in a line]"&&exit 1
one=`cat`
while [ -z "$two" -o `echo -n "$two" | sed -n '$='`0 -gt  `echo -n "$one" | sed -n '$='`0 ]; do
  [ -n "$two" ]&&one=`echo -n "$two"`
  two=`echo -n "$one" | sed -r ' /^.{'"$1"'}[^\\]/s/^.{'"$1"'}/&\\\\\\n/' | sed -r ' /^.{'"$1"'}[\\]/{s/([ [:punct:]])([^ ]*\\\\$)/\\1\\n\\2/;ta;s/\\\\//;:a;}' | sed -r ' /[\\]$/{N;s/\\\\\\n//}'`
done
echo -n "$two"
