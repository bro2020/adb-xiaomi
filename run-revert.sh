#!/bin/bash
export LD_LIBRARY_PATH=./lib64:"$LD_LIBRARY_PATH"
export PATH=./:"$PATH"
APPS_LIST=`cat ./APPS_LIST`
DEV=$(adb devices | tail +2)

worker(){
for APPS in $APPS_LIST
do
adb shell pm install -k --user 0 $APPS
done
echo 'Процесс восстановления завершен'
exit 0
}

input(){
read -p "Введите название приложения: " APPS_LIST
worker
}

selected(){
read -p "Введите 1 для одиночного восстановления приложения, или enter для восстановления списка: " sel
case $sel in
  1) input ;;
  '') worker ;;
  *) echo "Неверный ввод!"; selected ;;
esac
}

if [[ $DEV = '' ]]; then
echo 'Телефон не обнаружен'
exit 1
else
echo "Обнаружен телефон $DEV"
selected
fi
