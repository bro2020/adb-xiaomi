#!/bin/bash

export LD_LIBRARY_PATH=./lib64:"$LD_LIBRARY_PATH"
export PATH=./:"$PATH"
APPS_LIST1=`cat ./LIST1`
APPS_LIST2=`cat ./LIST2`
APPS_LIST3=`cat ./LIST3`
DEV=$(adb devices -l | tail +2 | cut -d: -f4 | cut -d' ' -f1) #для работы дожно быть +2, для отладки +1
CONNECT="./connect.sh"
F='$'
VERSION='1.0'

FON="1" # "1" - если фон терминала тёмный, "2;1" - если фон тереминала светлый
RE="\e[$FON;91m"
GR="\e[$FON;92m"
YE="\e[$FON;93m"
BL="\e[$FON;94m"
WH="\e[$FON;97m"
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
pm $COMMAND --user 0 $APPS.apk && exit 0 || rm $APPS.apk; exit 1" && \
adb shell rm /data/local/tmp/$APPS.apk && \
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
echo -e "$YE*********************************************$EN
"$YE"*************  Все приложения  **************$EN
"$YE"*********************************************$EN"
adb shell pm list packages -u | grep $F | sort | cut -d: -f2
echo -e "$YE*********************************************$EN"
$STATUS
main_selectind
}

list_installed(){
echo -e "$YE*********************************************$EN
"$YE"********  Установленные приложения  *********$EN
"$YE"*********************************************$EN"
adb shell pm list packages -3 | grep $F | sort | cut -d: -f2
echo -e "$YE*********************************************$EN"
$STATUS
main_selectind
}

list_system(){
echo -e "$YE*********************************************$EN
"$YE"**********  Системные приложения  ***********$EN
"$YE"*********************************************$EN"
adb shell pm list packages -s | grep $F | sort | cut -d: -f2
echo -e "$YE*********************************************$EN"
$STATUS
main_selectind
}

ALL_REM() { adb shell pm list packages -u | grep $F | sort | cut -d: -f2; }
ALL() { adb shell pm list packages | grep $F | sort | cut -d: -f2; }

list_removed() {
COMM=$(comm -23 <(ALL_REM) <(ALL))
echo -e "$YE*********************************************$EN
"$YE"**********  Удаленные приложения  ***********$EN
"$YE"*********************************************$EN"
echo "$COMM" 
echo -e "$YE*********************************************$EN"
$STATUS
main_selectind
}

set_filter() {
read -p "Введите слово фильтра: " F
main_selectind
}

main_selectind() {
echo -e "$YE###################################################################################$EN
$BLВыбран режим $EN"$GR"$R$EN
  "$WH"Введите $EN"$GR"0$N "$WH"- для выборочного $R (Можно ввести несколько имён приложений через пробел).
  Нажмите $EN"$GR"1$N "$WH"- для $R по списку $EN"$GR"LIST1$N"$WH".
  Нажмите $EN"$GR"2$N "$WH"- для $R по списку $EN"$GR"LIST2$N"$WH".
  Нажмите $EN"$GR"3$N "$WH"- для $R по списку $EN"$GR"LIST3$N"$WH".$EN
"$BL"Дополнительные опции:$EN
  "$WH"Введите $EN"$GR"a$N "$WH"- для отображения всех приложений.
  Введите $EN"$GR"i$N "$WH"- для отображения установленных приложений.
  Введите $EN"$GR"s$N "$WH"- для отображения системных приложений.
  Введите $EN"$GR"r$N "$WH"- для отображения удалённых приложений.
  Введите $EN"$GR"f$N "$WH"- для установки фильтра по слову.
Вышеописанные отображения будут отфильтрованы по этому слову
Для сброса фильтра нужно установить ему значение$EN "$GR"$"$EN"
"$BL"Установлен фильтр по слову: $EN"$RE"$F$EN

"$WH"Введите $EN"$GR"b$EN "$WH"для повторного выбора режима работы скрипта.
Введите $EN"$GR"q$EN "$WH"для завершение работы скрипта на этом этапе.$EN
"$YE"_______________________$EN"
read -p "Сделайте выбор здесь: " m_sel
echo -e ""$YE"_______________________$EN"
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
  q) exit 0 ;;
  *) echo -e "$REНеверный ввод!$EN"; main_selectind ;;
esac
}

primary_selecting() {
echo -e "$YE###################################################################################$EN
"$RE"Для $EN"$YE"восстановления$EN "$RE"приложений в настройках смартфона$EN "$YE"\"Для разработчиков\"$EN
"$RE"ползунок$EN "$YE"\"Установка через USB\"$EN "$RE"должен быть установлен во$EN "$YE"ВКЛЮЧЕННОЕ$EN "$RE"положение$EN

  "$WH"Введите $EN"$GR"r$EN "$WH"- для удаления приложений
  Введите $EN"$GR"i$EN "$WH"- для восстанолвения приложений

Введите $EN"$GR"q$EN "$WH"для завершение работы скрипта на этом этапе.$EN
"$YE"_______________________$EN"
read -p 'Сделайте выбор здесь: ' p_sel
case $p_sel in
  r) COMMAND='uninstall -k'; R='удаления' FUNC='_rm'; main_selectind ;;
  i) COMMAND='install'; R='восстановления' FUNC='_restore'; main_selectind ;;
  q) exit 0 ;;
  *) echo -e "$REНеверный ввод!$EN"; primary_selecting ;;
esac
}

conn() {
echo -e "$WH  Введите $EN"$GR"y$EN "$WH"для запуска скрипта подключения телефона
  Введите $EN"$GR"n$EN "$WH"для завершения этого скрипта$EN
"$YE"_______________________$EN"
read -p "Сделайте выбор здесь: " con
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

lst(){
case "$a2" in
  -a) list_all ;;
  -i) list_installed ;;
  -s) list_system ;;
  -r) list_removed ;;
  *) echo -e "$REДопущена ошибка в написании ключей$EN"; exit 1 ;;
esac
}

helpa() {
echo -e "$WHВерсия скрипта $VERSION

  Ключ $EN"$YE"-r$EN - "$WH"задает режим УДАЛЕНИЯ приложений.
  Ключ $EN"$YE"-i$EN - "$WH"задает режим ВОССТАНОВЛЕНИЯ приложений.
  Ключ $EN"$YE"ls$EN - "$WH"используя параметры, выводит списки приложений
    $EN"$GR"-a$N "$WH"- отображает все приложеня.
    $EN"$GR"-i$N "$WH"- отображает установленные приложения.
    $EN"$GR"-s$N "$WH"- отображает системные приложения.
    $EN"$GR"-r$N "$WH"- отображает удалённые приложения.
       "$BL"Пример:$EN
          "$RE"./run-me.sh $EN"$YE"ls $EN"$GR"-i$EN "$WH"- отображает список всех установленых пользователем приложений

  Для ключей $EN"$YE"-r$EN "$WH"и$EN "$YE"-i$EN"$WH":

  С параметрами $EN"$GR"1-3$EN - "$WH"задается список имён приложений.$EN
       "$BL"Пример:$EN
          "$RE"./run-me.sh $EN"$YE"-r $EN"$GR"1$EN "$WH"- запускает удаление приложений из списка$EN "$GR"LIST1$EN "$WH"(Всего 3 списка)

  С параметром$EN "$GR"0$EN "$WH"имена приложений задаются вручную через пробел.$EN
       "$BL"Пример:$EN
          "$RE"./run-me.sh $EN"$YE"-i $EN"$GR"0 com.miui.app1 com.miui.app2$EN "$WH"- запускает восстановление приложений
       $EN"$GR"com.miui.app1$EN "$WH"и$EN "$GR"com.miui.app2$EN

  "$WH"Для простой УСТАНОВКИ приложений, их$EN "$GR"apk$EN "$WH"файлы нужно разместить в директории$EN "$GR"BACKUP_APP$EN.
  "$WH"Запустить восстановление с параметром$EN "$GR"0$EN. "$WH"В качестве имён через пробел указать названия файлов
  (без$EN "$GR".apk$EN "$WH"вконце).$EN

  "$RE"Для УСТАНОВКИ и ВОССТАНОВЛЕНИЯ приложений в настройках смартфона$EN "$YE"\"Для разработчиков\"$EN
  "$RE"ползунок$EN "$YE"\"Установка через USB\"$EN "$RE"должен быть установлен во$EN "$YE"ВКЛЮЧЕННОЕ$EN "$RE"положение.$EN"; exit 0
}

a2=$2
a3=$3
case "$1" in
  '') STATUS='' ;;
  -r) STATUS='exit 0'; cli_r ;;
  -i) STATUS='exit 0'; cli_i ;;
  ls) STATUS='exit 0'; lst ;;
  -h|--help) helpa ;;
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
