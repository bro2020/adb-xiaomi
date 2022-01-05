#!/bin/bash
export LD_LIBRARY_PATH=./lib64:"$LD_LIBRARY_PATH"
export PATH=./:"$PATH"
APPS_LIST=`cat ./APPS_LIST`
DEV=$(adb devices | tail +2 | cut -f1)

worker(){
for APPS in $APPS_LIST
do
adb shell pm install --user 0 $APPS
done
echo 'Процесс восстановления завершен'
exit 0
}

input(){
read -p "Введите название приложения: " APPS_LIST
worker
}

list_all(){
echo '****************************************'
adb shell pm list packages -u | grep $F
echo '****************************************'
selectind
}

list_installed(){
echo '****************************************'
adb shell pm list packages -3 | grep $F
echo '****************************************'
selectind
}

list_system(){
echo '****************************************'
adb shell pm list packages -s | grep $F
echo '****************************************'
selectind
}

ALL_REM() { adb shell pm list packages -u; }
ALL() { adb shell pm list packages; }

list_removed(){
COMM=$(comm -23 <(ALL_REM) <(ALL))
echo '****************************************'
echo "$COMM | grep $F"
echo '****************************************'
selectind
}

set_filter() {
read -p "Введите слово фильтра: " F
selectind
}

selectind(){
echo "##############################################################################
Введите 1 для одиночного восстановления приложения, или enter для восстановления по списку.
Введите a для оторажения всех приложений.
Введите i для отображения установленных приложений.
Введите s для отображения системных приложений.
Введите r для отображения удаленных приложений.
Введите f для установки фильтра по слову. Вышеописанные выводы будут отфильтрованы по этому слову
Для сброса фильтра нужно установить его пустым
Установлен фильтр по слову: $F
Зажмите на клавиатуре Ctrl + c для завершение работы скрипта на этом этапе.
__________________"
read -p "Сделайте выбор: " sel
case $sel in
  1) input ;;
  '') worker ;;
  a) list_all ;;
  i) list_installed ;;
  s) list_system ;;
  r) list_removed ;;
  f) set_filter ;;
  *) echo "Неверный ввод!"; selectind ;;
esac
}

if [[ $DEV = '' ]]; then
echo 'Телефон не обнаружен'
exit 1
else
echo "Обнаружен телефон: $DEV"
selectind
fi
