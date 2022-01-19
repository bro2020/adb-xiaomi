#!/bin/bash

export LD_LIBRARY_PATH=./lib64:"$LD_LIBRARY_PATH"
export PATH=./:"$PATH"
APPS_LIST1=`cat ./LIST1`
APPS_LIST2=`cat ./LIST2`
APPS_LIST3=`cat ./LIST3`
DEV=$(adb devices | tail +2 | cut -f1) #для работы дожно быть +2, для отладки +1
CONNECT="./connect.sh"
F='$'
VERSION='1.0'

RE="\e[1;91m"
GR="\e[1;92m"
YE="\e[1;93m"
BL="\e[1;94m"
WH="\e[1;97m"
EN="\e[0m"

worker_rm(){
for APPS in $APPS_LIST
do
adb pull $(adb shell pm path $APPS | cut -d: -f2) ./BACKUP_APP/$APPS.apk && \
adb shell pm $COMMAND --user 0 $APPS
done &&
echo -e "$GRПроцесс $R завершен!$EN"
$STATUS
main_selectind
}

worker_restore(){
echo -e "$RE!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!
! Внимание! На телефоне потребуется вручную разрешить установку приложений  !
!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!$EN
$BLПоехали...$EN"
sleep 2
for APPS in $APPS_LIST
do
adb push ./BACKUP_APP/$APPS.apk /data/local/tmp && \
adb shell "cd /data/local/tmp/ && \
chmod +x $APPS.apk && \
pm $COMMAND --user 0 $APPS.apk && \
rm $APPS.apk" && \
rm ./BACKUP_APP/$APPS.apk
done &&
echo -e "$GRПроцесс $R завершен!$EN"
$STATUS
main_selectind
}

input(){
read -p 'Введите название приложения: ' APPS_LIST
echo -e ""$YE"_________________________________________________________________________________$EN"
worker$FUNC
}

list_all(){
echo -e "$YE*********************************************$EN"
adb shell pm list packages -u | grep $F | sort | cut -d: -f2
echo -e "$YE*********************************************$EN"
main_selectind
}

list_installed(){
echo -e "$YE*********************************************$EN"
adb shell pm list packages -3 | grep $F | sort | cut -d: -f2
echo -e "$YE*********************************************$EN"
main_selectind
}

list_system(){
echo -e "$YE*********************************************$EN"
adb shell pm list packages -s | grep $F | sort | cut -d: -f2
echo -e "$YE*********************************************$EN"
main_selectind
}

ALL_REM() { adb shell pm list packages -u | grep $F | sort | cut -d: -f2; }
ALL() { adb shell pm list packages | grep $F | sort | cut -d: -f2; }

list_removed() {
COMM=$(comm -23 <(ALL_REM) <(ALL))
echo -e "$YE*********************************************$EN"
echo "$COMM" 
echo -e "$YE*********************************************$EN"
main_selectind
}

set_filter() {
read -p "Введите слово фильтра: " F
main_selectind
}

main_selectind() {
echo -e "$YE###################################################################################$EN
$BLВыбран режим $EN"$GR"$R$EN
"$WH"Введите $EN"$GR"0$N "$WH"для выборочного $R (Можно ввести несколько приложений через пробел).
Нажмите $EN"$GR"1$N "$WH"для $R по списку $EN"$GR"LIST1$N"$WH".
Нажмите $EN"$GR"2$N "$WH"для $R по списку $EN"$GR"LIST2$N"$WH".
Нажмите $EN"$GR"3$N "$WH"для $R по списку $EN"$GR"LIST3$N"$WH".$EN
"$BL"Дополнительные опции:$EN
"$WH"Введите $EN"$GR"a$N "$WH"для отображения всех приложений.
Введите $EN"$GR"i$N "$WH"для отображения установленных приложений.
Введите $EN"$GR"s$N "$WH"для отображения системных приложений.
Введите $EN"$GR"r$N "$WH"для отображения удалённых приложений.
Введите $EN"$GR"f$N "$WH"для установки фильтра по слову.
Вышеописанные отображения будут отфильтрованы по этому слову
Для сброса фильтра нужно установить ему значение$EN "$GR"$"$EN"
"$BL"Установлен фильтр по слову: $EN"$RE"$F$EN

"$WH"Введите $EN"$GR"b$EN "$WH"для повторного выбора режима работы скрипта.
Зажмите на клавиатуре $EN"$GR"Ctrl + c$EN "$WH"для завершение работы скрипта на этом этапе.$EN
"$YE"__________________$EN"
read -p "Сделайте выбор: " m_sel
echo -e ""$YE"__________________$EN"
case $m_sel in
  0) input ;;
  1) APPS_LIST=$APPS_LIST1; worker$FUNC ;;
  2) APPS_LIST=$APPS_LIST2; worker$FUNC ;;
  3) APPS_LIST=$APPS_LIST3; worker$FUNC ;;
  a) list_all ;;
  i) list_installed ;;
  s) list_system ;;
  r) list_removed ;;
  f) set_filter ;;
  b) primary_selecting ;;
  *) echo -e "$REНеверный ввод!$EN"; main_selectind ;;
esac
}

primary_selecting() {
echo -e "$YE###################$EN
$WHВведите $EN"$GR"r$EN "$WH"для удаления приложений
Введите $EN"$GR"i$EN "$WH"для восстанолвения приложений
Зажмите на клавиатуре $EN"$GR"Ctrl + c$EN "$WH"для завершение работы скрипта на этом этапе.$EN
"$YE"__________________$EN"
read -p 'Сделайте выбор: ' p_sel
case $p_sel in
  r) COMMAND='uninstall -k'; R='удаления' FUNC='_rm'; main_selectind ;;
  i) COMMAND='install'; R='восстановления' FUNC='_restore'; main_selectind ;;
  *) echo -e "$REНеверный ввод!$EN"; primary_selecting ;;
esac
}

conn() {
echo -e "$WHВведите $EN"$GR"y$EN "$WH"для запуска скрипта подключения телефона
Введите $EN"$GR"n$EN "$WH"для завершения этого скрипта$EN
"$YE"__________________$EN"
read -p "Сделайте выбор: " con
case $con in
  y) bash $CONNECT; primary_selecting ;;
  n) exit 1 ;;
  *) echo -e "$REНеверный ввод!$EN"; conn ;;
esac
}

cli_r(){
case "$a2" in
  0) APPS_LIST="$a3" COMMAND='uninstall -k'; R='удаления'; worker_rm ;;
  1) APPS_LIST=$APPS_LIST1 COMMAND='uninstall -k'; R='удаления'; worker_rm ;;
  2) APPS_LIST=$APPS_LIST2 COMMAND='uninstall -k'; R='удаления'; worker_rm ;;
  3) APPS_LIST=$APPS_LIST3 COMMAND='uninstall -k'; R='удаления'; worker_rm ;;
  *) echo -e "$REДопущена ошибка в написании ключей$EN"; exit 1 ;;
esac

}

cli_i(){
case "$a2" in
  0) APPS_LIST="$a3" COMMAND='install'; R='восстановления'; worker_restore ;;
  1) APPS_LIST=$APPS_LIST1 COMMAND='install'; R='восстановления'; worker_restore ;;
  2) APPS_LIST=$APPS_LIST2 COMMAND='install'; R='восстановления'; worker_restore ;;
  3) APPS_LIST=$APPS_LIST3 COMMAND='install'; R='восстановления'; worker_restore ;;
  *) echo -e "$REДопущена ошибка в написании ключей$EN"; exit 1 ;;
esac
}

a2=$2
a3=$3
case "$1" in
  '') STATUS='' ;;
  -r) STATUS='exit 0'; cli_r ;;
  -i) STATUS='exit 0'; cli_i ;;
  -h) echo -e "$WHВерсия скрипта $VERSION
Ключ $EN"$YE"-r$EN - "$WH"задает режим удаления приложений.
Ключ $EN"$YE"-i$EN - "$WH"задает режим восстановления приложений.
С параметрами $EN"$YE"1-3$EN - "$WH"задается источник названий приложений.$EN
"$BL"Пример:$EN
  "$YE"./run-me.sh -r 1$EN "$WH"запускает удаление по списку$EN "$GR"LIST1$EN, "$WH"Всего 3 списка.

С параметром$EN "$YE"0$EN "$WH"название приложения задается вручную.$EN
"$BL"Пример:$EN
  "$YE"./run-me.sh -i 0 com.miui.app$EN "$WH"запускает восстановление приложения $EN"$GR"com.miui.app$EN."; exit 0 ;;
  *) echo -e "$REДопущена ошибка в написании ключей$EN"; exit 1 ;;
esac

if [[ $DEV = '' ]]; then
echo -e "$WHВерсия скрипта $VERSION"$EN"
"$RE"Телефон не обнаружен!$EN"
conn
else
echo -e "$WHВерсия скрипта $VERSION"$EN"
"$BL"Обнаружен телефон: $EN"$GR"\"$DEV\"$EN"
primary_selecting
fi
