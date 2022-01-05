#!/bin/bash
export LD_LIBRARY_PATH=./lib64:"$LD_LIBRARY_PATH"
export PATH=./:"$PATH"
APPS_LIST=`cat ./APPS_LIST`
DEV=$(adb devices | tail +2 | cut -f1)
F='$'

worker(){
for APPS in $APPS_LIST
do
adb shell pm uninstall -k --user 0 $APPS
done
echo 'Процесс удаления завершен'
selectind
}

input(){
read -p "Введите название приложения: " APPS_LIST
worker
}

list_all(){
echo '****************************************'
adb shell pm list packages -u | grep $F | sort
echo '****************************************'
selectind
}

list_installed(){
echo '****************************************'
adb shell pm list packages -3 | grep $F | sort
echo '****************************************'
selectind
}

list_system(){
echo '****************************************'
adb shell pm list packages -s | grep $F | sort
echo '****************************************'
selectind
}

ALL_REM() { adb shell pm list packages -u | grep $F | sort; }
ALL() { adb shell pm list packages | grep $F | sort; }

list_removed() {
COMM=$(comm -23 <(ALL_REM) <(ALL))
echo '****************************************'
echo "$COMM"
echo '****************************************'
selectind
}

set_filter() {
read -p "Введите слово фильтра: " F
selectind
}

selectind() {
echo "##############################################################################
Введите 1 для одиночного удаления приложения, или enter для удаления по списку.
Введите a для оторажения всех приложений.
Введите i для отображения установленных приложений.
Введите s для отображения системных приложений.
Введите r для отображения удаленных приложений.
Введите f для установки фильтра по слову. Вышеописанные выводы будут отфильтрованы по этому слову
Для сброса фильтра нужно установить ему значение $
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
