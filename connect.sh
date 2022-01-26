#!/bin/bash
export LD_LIBRARY_PATH="$(dirname $0)/lib64":"$LD_LIBRARY_PATH"
export PATH="$(dirname $0)/":"$PATH"
env BASHOPTS=xpg_echo POSIXLY_CORRECT=1
DEV=$(adb devices -l | tail +2 | cut -d: -f4 | cut -d' ' -f1)
IP=`cat "$(dirname $0)/SESSION"`
date=`date`

FON="1" # "1" - если фон терминала тёмный, "2;1" - если фон тереминала светлый
RE="\e[$FON;91m"
GR="\e[$FON;92m"
YE="\e[$FON;93m"
BL="\e[$FON;94m"
WH="\e[$FON;97m" # 97 - если фон терминала тёмный, 90 - если фон тереминала светлый
EN="\e[0m"

check_dev() {
if [[ $DEV != '' ]]; then
echo -e "$GRПодключение к "$YE"\"$DEV\"$EN "$GR"уже установлено!$EN"
exit 0
else
$STATUS
echo -e "$YEАктивные подключения не найдены!$EN"
exit 0
fi
}

check_ip() {
IP=$IP
if [[ $IP != '' ]]; then
echo -e "$YE###################################################################################$EN
"$BL"Обнаружен ранее подключенный IP-адрес:$EN "$GR"\"$IP\"$EN
  "$WH"Введите$EN "$GR"y$EN "$WH"для подключениче к этому устройству (Потребуется ввести только$EN "$YE"Порт$EN).
  Введите$EN "$GR"n$EN "$WH"для нового полного подключения с авторизацией.$EN
  "$WH"Введите$EN "$GR"d$EN "$WH"для удаления текущего IP из списка, если он не актуален.
"$YE"_________________________________________________________$EN"
read -p "Сделайте выбор здесь: " session
case "$session" in
  y) input_port ;;
  n) STATUS='input_code'; input_ipport1;;
  d) echo '' > "$(dirname $0)/SESSION" && echo -e "$GRГОТОВО$EN!" && IP=`cat "$(dirname $0)/SESSION"`; check_ip;;
  *) echo -e "$REНеверный ввод, попробуйте ещё раз.$EN" check_ip ;;
esac
fi
STATUS='input_code'; input_ipport1
}

input_port() {
echo -e "$WH В найстройках телефона зайдите в раздел $EN"$YE"\"Расширенные настройки\"$EN
"$WH" Найдите раздел $EN"$YE"\"Для разработчиков\"$EN "$WH"перейдите в него.
 Найдите пункт $EN"$YE"\"Беспроводная отладка\"$EN "$WH"установите флажок во ВКЛЮЧЕННОЕ положение.
 Нажмите на стрелку $EN"$YE"\">\"$EN "$WH"в этом же пункте. Вы провалитесь в подменю.
 В этом подменю отображается $EN"$YE"\"IP-адрес & Порт\"$EN "$WH"adb сервиса.$EN
"$BL"    Пример:$EN "$GR"$IP:32105$EN
"$WH" Сейчас нужно ввести только$EN "$YE"Порт$EN "$WH"- число которое расположено после двоеточия.$EN
"$BL"    Пример:$EN "$GR"32105$EN
"$YE"_________________________________________________________$EN"
read -p "Введите значение из этого поля здесь: " PORT1
IPPORT1="$IP":"$PORT1"
STATUS2='input_port'
worker_connect
}

input_ipport1() {
if [[ $DEV = '' ]]; then
echo -e "$YE###################################################################################$EN
"$GR"Подключение телефона через Wi-Fi adb...$EN"
else
echo -e "$GRПодключение к "$YE"\"$DEV\"$EN "$GR"уже установлено!$EN"
exit 0
fi
echo -e "$WH В найстройках телефона зайдите в раздел $EN"$YE"\"Расширенные настройки\"$EN
"$WH" Найдите раздел $EN"$YE"\"Для разработчиков\"$EN "$WH"перейдите в него.
 Найдите пункт $EN"$YE"\"Беспроводная отладка\"$EN "$WH"установите флажок во ВКЛЮЧЕННОЕ положение.
 Нажмите на стрелку $EN"$YE"\">\"$EN "$WH"в этом же пункте. Вы провалитесь в подменю.
 В этом подменю отображается $EN"$YE"\"IP-адрес & Порт\"$EN "$WH"adb сервиса.$EN
"$BL"    Пример:$EN "$GR"192.168.1.2:32105$EN
"$YE"_________________________________________________________$EN"
read -p "Введите значение из этого поля здесь: " IPPORT1
STATUS2='input_ipport1'
$STATUS
}

input_code() {
echo -e "$YE###################################################################################$EN
"$WH" Теперь нажмите на пункт $EN"$YE"\"Подключение устройств через код подключения\"$EN.
"$WH" Вы увидите $EN"$YE"\"Код подключения Wi-Fi\"$EN "$WH"большими шрифтом.
"$BL"    Пример:$EN "$YE"Код подключения Wi-Fi:$EN "$GR"850651$EN
"$YE"__________________________________________________________$EN"
read -p "Введите значение из этого поля здесь: " CODE
echo -e "$YE###################################################################################$EN
$WH "$WH"Ниже отображается$EN "$YE"\"IP-адрес & Порт\"$EN "$WH"сервиса авторизации.$EN
"$BL"    Пример:$EN "$YE"IP-адрес & Порт:$EN "$GR"192.168.1.2:40105$EN
"$WH" Сейчас нужно ввести только$EN "$YE"Порт$EN "$WH"- число которое расположено после двоеточия.$EN
"$BL"    Пример:$EN "$GR"40105$EN
"$YE"__________________________________________________________$EN"
read -p "Введите значение из этого поля здесь: " PORT2
worker_pair
}

worker_pair() {
echo -e "$YE###################################################################################$EN
"$GR"Выполняется авторизация...$EN"
IP=$(echo $IPPORT1 | cut -d: -f1)
PAIR=$(adb pair "$IP":"$PORT2" $CODE | cut -d' ' -f1)
if [[ $PAIR != 'Successfully' ]]; then
echo -e "$date \nadb pair to \"$IP\": $PAIR\n" >> "$(dirname $0)"/session.log
echo -e "$REАвторизация не удалась! Введите значения заново.$EN"; sleep 1; input_code
else
echo -e "$date \nadb pair to \"$IP\": $PAIR\n" >> "$(dirname $0)"/session.log
echo -e "$GRАвторизация выполнена успешна!$EN"
sleep 1
worker_connect
fi
}

worker_connect() {
echo -e "$YE###################################################################################$EN
"$GR"Выполняется подключение...$EN"
CONN=$(adb connect "$IPPORT1" | cut -d' ' -f1)
sleep 1
DEV=$(adb devices -l | tail +2 | cut -d: -f4 | cut -d' ' -f1)
if [[ $DEV = '' ]]; then
echo -e "$date \nadb connect to \"$IPPORT1\": Failure \ndevice: \"$DEV\" $CONN\n" >> "$(dirname $0)"/session.log
echo -e "$REПодключение не удалось!$EN
"$WH"Через 5 секунд запуститься повторная попытка ввода данных.
Зажмите$EN "$GR"Ctrl + c$EN "$WH"для отмены и завершения работы скрипта подключения.$EN
"$YE"###################################################################################$EN"
sleep 8
STATUS='worker_connect'
$STATUS2
else
echo -e "$date \nadb connect to \"$IPPORT1\": Successfully \ndevice: \"$DEV\" $CONN\n" >> "$(dirname $0)"/session.log
echo -e "$GRПодключение устройства "$YE"\"$DEV\"$EN "$GR"успешно завершено!$EN
"$YE"###################################################################################$EN"
echo "$IP" > "$(dirname $0)/SESSION"
exit 0
fi
}

start_pair_cli() {
IP=$(echo $IPPORT1 | cut -d: -f1)
echo -e "$YE###################################################################################$EN
"$GR"Выполняется авторизация...$EN"
PAIR=$(adb pair "$IP":"$PORT2" $CODE | cut -d' ' -f1)
if [[ $PAIR != 'Successfully' ]]; then
echo -e "$date \nadb pair to \"$IP\": $PAIR\n" >> "$(dirname $0)"/session.log
echo -e "$REАвторизация не удалась!$EN"; exit 1
else
echo -e "$date \nadb pair to \"$IP\": $PAIR\n" >> "$(dirname $0)"/session.log
echo -e "$GRАвторизация выполнена успешно!$EN"
start_connect_cli
fi
}

start_connect_cli() {
echo -e "$YE###################################################################################$EN
"$GR"Выполняется подключение...$EN"
CONN=$(adb connect "$IPPORT1" | cut -d' ' -f1)
sleep 1
DEV=$(adb devices -l | tail +2 | cut -d: -f4 | cut -d' ' -f1)
if [[ $DEV = '' ]]; then
echo -e "$date \nadb connect to \"$IPPORT1\": Failure \ndevice: \"$DEV\" $CONN\n" >> "$(dirname $0)"/session.log
echo -e "$REПодключение не удалось!$EN"; exit 1
else
echo -e "$date \nadb connect to \"$IPPORT1\": Successfully \ndevice: \"$DEV\" $CONN\n" >> "$(dirname $0)"/session.log
echo -e ""$GR"Подключение устройства "$YE"\"$DEV\"$EN "$GR"успешно завершено$EN
"$YE"###################################################################################$EN"
echo "$IP" > "$(dirname $0)/SESSION"
exit 0
fi
}

session_list() {
if [[ $IP = '' ]]; then
echo -e "
$WHРанее подключения не проводились.$EN
"
exit 0
else
echo -e "
$WHРанее проводилось подключение к устройству с IP-адресом:$EN "$GR"\"$IP\"$EN

  Для быстрого подключения к этому устройству введите:

     "$RE"./connect.sh$EN "$YE"-c$EN "$GR"$IP:ПОРТ$EN

  Где "$GR"ПОРТ$EN нужно посмотреть в настройках "$WH"\"Беспроводная отладка\"$EN в пункте "$WH"\"IP-адрес & Порт\"$EN
"
exit 0
fi
}

helpa() {
echo -e "
    $RE./connect.sh$EN "$YE"-c$EN или "$YE"--cli$EN "$GR"IP:PORT1$EN "$GR"CODE$EN "$GR"PORT2$EN

  "$GR"IP:PORT1$EN "$WH"- \"IP-адрес & Порт\"$EN из окна "$WH"\"Беспроводная отладка\"$EN.
  "$GR"CODE$EN "$WH"- \"Код подключения Wifi\"$EN из окна "$WH"\"Подключить устройство через код подключения\"$EN.
  "$GR"PORT2$EN - из "$WH"\"IP-адрес & Порт\"$EN из окна "$WH"\"Подключить устройство через код подключения\"$EN
          только "$WH"\"Порт\"$EN который после двоеточия.

    $RE./connect.sh$EN "$YE"-l$EN или "$YE"--list$EN - выводит информацию о наличии активного подключения.
    $RE./connect.sh$EN "$YE"-s$EN или "$YE"--session$EN - выводит информацию о наличии ранее подключенного IP.
    $RE./connect.sh$EN "$YE"-d$EN или "$YE"--disconnect$EN - отключает все подключенные устройства.

  Если обнаружен ранее подключенный IP-адрес, то авторизацию можно не проводить.
  Достаточно ввести только "$GR"IP:PORT1$EN:

    $RE./connect.sh$EN "$YE"-c$EN или "$YE"--cli$EN "$GR"IP:PORT1$EN
"
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
  *) echo -e "$REДопущена ошибка в написании ключей$EN"; exit 1 ;;
esac

