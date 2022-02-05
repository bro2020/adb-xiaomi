#!/bin/bash
if [[ $(uname -s) != 'Linux' ]]; then
export LD_LIBRARY_PATH="$(dirname $0)/adb-macos/lib64":"$LD_LIBRARY_PATH"
export PATH="$(dirname $0)/adb-macos/":"$PATH"
else
export LD_LIBRARY_PATH="$(dirname $0)/adb-linux/lib64":"$LD_LIBRARY_PATH"
export PATH="$(dirname $0)/adb-linux/":"$PATH"
fi
DEV=$(adb devices -l | tail +2 | cut -d: -f4 | cut -d' ' -f1)
IP=`cat "$(dirname $0)/SESSION.txt"`
date=`date`
VERSION='1.1'

FON="2;1"
RE="\e[1;91m"
GR="\e[$FON;92m"
YE="\e[$FON;93m"
BL="\e[$FON;94m"
WH="\e[$FON;97m" # 97 - если фон терминала тёмный, 90 - если фон тереминала светлый
EN="\e[0m"

check_dev() {
if [[ $DEV != '' ]]; then
printf "\n"$GR"Подключение к "$YE"\"$DEV\"$EN "$GR"уже установлено!$EN\n\n"
exit 0
else
$STATUS
printf "\n"$WH"Активные подключения не найдены!$EN\n\n"
exit 0
fi
}

check_ip() {
IP=$IP
if [[ $IP != '' ]]; then
printf ""$YE"###################################################################################$EN
"$BL"Обнаружен ранее подключенный IP-адрес:$EN "$GR"\"$IP\"$EN\n
  "$WH"Введите$EN "$GR"y$EN "$WH"для подключениче к этому устройству (Потребуется ввести только$EN "$YE"Порт$EN"$WH").
  Введите$EN "$GR"n$EN "$WH"для нового полного подключения с авторизацией.
  Введите$EN "$GR"d$EN "$WH"для удаления текущего IP из списка, если он не актуален.\n
Или введите$EN "$GR"q$EN "$WH"для завершение работы скрипта.$EN
"$YE"_________________________________________________________$EN\n"
read -p "Сделайте выбор здесь: " session
case "$session" in
  y) input_port ;;
  q) exit 0 ;;
  n) STATUS='input_code'; input_ipport1;;
  d) echo '' > "$(dirname $0)/SESSION.txt" && printf "$GRГОТОВО$EN!" && IP=`cat "$(dirname $0)/SESSION.txt"`; check_ip;;
  *) printf ""$RE"Неверный ввод, попробуйте ещё раз.$EN\n"; check_ip ;;
esac
fi
STATUS='input_code'; input_ipport1
}

input_port() {
printf ""$WH" В настройках телефона зайдите в раздел $EN"$YE"\"Расширенные настройки\"$EN
"$WH" Найдите раздел $EN"$YE"\"Для разработчиков\"$EN "$WH"перейдите в него.
 Найдите пункт $EN"$YE"\"Беспроводная отладка\"$EN "$WH"установите флажок во ВКЛЮЧЕННОЕ положение.
 Нажмите на стрелку $EN"$YE"\">\"$EN "$WH"в этом же пункте. Вы провалитесь в подменю.
 В этом подменю отображается $EN"$YE"\"IP-адрес & Порт\"$EN "$WH"adb сервиса.$EN \n
"$BL"    Пример:$EN "$GR"$IP:32105$EN \n
"$WH" Сейчас нужно ввести только$EN "$YE"Порт$EN "$WH"- число которое расположено после двоеточия.$EN \n
"$BL"    Пример:$EN "$GR"32105$EN \n
"$WH"Или введите$EN "$GR"q$EN "$WH"для завершение работы скрипта.$EN
"$YE"_________________________________________________________$EN\n"
read -p "Введите значение из этого поля здесь: " PORT1
if [[ $PORT1 = "q" ]]; then
exit 0
fi
IPPORT1="$IP":"$PORT1"
STATUS2='input_port'
worker_connect
}

input_ipport1() {
if [[ $DEV = '' ]]; then
printf ""$YE"###################################################################################$EN
"$GR"Подключение телефона через Wi-Fi adb...$EN
"$YE"###################################################################################$EN\n"
else
printf "\n"$GR"Подключение к "$YE"\"$DEV\"$EN "$GR"уже установлено!$EN\n\n"
exit 0
fi
printf ""$WH" В найстройках телефона зайдите в раздел $EN"$YE"\"Расширенные настройки\"$EN
"$WH" Найдите раздел $EN"$YE"\"Для разработчиков\"$EN "$WH"перейдите в него.
 Найдите пункт $EN"$YE"\"Беспроводная отладка\"$EN "$WH"установите флажок во ВКЛЮЧЕННОЕ положение.
 Нажмите на стрелку $EN"$YE"\">\"$EN "$WH"в этом же пункте. Вы провалитесь в подменю.
 В этом подменю отображается $EN"$YE"\"IP-адрес & Порт\"$EN "$WH"adb сервиса.$EN \n
"$BL"    Пример:$EN "$GR"192.168.1.2:32105$EN \n
"$WH"Или введите$EN "$GR"q$EN "$WH"для завершение работы скрипта.$EN
"$YE"_________________________________________________________$EN\n"
read -p "Введите значение из этого поля здесь: " IPPORT1
if [[ $IPPORT1 = "q" ]]; then
exit 0
fi
STATUS2='input_ipport1'
$STATUS
}

input_code() {
printf ""$YE"###################################################################################$EN
"$WH" Теперь нажмите на пункт $EN"$YE"\"Подключение устройств через код подключения\"$EN"$WH".
 Вы увидите $EN"$YE"\"Код подключения Wi-Fi\"$EN "$WH"большим шрифтом. \n
"$BL"    Пример:$EN "$YE"Код подключения Wi-Fi:$EN "$GR"850651$EN \n
"$WH"Или введите$EN "$GR"q$EN "$WH"для завершение работы скрипта.$EN
"$YE"__________________________________________________________$EN\n"
read -p "Введите значение из этого поля здесь: " CODE
if [[ $CODE = "q" ]]; then
exit 0
fi
printf ""$YE"###################################################################################$EN
$WH "$WH"Ниже отображается$EN "$YE"\"IP-адрес & Порт\"$EN "$WH"сервиса авторизации.$EN \n
"$BL"    Пример:$EN "$YE"IP-адрес & Порт:$EN "$GR"192.168.1.2:40105$EN \n
"$WH" Сейчас нужно ввести только$EN "$YE"Порт$EN "$WH"- число которое расположено после двоеточия.$EN \n
"$BL"    Пример:$EN "$GR"40105$EN \n
"$WH"Или введите$EN "$GR"q$EN "$WH"для завершение работы скрипта.$EN
"$YE"__________________________________________________________$EN\n"
read -p "Введите значение из этого поля здесь: " PORT2
if [[ $PORT2 = "q" ]]; then
exit 0
fi
worker_pair
}

worker_pair() {
printf ""$YE"###################################################################################$EN
"$GR"Выполняется авторизация...$EN\n"
IP=$(echo $IPPORT1 | cut -d: -f1)
PAIR=$(adb pair "$IP":"$PORT2" $CODE | cut -d' ' -f1)
if [[ $PAIR != 'Successfully' ]]; then
printf "$date \nadb pair to \"$IP\": $PAIR\n\n" >> "$(dirname $0)"/session.log
printf ""$RE"Авторизация не удалась! Введите значения заново.$EN\n"; sleep 1; input_code
else
printf "$date \nadb pair to \"$IP\": $PAIR\n\n" >> "$(dirname $0)"/session.log
printf ""$GR"Авторизация выполнена успешно!$EN\n"
sleep 1
worker_connect
fi
}

worker_connect() {
printf ""$YE"###################################################################################$EN
"$GR"Выполняется подключение...$EN\n"
CONN=$(adb connect "$IPPORT1" | cut -d' ' -f1)
sleep 1
DEV=$(adb devices -l | tail +2 | cut -d: -f4 | cut -d' ' -f1)
if [[ $DEV = '' ]]; then
printf "$date \nadb connect to \"$IPPORT1\": Failure \ndevice: \"$DEV\" $CONN\n\n" >> "$(dirname $0)"/session.log
printf ""$RE"Подключение не удалось!$EN
"$WH"Через 5 секунд запуститься повторная попытка ввода данных.
Зажмите$EN "$GR"Ctrl + c$EN "$WH"для отмены и завершения работы скрипта подключения.$EN
"$YE"###################################################################################$EN\n"
sleep 8
STATUS='worker_connect'
$STATUS2
else
printf "$date \nadb connect to \"$IPPORT1\": Successfully \ndevice: \"$DEV\" $CONN\n\n" >> "$(dirname $0)"/session.log
printf ""$GR"Подключение устройства "$YE"\"$DEV\"$EN "$GR"успешно завершено!$EN
"$YE"###################################################################################$EN\n"
echo "$IP" > "$(dirname $0)/SESSION.txt"
$RUN_STATUS
exit 0
fi
}

start_pair_cli() {
IP=$(echo $IPPORT1 | cut -d: -f1)
printf ""$YE"###################################################################################$EN
"$GR"Выполняется авторизация...$EN\n"
PAIR=$(adb pair "$IP":"$PORT2" $CODE | cut -d' ' -f1)
if [[ $PAIR != 'Successfully' ]]; then
printf "$date \nadb pair to \"$IP\": $PAIR\n\n" >> "$(dirname $0)"/session.log
printf ""$RE"Авторизация не удалась!$EN\n"; exit 1
else
printf "$date \nadb pair to \"$IP\": $PAIR\n\n" >> "$(dirname $0)"/session.log
printf ""$GR"Авторизация выполнена успешно!$EN\n"
start_connect_cli
fi
}

start_connect_cli() {
printf ""$YE"###################################################################################$EN
"$GR"Выполняется подключение...$EN\n"
CONN=$(adb connect "$IPPORT1" | cut -d' ' -f1)
sleep 1
DEV=$(adb devices -l | tail +2 | cut -d: -f4 | cut -d' ' -f1)
if [[ $DEV = '' ]]; then
printf "$date \nadb connect to \"$IPPORT1\": Failure \ndevice: \"$DEV\" $CONN\n" >> "$(dirname $0)"/session.log
printf ""$RE"Подключение не удалось!$EN\n"; exit 1
else
printf "$date \nadb connect to \"$IPPORT1\": Successfully \ndevice: \"$DEV\" $CONN\n" >> "$(dirname $0)"/session.log
printf ""$GR"Подключение устройства "$YE"\"$DEV\"$EN "$GR"успешно завершено$EN
"$YE"###################################################################################$EN\n"
echo "$IP" > "$(dirname $0)/SESSION.txt"
exit 0
fi
}

session_list() {
if [[ $IP = '' ]]; then
printf "\n"$WH"Ранее подключения не проводились.$EN\n\n"
exit 0
else
printf "\n"$WH"Ранее проводилось подключение к устройству с IP-адресом:$EN "$GR"\"$IP\"$EN

  Для быстрого подключения к этому устройству введите:

     "$RE"./connect.sh$EN "$YE"-c$EN "$GR"$IP:ПОРТ$EN

  Где "$GR"ПОРТ$EN нужно посмотреть в настройках "$WH"\"Беспроводная отладка\"$EN в пункте "$WH"\"IP-адрес & Порт\"$EN\n"
exit 0
fi
}

helpa() {
if [[ $IP = '' ]]; then
SES=""$YE"В данный моммент подключенных ранее IP-адресов не обнаружено.$EN"
IPSES='IP'
else
SES=""$YE"Обнаружен ранее подключенный IP-адрес:$EN "$GR""$IP"$EN"
IPSES="$IP"
fi
printf ""$WH"Версия скрипта $VERSION \n
    "$RE"./connect.sh$EN "$YE"-c$EN или "$YE"--cli$EN "$GR"IP:PORT1$EN "$GR"CODE$EN "$GR"PORT2$EN

  "$GR"IP:PORT1$EN "$WH"- \"IP-адрес & Порт\"$EN из окна "$WH"\"Беспроводная отладка\"$EN.
  "$GR"CODE$EN "$WH"- \"Код подключения Wifi\"$EN из окна "$WH"\"Подключить устройство через код подключения\"$EN.
  "$GR"PORT2$EN - из "$WH"\"IP-адрес & Порт\"$EN из окна "$WH"\"Подключить устройство через код подключения\"$EN
          только "$WH"\"Порт\"$EN который после двоеточия.

    "$RE"./connect.sh$EN "$YE"-l$EN или "$YE"--list$EN - выводит информацию о наличии активного подключения.
    "$RE"./connect.sh$EN "$YE"-s$EN или "$YE"--session$EN - выводит информацию о наличии ранее подключенного IP.
    "$RE"./connect.sh$EN "$YE"-d$EN или "$YE"--disconnect$EN - отключает все подключенные устройства.

  Если обнаружен ранее подключенный IP-адрес, то авторизацию можно не проводить.
  Достаточно ввести только "$GR"IP:PORT1$EN:

    "$RE"./connect.sh$EN "$YE"-c$EN или "$YE"--cli$EN "$GR""$IPSES":PORT1$EN\n
  $SES\n\n"
exit 0
}

check_pair() {
if [[ $CODE != '' ]]; then
STATUS='start_pair_cli'; check_dev
else
STATUS='start_connect_cli'; check_dev
fi
}

IPPORT1=$2
CODE=$3
PORT2=$4
case "$1" in
  '') STATUS='check_ip'; check_dev ;;
  -c|--cli) check_pair ;;
  -l|--list) STATUS=''; check_dev ;;
  -s|--session) session_list ;;
  -d|--disconnect) adb disconnect ;;
  -h|--help) helpa ;;
  *) printf ""$RE"Допущена ошибка в написании ключей$EN\n"; exit 1 ;;
esac

