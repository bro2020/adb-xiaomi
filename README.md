# adb-xiaomi
Интерактивный bash скрипт работающий в операционных систем **Linux** и **MacOS**. Позволяет подключиться к смартфонам через **Wi-Fi adb** *интерфейс*, и удалять приложения, включая системные.
Разумеется деинсталяция происходит только для *пользователя* `0` операционной системы android, и не позволит освободить постоянную память устройства,
но этого достаточно, чтобы приложения не запускались, в частности в фоне, и не использовали ресурс ОЗУ и батареи.

По умолчанию цвета оформленя подобраны для терминала с темным фоном. Для светлого фона, вначале скрипта нужно изменить два значения переменных. В коде имеются подсказки.

Скрипт использует свободные утилиты [SDK Platform Tools](https://developer.android.com/studio/releases/platform-tools). Для его использования нужно предварительно соединить смартфон с adb клиентом, который уже находится в проекте.
Для этого в настройках телефона нужно активировать ***режим разработчика***. 

В смартфонах от компании *Xiaomi/Redmi/Poco* нужно зайти в приложение **"Настройки"**, далее пройти в пункт **"О телефоне"** и нажать около 10 раз быстрыми нажатиями на **"Версия MIUI..."** После чего появится всплывающее уведомление об успешной активации режима разработчика.

Перед удалением скрипт бекапит *apk* файлы в директорию `BACKUP_APP`. Это позволяет в дальнейшем восстановить приложния. Но для этого в настройках смартфона **"Для разработчиков"** ползунок **"Установка через USB"** должен быть установлен во **ВКЛЮЧЕННОЕ** положение. В телефонах *Xiaomi/Redmi/Poco* может потребоваться авторизоваться в `Mi Account`.

Находясь в интерфейсе скрипта так же можно вывести список всех приложений, только системных, только установленных, а так же список удалённых системных приложений.
Есть возможность отфильтровать выводы по требуемому слову, или символу.
В проекте заложены 3 списка удаляемых приложений(`LIST1,LIST2,LIST3`), которые нужно заполнять по своим соображениям.
Так же есть возможность вводить вручную названия приложений, которые нужно удалить или восстановить.

В проекте находится два скрипта: *главный* - `run-me.sh` и *скрипт подключения* - `connect.sh`. Перым можно выполнить все операции. Второй только для соединения с телефоном.
Для запуска, достаточно выполнить команду:
```
  ./run-me.sh
```
После чего скрипт проверит наличие подключенного устройства, и в случае успеха, попросит выбрать режим работы, затем отобразит главное меню.
Для взаимодействия нужно отвечать вводя требуемые латинские символы.
Если не будет обнаружено ни одно устройство, скрипт предложит запустить подключения к смартфону с помощью второго скрипта.
В нем так же нужно, отвечая на все вопросы и вводя информацию с телефона, дождаться подключения. После чего основной скрипт автоматически продолжит работу.

Есть возможность не использовать интерактивные возможности. Можно запускать скрипты передавая им параметры прямо из терминала, используя ключи запуска.
Для получения справки используется ключ -h или --help:
```
  ./run-me.sh -h
```
Но для того, чобы работвть в таком режиме, нужно предварительно соедениться с телефоном. Это можно сделать отдельно запустив исполняемый файл *connect.sh*.
Он попросит ввести IP-адрес, TCP-порты, и код с запущеных adb сервисов, с экрана смартфона, после чего, в случае успеха, завершит свою работу. Для подключения нужно выполнить команду:
```
  ./connect.sh
```
следовать инструкциям, и дождаться успешного подключения, в противном случае скрипт будет циклически повторять свою работу.
Этот скрипт так же можно выполнять передавая ему параметры прямо из терминала. Для получения справки нужно его запустить с ключем -h или --help:
```
  ./connect.sh --help
```
С помощью главного скрипта, можно выборочно устанавливать приложения. Их *apk* файлы нужно разместить в директории *BACKUP_APP*, и запустить восстановление с параметром *0*. В качестве имён приложений в кавычках через пробел указать названия файлов (без .apk вконце).
```
  ./run-me.sh -i 0 'com.miui.app1 com.miui.app2'
```
В случае успеха, *apk* файлы из директории *BACKUP_APP* будут удалены.

При выполнении подключения к устройству, удаление, установка или восстановление приложений, пишутся простые логи *worker.log* и *session.log*.

В будующем планировалось создание скрипта и для операционной системы Windows. Но из-за больших отличий в синтаксисе, и нехватки мотивации, разбираться нету желания.

