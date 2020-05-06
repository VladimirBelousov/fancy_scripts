# fancy_scripts

## Fancy scripts for text processing, web development and more

### The set of scripts, which reveals the power of regular expressions and/or POSIX shell (bash):

- **html2csv.bat** - batch file, which converts html tables from html file to csv file (Windows, cmd.exe, sed.exe);

- **html2csv.sh** - shell script, which converts html tables from html file to csv file (Linux, Mac OS X, Unix, Android, bash, sed);

- **hyphwords.sh** - shell script, which produces hyphenation of monospace text by words (Linux, Mac OS X, Unix, Android, Windows, bash, sed);

- **bash-cgi.sh** - CGI (Common Gateway Interface) HTTP(S) server shell script, which processes :
  - the query string and post request data (x-www-form-urlencoded) into the $QUERY_STRING_POST key and value array;
  - the cookies data into the $HTTP_COOKIES key and value array.

  Demands bash version 4.0 or higher (to define the key and value arrays above).

  It has:
  - the check for max length of data, which can be transferred to it's input,
   as well as processed as query string and cookies;
  - the redirect() procedure to produce redirect to itself with the extension changed to .html (it is useful for an one page's sites);
  - the http_header_tail() procedure to output the last two strings of the HTTP(S) respond's header;
  - the $REMOTE_ADDR value sanitizer from possible injections;
  - the sanitizer of $QUERY_STRING_POST and $HTTP_COOKIES values against possible SQL injections (the escaping like the mysql_real_escape_string php function does, plus the escaping of @ and $).

  As it is the server script it can't be invoked in terminal and should be run in the server's CGI environment.

  In the server's CGI environment it has such global variables related to the current web request:
  - $CONTENT_LENGTH
  - $QUERY_STRING
  - $HTTP_COOKIE
  - $REMOTE_ADDR
  - $HTTP_USER_AGENT

  The web request's body (POST data) is transferred to the script's input.

  It can be included into another web bash script using a dot or the source command.

  Programming for web using bash one need to remember about possible bash injections in an use input:
  - asterisk;
  - semicolon in the loops over a parameters list, taken from an user input;
  - eval of an user input, which is dangerous by itself,
    but also removes escapes from the dengerous symbols,
    when is used with parameters, which is not wrapped into the single quotes.

  To output a valid HTML page one need just add these strings at the end of the bash-cgi.sh script:
    `# The bash CGI script, which increments the cookies value on each request
    cookie_value=${HTTP_COOKIES[Hello_World]}
    let cookie_value+=1
    echo -e "Set-Cookie: Hello_World=$cookie_value\r"
    http_header_tail
    echo -n "Hello_World cookie value == $cookie_value"`

  [Example may be available here](https://smsmms.biz/bash-cgi.html "The bash CGI script, which increments the cookies value on each request")
