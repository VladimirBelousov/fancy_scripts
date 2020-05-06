#!/bin/bash
# Copyright 2012 Vladimir Belousov (vlad.belos@gmail.com)
# https://github.com/VladimirBelousov/fancy_scripts
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# CGI HTTP(S) server script, which processes :
# - the query string and post request data (x-www-form-urlencoded) into the $QUERY_STRING_POST key and value array;
# - the cookies data into the $HTTP_COOKIES key and value array.
#
# Demands bash version 4.0 or higher (to define the key and value arrays above).
#
# It has:
# - the check for max length of data, which can be transferred to it's input,
#   as well as processed as query string and cookies;
# - the redirect() procedure to produce redirect to itself with the extension changed to .html (it is useful for an one page's sites);
# - the http_header_tail() procedure to output the last two strings of the HTTP(S) respond's header;
# - the $REMOTE_ADDR value sanitizer from possible injections;
# - the sanitizer of $QUERY_STRING_POST and $HTTP_COOKIES values against possible SQL injections (the escaping like the mysql_real_escape_string php function does, plus the escaping of @ and $).
#
# As it is the server script it can't be invoked in terminal and should be run in the HTTP(S) server's CGI environment.
#
# In the server's CGI environment it has such global variables related to the current web request:
# - $CONTENT_LENGTH
# - $QUERY_STRING
# - $HTTP_COOKIE
# - $REMOTE_ADDR
# - $HTTP_USER_AGENT
#
# The web request's body (POST data) is transferred to the script's input.
#
# It can be included into another web bash script using a dot or the source command.
#
# Programming for web using bash one need to remember about possible bash injections in an use input:
# - asterisk;
# - semicolon in the loops over a parameters list, taken from an user input;
# - eval of an user input, which is dangerous by itself,
#   but also removes escapes from the dengerous symbols,
#   when is used with parameters, which is not wrapped into the single quotes.
#
# To output a valid HTML page one need just add these strings at the end of this script:
#   # The bash script, which increments the cookies value on each request
#   cookie_value=${HTTP_COOKIES[Hello_World]}
#   let cookie_value+=1
#   echo -e "Set-Cookie: Hello_World=$cookie_value\r"
#   http_header_tail
#   echo -n "Hello_World cookie value == $cookie_value"
# ----------------------------------------------------------------------------------------

[ -t 0 ]&&echo "As it is the server script it can't be invoked in terminal and should be run in the HTTP(S) server's CGI environment"&&exit 1

MAX_CONTENT_LENGTH=3000 # 3 Kb
MAX_QUERY_STRING_LENGTH=1000 # 1000 symbols
MAX_HTTP_COOKIE_LENGTH=3000 # 3 Kb
[ "${CONTENT_LENGTH}"0 -gt ${MAX_CONTENT_LENGTH}0 -o ${#QUERY_STRING} -gt $MAX_QUERY_STRING_LENGTH -o ${#HTTP_COOKIE} -gt $MAX_HTTP_COOKIE_LENGTH ]&&exit 1

[ -z $LANG ]&&export LANG=ru_RU.UTF-8 # Set your locale here, so regular expressions will be processed correctly
DOMAIN_NAME='smsmms.biz' # Is used for links and redirects
BASENAME="$0";BASENAME="${BASENAME##*/}"
BASENAME="${BASENAME%.*}.html" # This script's extension was changed to .html, so use .htaccess to map .html with .sh

REMOTE_ADDR="${REMOTE_ADDR//[^0-9:A-Fa-f.]/}";REMOTE_ADDR="${rad:0:39}"

declare -A QUERY_STRING_GET
if [ -n "$QUERY_STRING" ]; then
  while read -d \&; do
    OIFS=$IFS;IFS="=";RPL=( $REPLY );IFS=$OIFS
    fsym="${RPL[0]:0:1}";fsym="${fsym/[^_A-Za-z]/_}"
    osym="${RPL[0]:1}";osym="${osym//[^A-Za-z0-9_]/}"
    [ -z "$fsym$osym" ]&&continue
    znach="${RPL[1]//+/ }"
    rslt="${znach//\%[0-9a-fA-F][0-9a-fA-F]/+}"
    OIFS=$IFS;IFS="+";rslt2=( $rslt );IFS=$OIFS
    col=${#rslt2[*]};ind=1
    re='(^.*)(%[0-9a-fA-F][0-9a-fA-F])(.*$)'
    re2='.*%[0-9a-fA-F][0-9a-fA-F]$'
    flg="";[[ "$znach" =~ $re2 ]]&&flg="1"
    rslt3="";while [[ "$znach" =~ $re ]]; do
      znach="\$'${BASH_REMATCH[2]/\%/\\x}'"
      eval znach="$znach"
      if [ -n "$flg" ]; then
          rslt3="$znach"
          flg=""
      else
          let i=$col-$ind
          rslt3="$znach${rslt2[$i]}$rslt3"
          let ind+=1
      fi
      znach="${BASH_REMATCH[1]}${BASH_REMATCH[3]}"
    done
    rslt="${rslt2[0]}$rslt3"
    rslt="${rslt//\\/\\\\\\}";rslt="${rslt//$'\n'/\\$'\n'}";rslt="${rslt//$'\r'/\\$'\r'}";rslt="${rslt//\'/\'}";rslt="${rslt//\"/\\\"}";rslt="${rslt//$'\x1a'/\\$'\x1a'}";rslt="${rslt//@/\\@}";rslt="${rslt//$/\\$}"
    eval 'QUERY_STRING_GET[$fsym$osym]="$rslt"'
  done <<< "$QUERY_STRING&"
fi

declare -A QUERY_STRING_POST
if [ -n "$CONTENT_LENGTH" ]; then
  POST_STRING=`cat`
  while read -d \&; do
    OIFS=$IFS;IFS="=";RPL=( $REPLY );IFS=$OIFS
    fsym="${RPL[0]:0:1}";fsym="${fsym/[^_A-Za-z]/_}"
    osym="${RPL[0]:1}";osym="${osym//[^A-Za-z0-9_]/}"
    [ -z "$fsym$osym" ]&&continue
    znach="${RPL[1]//+/ }"
    rslt="${znach//\%[0-9a-fA-F][0-9a-fA-F]/+}"
    OIFS=$IFS;IFS="+";rslt2=( $rslt );IFS=$OIFS
    col=${#rslt2[*]};ind=1
    re='(^.*)(%[0-9a-fA-F][0-9a-fA-F])(.*$)'
    re2='.*%[0-9a-fA-F][0-9a-fA-F]$'
    flg="";[[ "$znach" =~ $re2 ]]&&flg="1"
    rslt3="";while [[ "$znach" =~ $re ]]; do
      znach="\$'${BASH_REMATCH[2]/\%/\\x}'"
      eval znach="$znach"
      if [ -n "$flg" ]; then
          rslt3="$znach"
          flg=""
      else
          let i=$col-$ind
          rslt3="$znach${rslt2[$i]}$rslt3"
          let ind+=1
      fi
      znach="${BASH_REMATCH[1]}${BASH_REMATCH[3]}"
    done
    rslt="${rslt2[0]}$rslt3"
    rslt="${rslt//\\/\\\\\\}";rslt="${rslt//$'\n'/\\$'\n'}";rslt="${rslt//$'\r'/\\$'\r'}";rslt="${rslt//\'/\'}";rslt="${rslt//\"/\\\"}";rslt="${rslt//$'\x1a'/\\$'\x1a'}";rslt="${rslt//@/\\@}";rslt="${rslt//$/\\$}"
    eval 'QUERY_STRING_POST[$fsym$osym]="$rslt"'
  done <<< "$POST_STRING&"
fi

declare -A HTTP_COOKIES
if [ -n "$HTTP_COOKIE" ]; then
  while read -d \ ; do
    OIFS=$IFS;IFS="=";RPL=( $REPLY );IFS=$OIFS
    fsym="${RPL[0]:0:1}";fsym="${fsym/[^_A-Za-z]/_}"
    osym="${RPL[0]:1}";osym="${osym//[^A-Za-z0-9_]/}"
    [ -z "$fsym$osym" ]&&continue
    znach="${znach%;}"
    znach="${RPL[1]//+/ }"
    rslt="${znach//\%[0-9a-fA-F][0-9a-fA-F]/+}"
    OIFS=$IFS;IFS="+";rslt2=( $rslt );IFS=$OIFS
    col=${#rslt2[*]};ind=1
    re='(^.*)(%[0-9a-fA-F][0-9a-fA-F])(.*$)'
    re2='.*%[0-9a-fA-F][0-9a-fA-F]$'
    flg="";[[ "$znach" =~ $re2 ]]&&flg="1"
    rslt3="";while [[ "$znach" =~ $re ]]; do
      znach="\$'${BASH_REMATCH[2]/\%/\\x}'"
      eval znach="$znach"
      if [ -n "$flg" ]; then
          rslt3="$znach"
          flg=""
      else
          let i=$col-$ind
          rslt3="$znach${rslt2[$i]}$rslt3"
          let ind+=1
      fi
      znach="${BASH_REMATCH[1]}${BASH_REMATCH[3]}"
    done
    rslt="${rslt2[0]}$rslt3"
    rslt="${rslt//\\/\\\\\\}";rslt="${rslt//$'\n'/\\$'\n'}";rslt="${rslt//$'\r'/\\$'\r'}";rslt="${rslt//\'/\'}";rslt="${rslt//\"/\\\"}";rslt="${rslt//$'\x1a'/\\$'\x1a'}";rslt="${rslt//@/\\@}";rslt="${rslt//$/\\$}"
    eval 'HTTP_COOKIES[$fsym$osym]="$rslt"'
  done <<< "$HTTP_COOKIE "
fi

redirect() {
  echo -e "Location: http://${DOMAIN_NAME}/${BASENAME}\r
\r"
  exit 0
}

http_header_tail() {
  echo -e "Content-Type: text/html\r
\r"
}
