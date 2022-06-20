#!/bin/bash

if [[ $(uname -s) != 'Linux' ]]; then
export LD_LIBRARY_PATH="$(dirname $0)/adb-macos/lib64":"$LD_LIBRARY_PATH"
export PATH="$(dirname $0)/adb-macos/":"$PATH"
SED='mac'
else
export LD_LIBRARY_PATH="$(dirname $0)/adb-linux/lib64":"$LD_LIBRARY_PATH"
export PATH="$(dirname $0)/adb-linux/":"$PATH"
SED=''
fi

source "$(dirname $0)/l10n"
local=uk
DEV=$(adb devices -l | tail -n +2 | cut -d: -f4 | cut -d' ' -f1) #для работи повинно бути +2, для налагодження +1 $uk96
CONNECT="$(dirname $0)/connect.sh"
LS_N=$(ls "$(dirname $0)"/LIST*.txt | cut -dT -f2 | cut -d. -f1)
LS=$(basename -a "$(dirname $0)"/LIST*.txt | sed 's/.txt//' | tr '\n' ' ')
F='$'
VERSION='1.2'
date=`date`

FON="2;1"
RE="\e[1;91m"
GR="\e[$FON;92m"
YE="\e[$FON;93m"
BL="\e[$FON;94m"
WH="\e[$FON;97m" # "97" - якщо фон терминала тёмный, "90" - если фон тереминала светлый $uk97
EN="\e[0m"

worker_rm(){
$CLEAR_ST
if [[ $APPS_LIST = '' ]]; then
printf ""$RE"$uk59\n$uk60"$EN"\n"
$ST
sleep 2
main_selectind
fi
printf ""$GR"$uk63 $R $uk64"$EN"\n"
sleep 2
mkdir -p "$(dirname $0)"/BACKUP_APP_"$BACK_NUM"
printf "$date\n$uk73\n" >> "$(dirname $0)"/worker.log
for APPS in $APPS_LIST
do
echo "$APPS: $uk65" >> "$(dirname $0)"/worker.log
adb pull $(adb shell pm path $APPS | cut -d: -f2) "$(dirname $0)"/BACKUP_APP_"$BACK_NUM"/$APPS.apk && \
adb shell pm $COMMAND --user 0 $APPS && echo "$APPS: $uk66" >> "$(dirname $0)"/worker.log
done &&
printf ""$GR"$uk63 $R $uk67"$EN"\n" && \
printf "$uk71\n\n" >> "$(dirname $0)"/worker.log || \
printf "$uk72\n\n" >> "$(dirname $0)"/worker.log
$ST
sleep 2
main_selectind
}

worker_rmn(){
$CLEAR_ST
if [[ $APPS_LIST = '' ]]; then
printf ""$RE"$uk59\n$uk60$EN\n"
$ST
sleep 2
main_selectind
fi
printf ""$GR"$uk63 $R $uk64"$EN"\n"
sleep 2
printf "$date\n$uk70\n" >> "$(dirname $0)"/worker.log
for APPS in $APPS_LIST
do
echo "$APPS: $uk65" >> "$(dirname $0)"/worker.log
adb shell pm $COMMAND --user 0 $APPS && echo "$APPS: $uk66" >> "$(dirname $0)"/worker.log
done &&
printf ""$GR"$uk63 $R $uk67"$EN"\n" && \
printf "$uk71\n\n" >> "$(dirname $0)"/worker.log || \
printf "$uk72\n\n" >> "$(dirname $0)"/worker.log
$ST
sleep 2
main_selectind
}

worker_restore(){
$CLEAR_ST
if [[ $APPS_LIST = '' ]]; then
printf ""$RE"$uk59\n$uk60"$EN"\n"
$ST
sleep 2
main_selectind
fi
printf "$date\n$uk61\n" >> "$(dirname $0)"/worker.log
printf ""$RE"!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!
!  $uk62 !
!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!$EN
"$GR"$uk63 $R $uk64"$EN"\n"
sleep 2
for APPS in $APPS_LIST
do
echo "$APPS: $uk65" >> "$(dirname $0)"/worker.log
adb push "$(dirname $0)"/BACKUP_APP_"$BACK_NUM"/$APPS.apk /data/local/tmp && \
adb shell "cd /data/local/tmp/ && \
chmod +x $APPS.apk && \
pm $COMMAND --user 0 $APPS.apk && exit 0 || rm $APPS.apk; exit 1" && echo "$APPS: $uk66" >> "$(dirname $0)"/worker.log && \
adb shell rm /data/local/tmp/$APPS.apk && \
rm "$(dirname $0)"/BACKUP_APP_"$BACK_NUM"/$APPS.apk
done &&
printf ""$GR"$uk63 $R $uk67"$EN"\n" && \
printf "$uk68\n\n" >> "$(dirname $0)"/worker.log || \
printf "$uk69\n\n" >> "$(dirname $0)"/worker.log
$ST
sleep 2
main_selectind
}

input_0(){
clear
read -p "$uk50 " APPS_LIST
printf ""$YE"_________________________________________________________________________________$EN\n"
worker$FUNC
}

list_a_u_s(){
$CLEAR_ST
res_count=$(adb shell pm list packages -$KEY | grep $F | wc -l)
printf ""$YE"*******************************************************$EN
"$YE"************$EN  $(printf '%16s %2s\n' "$KEY_NAME") $uk58  "$YE"************$EN
"$YE"**$EN $uk40 "$GR"$uk41"$EN" - $uk42, "$GR"q$EN - $uk43 "$YE"**$EN
"$YE"*******************************************************$EN
"$YE"$uk44"$EN" $res_count
$(adb shell pm list packages -$KEY | grep $F | sort | cut -d: -f2)
"$YE"*******************************************************$EN\n" | $LESS_ST
$ST
main_selectind
}

ALL_REM() { adb shell pm list packages -u | grep $F | sort | cut -d: -f2; }
ALL() { adb shell pm list packages | grep $F | sort | cut -d: -f2; }

list_removed() {
$CLEAR_ST
COMM=$(comm -23 <(ALL_REM) <(ALL))
res_count=$(echo "$COMM" | wc -l)
printf ""$YE"*******************************************************$EN
"$YE"****************$EN  $uk57  "$YE"***************$EN
"$YE"**$EN $uk40 "$GR"$uk41"$EN" - $uk42, "$GR"q$EN - $uk43 "$YE"**$EN
"$YE"*******************************************************$EN
"$YE"$uk44"$EN" $res_count
$(echo "$COMM" )
"$YE"*******************************************************$EN\n" | $LESS_ST
$ST
main_selectind
}

set_filter() {
clear
read -p "$uk56 " F
main_selectind
}

echo_list() {
clear
read -p "$uk48 " n_lst
ECHO_LST=$(cat "$(dirname $0)"/LIST"$n_lst".txt | grep $F)
count=$(echo "$ECHO_LST" | wc -l)
res_count=$(expr $count - 2)
printf ""$YE"*******************************************************$EN
"$YE"**************$EN  $uk39 LIST"$n_lst" "$YE"***************$EN
"$YE"**$EN $uk40 "$GR"$uk41"$EN" - $uk42, "$GR"q$EN - $uk43 "$YE"**$EN
"$YE"*******************************************************$EN
"$YE"$uk44"$EN" $res_count
$(echo "$ECHO_LST")
"$YE"*******************************************************$EN\n" | less -R
main_selectind
}

add_to_list() {
clear
read -p "$uk48 " nom_list
read -p "$uk50 " name_app
touch "$(dirname $0)"/LIST"$nom_list".txt
if [[ $(cat "$(dirname $0)"/LIST"$nom_list".txt) = '' ]]; then
echo "$uk53, $date
" >> "$(dirname $0)"/LIST"$nom_list".txt
fi
echo "$name_app" | tr ' ' '\n' | tee >> "$(dirname $0)"/LIST"$nom_list".txt && \
printf ""$GR"$uk54"$EN" "$YE""$name_app"$EN "$GR"$uk55"$EN" "$YE"LIST"$nom_list"$EN"$GR" ...$EN\n"
sleep 2
main_selectind
}

del_to_list() {
clear
SED1=''
SED2='macsed=lox'
read -p "$uk48 " nom_list
read -p "$uk50 " name_app
if [[ $SED = 'mac' ]]; then
SED1='.back'
SED2="rm "$(dirname $0)"/LIST"$nom_list".txt.back"
fi
sed -i$SED1 "/^$name_app$/d" "$(dirname $0)"/LIST"$nom_list".txt && $SED2 && \
printf ""$GR"$uk51"$EN" "$YE""$name_app"$EN "$GR"$uk52"$EN" "$YE"LIST"$nom_list"$EN"$GR" ...$EN\n"
sleep 2
main_selectind
}

del_all_to_list() {
clear
read -p "$uk48 " nom_list
echo -n > "$(dirname $0)"/LIST"$nom_list".txt && \
printf ""$GR"$uk49"$EN" "$YE"LIST"$nom_list"$EN"$GR" ...$EN\n"
sleep 2
main_selectind
}

main_selectind() {
clear
printf ""$YE"###################################################################################$EN
"$BL"$uk20 $EN"$GR"$R$EN
  "$WH"$uk3 $EN"$GR"0$N "$WH"- $uk21 $R $uk22
  $uk3 $EN"$GR"1...n$EN "$WH"- $uk23 $R $uk24 $EN"$YE"LIST$EN"$GR"1...n$EN"$WH".
  $uk25 $EN "$YE"$LS\n$EN
"$BL"$uk26 $EN
  "$WH"$uk3 $EN"$GR"ls$N "$WH"- $uk27
  $uk3 $EN"$GR"add$N "$WH"- $uk28
  $uk3 $EN"$GR"del$N "$WH"- $uk29
  $uk3 $EN"$GR"del -a$N "$WH"- $uk30
  $uk3 $EN"$GR"a$N "$WH"- $uk31
  $uk3 $EN"$GR"u$N "$WH"- $uk32
  $uk3 $EN"$GR"s$N "$WH"- $uk33
  $uk3 $EN"$GR"d$N "$WH"- $uk34
  $uk3 $EN"$GR"f$N "$WH"- $uk35
\n$uk36 $EN "$GR"$"$EN"
"$BL"$uk37 $EN"$RE"$F$EN

"$WH"$uk3 $EN"$GR"b$EN "$WH"$uk38
$uk3 $EN"$GR"q$EN "$WH"$uk5 $EN
"$YE"_______________________$EN\n"
read -p "$uk6" m_sel
printf ""$YE"_______________________$EN\n"
if [[ "$(echo $LS_N | tr ' ' '\n' | grep -cx $m_sel)" -ge 1 ]]; then
BACK_NUM="$m_sel" CLEAR_ST='clear' APPS_LIST=$(cat "$(dirname $0)"/LIST"$m_sel".txt | tail -n +3 | cut -d' ' -f1); worker$FUNC
fi
case "$m_sel" in
  0) CLEAR_ST='clear' BACK_NUM="$m_sel"; input_0 ;;
  ls) echo_list ;;
  add) add_to_list ;;
  del) del_to_list ;;
  "del -a") del_all_to_list ;;
  a) LESS_ST='less -R' CLEAR_ST='clear' KEY=a KEY_NAME="$uk45"; list_a_u_s ;;
  u) LESS_ST='less -R' CLEAR_ST='clear' KEY=3 KEY_NAME="$uk46"; list_a_u_s ;;
  s) LESS_ST='less -R' CLEAR_ST='clear' KEY=s KEY_NAME="$uk47"; list_a_u_s ;;
  d) LESS_ST='less -R' CLEAR_ST='clear' list_removed ;;
  f) set_filter ;;
  b) primary_selecting ;;
  q) clear; exit 0 ;;
  *) printf ""$RE"$uk7$EN\n"; sleep 2; main_selectind ;;
esac
}

primary_selecting() {
clear
printf ""$BL"$uk2 $EN"$GR"\"$DEV\"$EN\n
"$YE"###################################################################################$EN
"$RE"$uk8$EN "$YE"\"$uk9\"$EN
"$RE"$uk10$EN "$YE"\"$uk11\"$EN "$RE"$uk12$EN

  "$WH"$uk3 $EN"$GR"r$EN "$WH"- $uk13
  $uk3 $EN"$GR"rn$EN "$WH"- $uk14
  $uk3 $EN"$GR"i$EN "$WH"- $uk15

$uk16 $EN"$GR"q$EN "$WH"$uk5$EN
"$YE"_______________________$EN\n"
read -p "$uk6" p_sel
case $p_sel in
  r) COMMAND='uninstall -k' R="$uk17" FUNC='_rm'; main_selectind ;;
  rn) COMMAND='uninstall -k' R="$uk18" FUNC='_rmn'; main_selectind ;;
  i) COMMAND='install' R="$uk19" FUNC='_restore'; main_selectind ;;
  q) clear; exit 0 ;;
  *) printf ""$RE"$uk7$EN\n"; sleep 2; primary_selecting ;;
esac
}

conn() {
clear
printf ""$RE"$uk1$EN\n
"$WH"  $uk3 $EN"$GR"y$EN "$WH"$uk4
  $uk3 $EN"$GR"q$EN "$WH"$uk5$EN
"$YE"_______________________$EN\n"
read -p "$uk6" con
case $con in
  y) RUN_ST="source $0" source $CONNECT; primary_selecting ;;
  q) clear; exit 0 ;;
  *) printf ""$RE"$uk7$EN"; sleep 2; conn ;;
esac
}

cli_w(){
if [[ "$a2" -eq 0 ]]; then
APPS_LIST="$a3"; worker$FUNC
fi
if [[ "$(echo $LS_N | tr ' ' '\n' | grep -cx $a2)" -ge 1 ]]; then
APPS_LIST=$(cat "$(dirname $0)"/LIST"$a2".txt | tail +3 | cut -d' ' -f1); worker$FUNC
else
printf "\n"$RE"$uk7 $EN
"$WH"$uk25 $EN"$YE"$LS\n$EN\n"
exit 1
fi
}

lst(){
ECHO_LST=$(cat "$(dirname $0)"/LIST"$a2".txt | grep $F)
count=$(echo "$ECHO_LST" | wc -l)
res_count=$(expr $count - 2)
printf ""$YE"*******************************************************$EN
"$YE"**************$EN  $uk39 LIST"$a2" "$YE"***************$EN
"$YE"**$EN $uk40 "$GR"$uk41"$EN" - $uk42, "$GR"q$EN - $uk43 "$YE"**$EN
"$YE"*******************************************************$EN
"$YE"$uk44"$EN" $res_count
$(echo "$ECHO_LST")
"$YE"*******************************************************$EN\n"
exit 0
}

helpa() {
printf ""$WH"$uk74 $VERSION

  $uk75 $EN"$YE"ls$EN - "$WH"$uk76"$EN"
       "$BL"$uk77"$EN"
          "$RE"./run-me.sh $EN"$YE"ls $EN"$GR"1$EN "$WH"- $uk78"$EN" "$GR"LIST1$EN

       "$YE"$uk25"$EN" "$GR"$LS$EN

  "$WH"$uk75 $EN"$GR"-a$N "$WH"- $uk31
  $uk75 $EN"$GR"-u$N "$WH"- $uk32
  $uk75 $EN"$GR"-s$N "$WH"- $uk33
  $uk75 $EN"$GR"-d$N "$WH"- $uk34
       "$BL"$uk77"$EN"
          "$RE"./run-me.sh $EN"$GR"-u$EN "$WH"- $uk80

  $uk75 $EN"$YE"-r$EN - "$WH"$uk81
  $uk75 $EN"$YE"-rn$EN - "$WH"$uk82
  $uk75 $EN"$YE"-i$EN - "$WH"$uk83

    $uk84 $EN"$GR"1-n$EN - "$WH"$uk85"$EN"
       "$BL"$uk77"$EN"
          "$RE"./run-me.sh $EN"$YE"-r $EN"$GR"2$EN "$WH"- $uk86"$EN" "$GR"LIST2$EN "$WH"

    "$WH"$uk87"$EN" "$GR"0$EN "$WH"$uk88"$EN"
       "$BL"$uk77"$EN"
          "$RE"./run-me.sh $EN"$YE"-i $EN"$GR"0 'com.miui.app1 com.miui.app2'$EN "$WH"- $uk89
       $EN"$GR"com.miui.app1$EN "$WH"$uk95"$EN" "$GR"com.miui.app2$EN

  "$WH"$uk90"$EN" "$GR"apk$EN "$WH"$uk91"$EN" "$GR"BACKUP_APP_0$EN.
  "$WH"$uk92"$EN" "$GR"0$EN. "$WH"$uk93"$EN" "$GR".apk$EN "$WH"$uk94"$EN"

  "$RE"$uk8"$EN" "$YE"\"$uk9\"$EN
  "$RE"$uk10"$EN" "$YE"\"$uk11\"$EN "$RE"$uk12"$EN"\n\n"; exit 0
}

a2=$2
a3=$3
case "$1" in
  '') ST='' ;;
  -r) ST='exit 0' CLEAR_ST='' COMMAND='uninstall -k' R='удаления' FUNC='_rm'  BACK_NUM="$a2"; cli_w ;;
  -rn) ST='exit 0' CLEAR_ST='' COMMAND='uninstall -k' R='удаления без бекапа' FUNC='_rmn'; cli_w ;;
  -i) ST='exit 0' CLEAR_ST='' COMMAND='install' R='восстановления' FUNC='_restore' BACK_NUM="$a2";  cli_w ;;
  ls) lst ;;
  -a) ST='exit 0' LESS_ST='tee' CLEAR_ST='' KEY=a KEY_NAME='Все'; list_a_u_s ;;
  -u) ST='exit 0' LESS_ST='tee' CLEAR_ST='' KEY=3 KEY_NAME='Установленные'; list_a_u_s ;;
  -s) ST='exit 0' LESS_ST='tee' CLEAR_ST='' KEY=s KEY_NAME='Системные'; list_a_u_s ;;
  -d) ST='exit 0' LESS_ST='tee' CLEAR_ST=''; list_removed ;;
  -h|--help) helpa ;;
  *) printf ""$RE"Допущена ошибка в написании ключей!$EN\n"; exit 1 ;;
esac

clear
if [[ $DEV = '' ]]; then
conn
else
primary_selecting
fi
