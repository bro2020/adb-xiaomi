#!/bin/bash
if [[ $(uname -s) != 'Linux' ]]; then
export LD_LIBRARY_PATH="$(dirname $0)/adb-macos/lib64":"$LD_LIBRARY_PATH"
export PATH="$(dirname $0)/adb-macos/":"$PATH"
else
export LD_LIBRARY_PATH="$(dirname $0)/adb-linux/lib64":"$LD_LIBRARY_PATH"
export PATH="$(dirname $0)/adb-linux/":"$PATH"
fi

source "$(dirname $0)/l10n"
DEV=$(adb devices -l | tail +2 | cut -d: -f4 | cut -d' ' -f1)
IP=`cat "$(dirname $0)/SESSION.txt"`
date=`date`
VERSION='2.0'

FON="2;1"
RE="\e[1;91m"
GR="\e[$FON;92m"
YE="\e[$FON;93m"
BL="\e[$FON;94m"
WH="\e[$FON;97m" # "97" - якщо фон терміналу темний, "90" - якщо фон тереміналу світлий $uk97
EN="\e[0m"

check_dev() {
if [[ $DEV != '' ]]; then
printf "\n"$GR"$uk100 "$YE"\"$DEV\"$EN "$GR"$uk101"$EN"\n\n"
exit 0
else
$ST
printf "\n"$WH"$uk102"$EN"\n\n"
exit 0
fi
}

session_list() {
if [[ $IP = '' ]]; then
printf "\n"$WH"$uk103"$EN"\n\n"
exit 0
else
printf "\n"$WH"$uk104"$EN" "$GR"\"$IP\"$EN
  $uk105"$RE"
     ./connect.sh$EN "$YE"-c$EN "$GR"$IP:$uk106"$EN"
  $uk107 "$GR"$uk106"$EN" $uk108 "$WH"\"$uk109\"$EN $uk110 "$WH"\"$uk111\"$EN\n"
exit 0
fi
}

check_ip() {
clear
IP=$IP
if [[ $IP != '' ]]; then
printf ""$YE"###################################################################################$EN"$BL"
$uk112"$EN" "$GR"\"$IP\"$EN\n"$WH"
  $uk3"$EN" "$GR"y$EN "$WH"$uk114"$EN" "$YE"$uk106"$EN""$WH"$uk115
  $uk3"$EN" "$GR"n$EN "$WH"$uk116
  $uk3"$EN" "$GR"d$EN "$WH"$uk117\n
$uk16"$EN" "$GR"q$EN "$WH"$uk5"$EN"
"$YE"_________________________________________________________$EN\n"
read -p "$uk6 " session
case "$session" in
  y) input_port ;;
  q) clear; exit 0 ;;
  n) ST='input_code'; input_ipport1;;
  d) echo '' > "$(dirname $0)/SESSION.txt" && printf "$GRГОТОВО$EN!" && IP=`cat "$(dirname $0)/SESSION.txt"`; check_ip;;
  *) printf ""$RE"$uk7"$EN"\n"; sleep 2; check_ip ;;
esac
fi
ST='input_code'; input_ipport1
}

input_port() {
clear
printf ""$WH" $uk118 $EN"$YE"\"$uk119\"$EN"$WH"
 $uk120 $EN"$YE"\"$uk9\"$EN "$WH"$uk121
 $uk122 $EN"$YE"\"$uk109\"$EN "$WH"$uk123
 $uk124 $EN"$YE"\">\"$EN "$WH"$uk125
 $uk126 $EN"$YE"\"$uk111\"$EN "$WH"$uk127$EN \n"$BL"
    $uk77"$EN" "$GR"$IP:32105$EN \n"$WH"
 $uk128"$EN" "$YE"$uk106"$EN" "$WH"- $uk129"$EN" \n"$BL"
    $uk77"$EN" "$GR"32105$EN \n"$WH"
$uk16"$EN" "$GR"q$EN "$WH"$uk5"$EN"
"$YE"_________________________________________________________$EN\n"
read -p "$uk113 " PORT1
if [[ $PORT1 = "q" ]]; then
clear; exit 0
fi
IPPORT1="$IP":"$PORT1"
ST2='input_port'
clear
worker_connect
}

input_ipport1() {
clear
if [[ $DEV = '' ]]; then
printf ""$YE"###################################################################################$EN"$GR"
$uk130"$EN"
"$YE"###################################################################################$EN\n"
else
printf "\n"$GR"$uk100 "$YE"\"$DEV\"$EN "$GR"$uk101"$EN"\n\n"
exit 0
fi
printf ""$WH" $uk118 $EN"$YE"\"$uk119\"$EN"$WH"
 $uk120 $EN"$YE"\"$uk9\"$EN "$WH"$uk121
 $uk122 $EN"$YE"\"$uk109\"$EN "$WH"$uk123
 $uk124 $EN"$YE"\">\"$EN "$WH"$uk125
 $uk126 $EN"$YE"\"$uk111\"$EN "$WH"$uk127"$EN" \n"$BL"
    $uk77"$EN" "$GR"192.168.1.2:32105$EN \n"$WH"
$uk16"$EN" "$GR"q$EN "$WH"$uk5"$EN"
"$YE"_________________________________________________________$EN\n"
read -p "$uk113 " IPPORT1
if [[ $IPPORT1 = "q" ]]; then
clear; exit 0
fi
ST2='input_ipport1'
$ST
}

input_code() {
clear
printf ""$YE"###################################################################################$EN"$WH"
 $uk131 $EN"$YE"\"$uk132\"$EN"$WH".
 $uk133 $EN"$YE"\"$uk134\"$EN "$WH"$uk135 \n"$BL"
    $uk77"$EN" "$YE"$uk134:$EN "$GR"850651$EN \n"$WH"
$uk16"$EN" "$GR"q$EN "$WH"$uk5$EN
"$YE"__________________________________________________________$EN\n"
read -p "$uk113 " CODE
if [[ $CODE = "q" ]]; then
clear; exit 0
fi
clear
printf ""$YE"###################################################################################$EN "$WH"
$uk136"$EN" "$YE"\"$uk111\"$EN "$WH"$uk137"$EN" \n"$BL"
    $uk77"$EN" "$YE"$uk111"$EN" "$GR"192.168.1.2:40105$EN \n"$WH"
 $uk128"$EN" "$YE"$uk106"$EN" "$WH"- $uk129"$EN" \n"$BL"
    $uk77"$EN" "$GR"40105$EN \n"$WH"
$uk16"$EN" "$GR"q$EN "$WH"$uk5"$EN"
"$YE"__________________________________________________________$EN\n"
read -p "$uk113 " PORT2
if [[ $PORT2 = "q" ]]; then
clear; exit 0
fi
worker_pair
}

worker_pair() {
clear
printf ""$YE"###################################################################################$EN
"$GR"$uk138"$EN"\n"
IP=$(echo $IPPORT1 | cut -d: -f1)
PAIR=$(adb pair "$IP":"$PORT2" $CODE | cut -d' ' -f1)
if [[ $PAIR != 'Successfully' ]]; then
printf "$date \nadb pair to \"$IP\": $PAIR\n\n" >> "$(dirname $0)"/session.log
printf ""$RE"$uk139"$EN"\n
"$WH"$uk140
$uk16"$EN" "$GR"q$EN "$WH"$uk141"$EN"
"$YE"###################################################################################$EN\n"
read -p "$uk6 " qin
case "$qin" in
  q) clear; exit 0 ;;
  *) ;;
esac
input_code
else
printf "$date \nadb pair to \"$IP\": $PAIR\n\n" >> "$(dirname $0)"/session.log
printf ""$GR"$uk142"$EN"\n"
sleep 1
worker_connect
fi
}

worker_connect() {
printf ""$YE"###################################################################################$EN
"$GR"$uk143"$EN"\n"
CONN=$(adb connect "$IPPORT1" | cut -d' ' -f1)
sleep 1
DEV=$(adb devices -l | tail +2 | cut -d: -f4 | cut -d' ' -f1)
if [[ $DEV = '' ]]; then
printf "$date \nadb connect to \"$IPPORT1\": Failure \ndevice: \"$DEV\" $CONN\n\n" >> "$(dirname $0)"/session.log
printf ""$RE"$uk144"$EN"\n
"$WH"$uk140
$uk16"$EN" "$GR"q$EN "$WH"$uk141"$EN"
"$YE"###################################################################################$EN\n"
read -p "$uk6 " qin
case "$qin" in
  q) clear; exit 0 ;;
  *) ;;
esac
ST='worker_connect'
$ST2
else
printf "$date \nadb connect to \"$IPPORT1\": Successfully \ndevice: \"$DEV\" $CONN\n\n" >> "$(dirname $0)"/session.log
printf ""$GR"$uk100 "$YE"\"$DEV\"$EN "$GR"$uk145"$EN"
"$YE"###################################################################################$EN\n"
echo "$IP" > "$(dirname $0)/SESSION.txt"
sleep 3
$RUN_ST
clear; exit 0
fi
}

start_pair_cli() {
IP=$(echo $IPPORT1 | cut -d: -f1)
printf ""$YE"###################################################################################$EN
"$GR"$uk138"$EN"\n"
PAIR=$(adb pair "$IP":"$PORT2" $CODE | cut -d' ' -f1)
if [[ $PAIR != 'Successfully' ]]; then
printf "$date \nadb pair to \"$IP\": $PAIR\n\n" >> "$(dirname $0)"/session.log
printf ""$RE"$uk139"$EN"\n"; exit 1
else
printf "$date \nadb pair to \"$IP\": $PAIR\n\n" >> "$(dirname $0)"/session.log
printf ""$GR"$uk142"$EN"\n"
start_connect_cli
fi
}

start_connect_cli() {
printf ""$YE"###################################################################################$EN
"$GR"$uk143"$EN"\n"
CONN=$(adb connect "$IPPORT1" | cut -d' ' -f1)
sleep 1
DEV=$(adb devices -l | tail +2 | cut -d: -f4 | cut -d' ' -f1)
if [[ $DEV = '' ]]; then
printf "$date \nadb connect to \"$IPPORT1\": Failure \ndevice: \"$DEV\" $CONN\n" >> "$(dirname $0)"/session.log
printf ""$RE"$uk144"$EN"\n"; exit 1
else
printf "$date \nadb connect to \"$IPPORT1\": Successfully \ndevice: \"$DEV\" $CONN\n" >> "$(dirname $0)"/session.log
printf ""$GR"$uk100 "$YE"\"$DEV\"$EN "$GR"$uk145"$EN"
"$YE"###################################################################################$EN\n"
echo "$IP" > "$(dirname $0)/SESSION.txt"
exit 0
fi
}

helpa() {
if [[ $IP = '' ]]; then
SES=""$YE"$uk146"$EN""
IPSES='IP'
else
SES=""$YE"$uk112"$EN" "$GR""$IP"$EN"
IPSES="$IP"
fi
printf ""$WH"$uk74 $VERSION \n$EN
    "$RE"./connect.sh$EN "$YE"-c$EN $uk147 "$YE"--cli$EN "$GR"IP:PORT1$EN "$GR"CODE$EN "$GR"PORT2$EN
  "$GR"IP:PORT1$EN "$WH"- \"$uk111\"$EN $uk148 "$WH"\"$uk109\"$EN.
  "$GR"CODE$EN "$WH"- \"$uk134\"$EN $uk148 "$WH"\"$uk132\"$EN.
  "$GR"PORT2$EN - "$WH"\"$uk111\"$EN $uk148 "$WH"\"$uk132\"$EN
          $uk149 "$WH"\"$uk106\"$EN $uk150
    "$RE"./connect.sh$EN "$YE"-l$EN $uk147 "$YE"--list$EN - $uk151
    "$RE"./connect.sh$EN "$YE"-s$EN $uk147 "$YE"--session$EN - $uk152
    "$RE"./connect.sh$EN "$YE"-d$EN $uk147 "$YE"--disconnect$EN - $uk153
  $uk154 "$GR"IP:PORT1$EN:
    "$RE"./connect.sh$EN "$YE"-c$EN $uk147 "$YE"--cli$EN "$GR""$IPSES":PORT1$EN\n
  $SES\n\n"
exit 0
}

check_pair() {
if [[ $CODE != '' ]]; then
ST='start_pair_cli'; check_dev
else
ST='start_connect_cli'; check_dev
fi
}

IPPORT1=$2
CODE=$3
PORT2=$4
case "$1" in
  '') ST='check_ip'; check_dev ;;
  -c|--cli) check_pair ;;
  -l|--list) ST=''; check_dev ;;
  -s|--session) session_list ;;
  -d|--disconnect) adb disconnect ;;
  -h|--help) helpa ;;
  *) printf ""$RE"$uk7"$EN"\n"; exit 1 ;;
esac
