#!/bin/bash
export LD_LIBRARY_PATH=./lib64:"$LD_LIBRARY_PATH"
export PATH=./:"$PATH"
APPS_LIST1=`cat ./LIST1`
APPS_LIST2=`cat ./LIST2`
APPS_LIST3=`cat ./LIST3`
DEV=$(adb devices | tail +2 | cut -f1) #для работы дожно быть +2, для отладки +1
CONNECT="./connect.sh"
F='$'

worker(){
for APPS in $APPS_LIST
do
adb shell pm $COMMAND --user 0 $APPS
done
echo "Процесс $R завершен"
main_selectind
}

input(){
read -p 'Введите название приложения: ' APPS_LIST
worker
}

list_all(){
echo '****************************************'
adb shell pm list packages -u | grep $F | sort
echo '****************************************'
main_selectind
}

list_installed(){
echo '****************************************'
adb shell pm list packages -3 | grep $F | sort
echo '****************************************'
main_selectind
}

list_system(){
echo '****************************************'
adb shell pm list packages -s | grep $F | sort
echo '****************************************'
main_selectind
}

ALL_REM() { adb shell pm list packages -u | grep $F | sort; }
ALL() { adb shell pm list packages | grep $F | sort; }

list_removed() {
COMM=$(comm -23 <(ALL_REM) <(ALL))
echo '****************************************'
echo "$COMM"
echo '****************************************'
main_selectind
}

set_filter() {
read -p "Введите слово фильтра: " F
main_selectind
}

main_selectind() {
echo "##############################################################################
Выбран режим $R
Введите 0 для выборочного $R (Можно ввести несколько приложений через пробел).
Нажмите 1 для $R по списку LIST1.
Нажмите 2 для $R по списку LIST2.
Нажмите 3 для $R по списку LIST3.
Дополнительные опции:
Введите a для отображения всех приложений.
Введите i для отображения установленных приложений.
Введите s для отображения системных приложений.
Введите r для отображения удалённых приложений.
Введите f для установки фильтра по слову. Вышеописанные отображения будут отфильтрованы по этому слову
Для сброса фильтра нужно установить ему значение $
Установлен фильтр по слову: $F

Введите b для выбора режима работы скрипта.
Зажмите на клавиатуре Ctrl + c для завершение работы скрипта на этом этапе.
__________________"
read -p "Сделайте выбор: " m_sel
case $m_sel in
  0) input ;;
  1) APPS_LIST=$APPS_LIST1; worker ;;
  2) APPS_LIST=$APPS_LIST2; worker ;;
  3) APPS_LIST=$APPS_LIST3; worker ;;
  a) list_all ;;
  i) list_installed ;;
  s) list_system ;;
  r) list_removed ;;
  f) set_filter ;;
  b) primary_selecting ;;
  *) echo 'Неверный ввод!'; main_selectind ;;
esac
}

primary_selecting() {
echo '###################
Версия скрипта 1.0
Введите r для удаления приложений
Введите i для восстанолвения приложений
Зажмите на клавиатуре Ctrl + c для завершение работы скрипта на этом этапе.
__________________'
read -p "Сделайте выбор: " p_sel
case $p_sel in
  r) COMMAND='uninstall -k'; R='удаления'; main_selectind ;;
  i) COMMAND='install'; R='восстановления'; main_selectind ;;
  *) echo 'Неверный ввод!'; primary_selecting ;;
esac
}

conn() {
echo 'Введите y для запуска скрипта подключения телефона
Введите n для завершения этого скрипта
__________________'
read -p "Сделайте выбор: " con
case $con in
  y) bash $CONNECT; primary_selecting ;;
  n) exit 1 ;;
  *) echo 'Неверный ввод!'; conn ;;
esac
}

if [[ $DEV = '' ]]; then
echo 'Телефон не обнаружен'
conn
else
echo "Обнаружен телефон: $DEV"
primary_selecting
fi
