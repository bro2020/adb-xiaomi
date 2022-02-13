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

DEV=$(adb devices -l | tail -n +2 | cut -d: -f4 | cut -d' ' -f1) #для работы дожно быть +2, для отладки +1
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
WH="\e[$FON;97m" # "97" - если фон терминала тёмный, "90" - если фон тереминала светлый
EN="\e[0m"

worker_rm(){
$CLEAR_ST
if [[ $APPS_LIST = '' ]]; then
printf ""$RE"Список приложений пуст!\nПроцесс не выполнен!$EN\n"
$ST
sleep 2
main_selectind
fi
printf ""$GR"Процесс $R запущен...$EN\n"
sleep 2
mkdir -p "$(dirname $0)"/BACKUP_APP_"$BACK_NUM"
printf "$date\nЗапущено удаление приложений:\n" >> "$(dirname $0)"/worker.log
for APPS in $APPS_LIST
do
echo "$APPS: Старт..." >> "$(dirname $0)"/worker.log
adb pull $(adb shell pm path $APPS | cut -d: -f2) "$(dirname $0)"/BACKUP_APP_"$BACK_NUM"/$APPS.apk && \
adb shell pm $COMMAND --user 0 $APPS && echo "$APPS: Успех" >> "$(dirname $0)"/worker.log
done &&
printf ""$GR"Процесс $R успешно завершен!$EN\n" && \
printf "Удаление завершено!\n\n" >> "$(dirname $0)"/worker.log || \
printf "Удаление завершено с ошибками!\n\n" >> "$(dirname $0)"/worker.log
$ST
sleep 2
main_selectind
}

worker_rmn(){
$CLEAR_ST
if [[ $APPS_LIST = '' ]]; then
printf ""$RE"Список приложений пуст!\nПроцесс не выполнен!$EN\n"
$ST
sleep 2
main_selectind
fi
printf ""$GR"Процесс $R запущен...$EN\n"
sleep 2
printf "$date\nЗапущено удаление приложений без бекапа:\n" >> "$(dirname $0)"/worker.log
for APPS in $APPS_LIST
do
echo "$APPS: Старт..." >> "$(dirname $0)"/worker.log
adb shell pm $COMMAND --user 0 $APPS && echo "$APPS: Успех" >> "$(dirname $0)"/worker.log
done &&
printf ""$GR"Процесс $R успешно завершен!$EN\n" && \
printf "Удаление завершено!\n\n" >> "$(dirname $0)"/worker.log || \
printf "Удаление завершено с ошибками!\n\n" >> "$(dirname $0)"/worker.log
$ST
sleep 2
main_selectind
}

worker_restore(){
$CLEAR_ST
if [[ $APPS_LIST = '' ]]; then
printf ""$RE"Список приложений пуст!\nПроцесс не выполнен!$EN\n"
$ST
sleep 2
main_selectind
fi
printf "$date\nЗапущено восстановлеение приложений:\n" >> "$(dirname $0)"/worker.log
printf ""$RE"!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!
!  ВНИМАНИЕ! Сейчас на экране телефона потребуется вручную разрешить установку приложений !
!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!$EN
"$GR"Процесс $R запущен...$EN\n"
sleep 2
for APPS in $APPS_LIST
do
echo "$APPS: Старт..." >> "$(dirname $0)"/worker.log
adb push "$(dirname $0)"/BACKUP_APP_"$BACK_NUM"/$APPS.apk /data/local/tmp && \
adb shell "cd /data/local/tmp/ && \
chmod +x $APPS.apk && \
pm $COMMAND --user 0 $APPS.apk && exit 0 || rm $APPS.apk; exit 1" && echo "$APPS: Успех" >> "$(dirname $0)"/worker.log && \
adb shell rm /data/local/tmp/$APPS.apk && \
rm "$(dirname $0)"/BACKUP_APP_"$BACK_NUM"/$APPS.apk
done &&
printf ""$GR"Процесс $R успешно завершен!$EN\n" && \
printf "Восстановление завершено!\n\n" >> "$(dirname $0)"/worker.log || \
printf "Восстановление завершено с ошибками!\n\n" >> "$(dirname $0)"/worker.log
$ST
sleep 2
main_selectind
}

input_0(){
clear
read -p 'Введите название приложения: ' APPS_LIST
printf ""$YE"_________________________________________________________________________________$EN\n"
worker$FUNC
}

list_a_u_s(){
$CLEAR_ST
res_count=$(adb shell pm list packages -$KEY | grep $F | wc -l)
printf ""$YE"*******************************************************$EN
"$YE"************$EN  $(printf '%16s %2s\n' "$KEY_NAME") приложения  "$YE"************$EN
"$YE"**$EN Кнопки "$GR"вверх-вниз$EN - для прокрутки, "$GR"q$EN - для выхода "$YE"**$EN
"$YE"*******************************************************$EN
"$YE"Всего приложений:$EN $res_count
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
"$YE"****************$EN  Удаленные приложения  "$YE"***************$EN
"$YE"**$EN Кнопки "$GR"вверх-вниз$EN - для прокрутки, "$GR"q$EN - для выхода "$YE"**$EN
"$YE"*******************************************************$EN
"$YE"Всего приложений:$EN $res_count
$(echo "$COMM" )
"$YE"*******************************************************$EN\n" | $LESS_ST
$ST
main_selectind
}

set_filter() {
clear
read -p "Введите слово фильтра: " F
main_selectind
}

echo_list() {
clear
read -p 'Ввведите номер списка: ' n_lst
ECHO_LST=$(cat "$(dirname $0)"/LIST"$n_lst".txt | grep $F)
count=$(echo "$ECHO_LST" | wc -l)
res_count=$(expr $count - 2)
printf ""$YE"*******************************************************$EN
"$YE"**************$EN  Список приложений LIST"$n_lst" "$YE"***************$EN
"$YE"**$EN Кнопки "$GR"вверх-вниз$EN - для прокрутки, "$GR"q$EN - для выхода "$YE"**$EN
"$YE"*******************************************************$EN
"$YE"Всего приложений:$EN $res_count
$(echo "$ECHO_LST")
"$YE"*******************************************************$EN\n" | less -R
main_selectind
}

add_to_list() {
clear
read -p "Введите номер списка: " nom_list
read -p "Введите имя приложения: " name_app
touch "$(dirname $0)"/LIST"$nom_list".txt
if [[ $(cat "$(dirname $0)"/LIST"$nom_list".txt) = '' ]]; then
echo "Список создан скриптом $date
" >> "$(dirname $0)"/LIST"$nom_list".txt
fi
echo "$name_app" | tr ' ' '\n' | tee >> "$(dirname $0)"/LIST"$nom_list".txt && \
printf ""$GR"Добавление приложения$EN "$YE""$name_app"$EN "$GR"в список$EN "$YE"LIST"$nom_list"$EN"$GR" ...$EN\n"
sleep 2
main_selectind
}

del_to_list() {
clear
SED1=''
SED2='macsed=lox'
read -p "Введите номер списка: " nom_list
read -p "Введите имя приложения: " name_app
if [[ $SED = 'mac' ]]; then
SED1='.back'
SED2="rm "$(dirname $0)"/LIST"$nom_list".txt.back"
fi
sed -i$SED1 "/^$name_app$/d" "$(dirname $0)"/LIST"$nom_list".txt && $SED2 && \
printf ""$GR"Удаление приложение$EN "$YE""$name_app"$EN "$GR"из списка$EN "$YE"LIST"$nom_list"$EN"$GR" ...$EN\n"
sleep 2
main_selectind
}

del_all_to_list() {
clear
read -p "Введите номер списка: " nom_list
echo -n > "$(dirname $0)"/LIST"$nom_list".txt && \
printf ""$GR"Очистка списка$EN "$YE"LIST"$nom_list"$EN"$GR" ...$EN\n"
sleep 2
main_selectind
}

main_selectind() {
clear
printf ""$YE"###################################################################################$EN
"$BL"Выбран режим $EN"$GR"$R$EN
  "$WH"Введите $EN"$GR"0$N "$WH"- для выборочного $R (Можно ввести несколько имён приложений через пробел).
  Введите $EN"$GR"1...n$EN "$WH"- для $R по списку приложений $EN"$GR"LIST1...n$EN"$WH".
  Обнаруженные списки приложений:$EN "$YE"$LS\n$EN
"$BL"Дополнительные опции:$EN
  "$WH"Введите $EN"$GR"ls$N "$WH"- для выбора списка приложений и отображения его содержимого.
  Введите $EN"$GR"add$N "$WH"- для добавления нового имени приложения в список.
  Введите $EN"$GR"del$N "$WH"- для удаления имени приложения из списка.
  Введите $EN"$GR"del -a$N "$WH"- для полной очистки списка.
  Введите $EN"$GR"a$N "$WH"- для отображения всех приложений.
  Введите $EN"$GR"u$N "$WH"- для отображения установленных приложений.
  Введите $EN"$GR"s$N "$WH"- для отображения системных приложений.
  Введите $EN"$GR"d$N "$WH"- для отображения удалённых приложений.
  Введите $EN"$GR"f$N "$WH"- для установки фильтра по слову.
Вышеописанные отображения будут отфильтрованы по этому слову
Для сброса фильтра нужно установить ему значение$EN "$GR"$"$EN"
"$BL"Установлен фильтр по слову: $EN"$RE"$F$EN

"$WH"Введите $EN"$GR"b$EN "$WH"для повторного выбора режима работы скрипта.
Введите $EN"$GR"q$EN "$WH"для завершение работы скрипта на этом этапе.$EN
"$YE"_______________________$EN\n"
read -p "Сделайте выбор здесь: " m_sel
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
  a) LESS_ST='less -R' CLEAR_ST='clear' KEY=a KEY_NAME='Все'; list_a_u_s ;;
  u) LESS_ST='less -R' CLEAR_ST='clear' KEY=3 KEY_NAME='Установленные'; list_a_u_s ;;
  s) LESS_ST='less -R' CLEAR_ST='clear' KEY=s KEY_NAME='Системные'; list_a_u_s ;;
  d) LESS_ST='less -R' CLEAR_ST='clear' list_removed ;;
  f) set_filter ;;
  b) primary_selecting ;;
  q) clear; exit 0 ;;
  *) printf ""$RE"Введён недопустимый символ!$EN\n"; sleep 2; main_selectind ;;
esac
}

primary_selecting() {
clear
printf ""$YE"###################################################################################$EN
"$RE"Для ВОССТАНОВЛЕНИЯ приложений в настройках смартфона$EN "$YE"\"Для разработчиков\"$EN
"$RE"переключатель$EN "$YE"\"Установка через USB\"$EN "$RE"должен быть ВКЛЮЧЕН!$EN

  "$WH"Введите $EN"$GR"r$EN "$WH"- для удаления приложений.
  Введите $EN"$GR"rn$EN "$WH"- для удаления приложений без бекапа.
  Введите $EN"$GR"i$EN "$WH"- для восстановления приложений.

Или введите $EN"$GR"q$EN "$WH"для завершение работы скрипта.$EN
"$YE"_______________________$EN\n"
read -p 'Сделайте выбор здесь: ' p_sel
case $p_sel in
  r) COMMAND='uninstall -k' R='удаления' FUNC='_rm'; main_selectind ;;
  rn) COMMAND='uninstall -k' R='удаления без бекапа' FUNC='_rmn'; main_selectind ;;
  i) COMMAND='install' R='восстановления' FUNC='_restore'; main_selectind ;;
  q) clear; exit 0 ;;
  *) printf ""$RE"Неверный ввод!$EN\n"; sleep 2; primary_selecting ;;
esac
}

conn() {
printf ""$WH"  Введите $EN"$GR"y$EN "$WH"для запуска скрипта подключения телефона.
  Введите $EN"$GR"q$EN "$WH"для завершения работы этого скрипта.$EN
"$YE"_______________________$EN\n"
read -p "Сделайте выбор здесь: " con
case $con in
  y) RUN_ST="source $0" source $CONNECT; primary_selecting ;;
  q) clear; exit 0 ;;
  *) printf "$REНеверный ввод!$EN"; sleep 2; conn ;;
esac
}

cli_w(){
if [[ "$a2" -eq 0 ]]; then
APPS_LIST="$a3"; worker$FUNC
fi
if [[ "$(echo $LS_N | tr ' ' '\n' | grep -cx $a2)" -ge 1 ]]; then
APPS_LIST=$(cat "$(dirname $0)"/LIST"$a2".txt | tail +3 | cut -d' ' -f1); worker$FUNC
else
printf "\n"$RE"Допущена ошибка в написании ключей!$EN
"$WH"Обнаруженные списки приложений:$EN "$YE"$LS\n$EN\n"
exit 1
fi
}

lst(){
ECHO_LST=$(cat "$(dirname $0)"/LIST"$a2".txt | grep $F)
count=$(echo "$ECHO_LST" | wc -l)
res_count=$(expr $count - 2)
printf ""$YE"*******************************************************$EN
"$YE"**************$EN  Список приложений LIST"$a2" "$YE"***************$EN
"$YE"**$EN Кнопки "$GR"вверх-вниз$EN - для прокрутки, "$GR"q$EN - для выхода "$YE"**$EN
"$YE"*******************************************************$EN
"$YE"Всего приложений:$EN $res_count
$(echo "$ECHO_LST")
"$YE"*******************************************************$EN\n"
exit 0
}

helpa() {
printf ""$WH"Версия скрипта $VERSION

  Ключ $EN"$YE"ls$EN - "$WH"используя аргументы, выводит содержимое списков приложений.
       "$BL"Пример:$EN
          "$RE"./run-me.sh $EN"$YE"ls $EN"$GR"1$EN "$WH"- отобразит содержимое списка$EN "$GR"LIST1$EN

       "$YE"В данный момент обнаружены списки:$EN "$GR"$LS$EN

  "$WH"Ключ $EN"$GR"-a$N "$WH"- отображает все приложеня.
  Ключ $EN"$GR"-u$N "$WH"- отображает установленные приложения.
  Ключ $EN"$GR"-s$N "$WH"- отображает системные приложения.
  Ключ $EN"$GR"-d$N "$WH"- отображает удалённые приложения.
       "$BL"Пример:$EN
          "$RE"./run-me.sh $EN"$GR"-u$EN "$WH"- отображает список всех установленых пользователем приложений.

  Ключ $EN"$YE"-r$EN - "$WH"задает режим УДАЛЕНИЯ приложений.
  Ключ $EN"$YE"-rn$EN - "$WH"задает режим УДАЛЕНИЯ приложений БЕЗ БЕКАПА.
  Ключ $EN"$YE"-i$EN - "$WH"задает режим ВОССТАНОВЛЕНИЯ приложений.

    С параметрами $EN"$GR"1-n$EN - "$WH"задается список имён приложений.$EN
       "$BL"Пример:$EN
          "$RE"./run-me.sh $EN"$YE"-r $EN"$GR"2$EN "$WH"- запускает удаление приложений из списка$EN "$GR"LIST2$EN "$WH"

    "$WH"С параметром$EN "$GR"0$EN "$WH"имена приложений задаются вручную в кавычках через пробел.$EN
       "$BL"Пример:$EN
          "$RE"./run-me.sh $EN"$YE"-i $EN"$GR"0 'com.miui.app1 com.miui.app2'$EN "$WH"- запускает восстановление приложений
       $EN"$GR"com.miui.app1$EN "$WH"и$EN "$GR"com.miui.app2$EN

  "$WH"Для простой УСТАНОВКИ приложений, их$EN "$GR"apk$EN "$WH"файлы нужно разместить в директории$EN "$GR"BACKUP_APP_0$EN.
  "$WH"Запустить восстановление с параметром$EN "$GR"0$EN. "$WH"В качестве имён указать названия файлов приложений
  (без$EN "$GR".apk$EN "$WH"вконце). Все как в случае с восстановлением.$EN

  "$RE"Для УСТАНОВКИ и ВОССТАНОВЛЕНИЯ приложений в настройках смартфона$EN "$YE"\"Для разработчиков\"$EN
  "$RE"переключатель$EN "$YE"\"Установка через USB\"$EN "$RE"должен быть$EN "$YE"ВКЛЮЧЕН!$EN\n\n"; exit 0
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
printf ""$RE"Телефон не обнаружен!$EN\n"
conn
else
printf ""$BL"Обнаружено adb устройство: $EN"$GR"\"$DEV\"$EN\n"
primary_selecting
fi
