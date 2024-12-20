# pymongo-api

## Как запустить

Идем в папку sharding-repl-cache.

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

Все инициализации, настройка шардов и заполнение БД находятся внутри этого одного скрипты. Скрипт выполяется 20-30с, так как внутри есть sleep 10, чтобы реплики успели выбрать Primary.

## Как проверить

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

### Проверка работы кеша

Откройте новую вкладку браузера.

Откройте инструменты разработчика, вкладка Network. Я проверял на Chrome.

Скопируйте в адресную строку браузера эндпоинт http://localhost:8080/helloDoc/users.

В колонке Time вкладки Network будет указано время примерно 1-2 сек.

![](/sharding-repl-cache/assets/20241201_014237__.png)

Выполните рефреш страницы с адресом http://localhost:8080/helloDoc/users.

В колонке Time вкладки Network будет указано время <100 мс.

При последующих рефрешах также будет <100 мс.

![](/sharding-repl-cache/assets/20241201_013701__.png)

Для сравнения при проделывании этого теста в проекте mongo-sharding-repl время загрузки всегда остается примерно 1-2 сек.

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs

## Схема

См. файл 5-CDN.drawio.

Несмотря на то, что в задании сказано добавить один инстанс Redis, в финальном варианте я добавил несколько - по одному на каждый инстанс pymongo-api. Обоснование заключается в том, что при использовании кеша на несколько инстансов приложения нивелируется эффект от кеша. Он будет быстро переполняться за счет кратного увеличения запросов.

Каждый из Redis через Consul маппиться на свой инстанс pymongo-api. Pymongo-api после поднятия в режиме поллинга Consul ищет свободный Redis. Как только нашел, резервирует его себе. В Consul делается запись, что инстанс Redis занят таким-то pymongo-api. При выгрузке инстанса pymongo-api Consul освобождает Redis.

Я не уверен, что Redis поддерживает интагация с Consul, поэтому вариант теоритический. Я уверен, в любом случае можно реализовать маппинг конкретных интаснов pymongo-api и Redis относительно недорого.
