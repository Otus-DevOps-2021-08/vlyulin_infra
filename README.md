<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4" />

# vlyulin Infra repository

# Content:
* [Student](#Student)
* [Module hw03-bastion](#Module-hw03-bastion)
* [Module hw04-cloud-testapp](#Module-hw04-cloud-testapp)

# Student
`
Student: Vadim Lyulin
Course: DevOps
Group: Otus-DevOps-2021-08
`

## Module hw03-bastion<a name="Module-hw03-bastion"></a>
### Самостоятельное задание
Исследовать способ подключения к someinternalhost в однукоманду из вашего рабочего устройства, проверить работоспособностьнайденного решения и внести его в README.md в вашем репозитории.

#### Решение
Использовать ключ -J (ssh jump host) для перепрыгивания через hosts.
Команда:
```
ssh -i ~/.ssh/vlyulin_key -J appuser@130.193.38.153 appuser@10.128.0.30
```

### Дополнительное задание:
Предложить вариант решения для подключения из консоли при помощикоманды вида ssh someinternalhost из локальной консоли рабочегоустройства, чтобы подключение выполнялось по алиасуsomeinternalhost и внести его в README.md в вашем репозитории.

#### Решение
Настроить Static jumphost list.
Для этого сощдается файл ~/.ssh/config, где указываются переходы
```
### Первый переход к host, который доступен напрямую.
Host bastion
  User appuser
  HostName 130.193.38.153

### Host для последующего перехода
Host someinternalhost
  User appuser
  HostName 10.128.0.30
  ProxyJump bastion
```

Выполнить команду:
```
ssh -i ~/.ssh/vlyulin_key someinternalhost
```
### Дополнительное задание
С помощью сервисов / и реализуйте
использование валидного сертификата для панели управления VPN-сервера

#### Решение

![](images/LetsEncript.png)

https://130.193.37.127.sslip.io

## Описание конфигурации
bastion_IP = 130.193.37.12
someinternalhost_IP = 10.128.0.30

## Module hw04-cloud-testapp<a name="Module-hw04-cloud-testapp"></a>
Деплой тестового приложения reddit

1) Установлен YC CLI
2) Создана ВМ
2) Созданы скрипты для установки:
        - Ruby и Bundler (install_ruby.sh),
        - MongoDB (install_mongo.sh),
        - Reddit (deploy.sh)
3) Скриптам install_ruby.sh, install_mongo.sh, deploy.sh установлен флаг исполнения +x
4) Проверена работа приложения http://62.84.116.223:9292
5) Предпринята попытка выполнения дополнительного задания

testapp_IP=62.84.116.223
testapp_port=9292

Создание ключей:
```
ssh-keygen -t rsa -b 2048 -f ~/.ssh/appuser -C appuser -P ""
```

Команда создания ВМ (файл yc-create-instance.sh):
```
#!/bin/bash
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --ssh-key ~/.ssh/appuser.pub
```

Соединение с rabbit-app:
ssh -i ~/.ssh/appuser yc-user@62.84.116.223

Дополнительное задание:
`
В качестве доп. задания используйте созданные ранее скрипты длясоздания,
который будет запускаться при создании инстанса.В результате применения данной команды CLI
мы должны получать инстанс с уже запущенным приложением. Startup скрипт
необходимо закомитить, а используемую команду CLI добавить в описание репозитория(README.md)
`

Конфигурационный файл (cloud-config.yml):
```
#cloud-config

users:
  - name: appuser
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL:ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjk1hL2RJ/cLvzmBZ4dsRGKmceEh+x5VxMPY09/wG/yiv7j2gm+flQQ4bRZfQwmEPsVW8OflQPBfyVsttXoilG0Q5xO2hT1Kgjr/RMGW6LghXOZFSTFLEZ+OAXgf89W3RyYIMgsJti7qNTHJSqsq1CrxNm8fCVdU1h//+YOoYQUgEZ25uOHPm/agByptI4Icqv/0u5pYpu2IJHo4ko/D3uVwsc9WRPyFt73uPW/EGgOCjVWTvNxuGxb6S7f1KMHuKrf4vrjeuO7YfklCldnjhnULLj0SV1LhdmRzkNNAU8WZdw/HCyRKpUmY5aM6UlkayI0x+plFMQE4ODj7yQaJ0r appuser

bootcmd:
  # install ruby
  - sudo apt update
  - sudo apt install -y ruby-full ruby-bundler build-essential
  # install mongo
  - wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
  - echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
  - sudo apt-get update
  - sudo apt-get install -y mongodb-org
  - sudo systemctl start mongod
  - sudo systemctl enable mongod
  # install reddit
  - cd ~
  - apt install git
  - git clone -b monolith https://github.com/express42/reddit.git
  - cd reddit && bundle install
  - puma -d
```

Другой вариант конфигаруционного файла cloud-config_sudoers.d.yml:
```
#cloud-config

bootcmd:
  - echo "======Put public key to authorized_keys======"
  - PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjk1hL2RJ/cLvzmBZ4dsRGKmceEh+x5VxMPY09/wG/yiv7j2gm+flQQ4bRZfQwmEPsVW8OflQPBfyVsttXoilG0Q5xO2hT1Kgjr/RMGW6LghXOZFSTFLEZ+OAXgf89W3RyYIMgsJti7qNTHJSqsq1CrxNm8fCVdU1h//+YOoYQUgEZ25uOHPm/agByptI4Icqv/0u5pYpu2IJHo4ko/D3uVwsc9WRPyFt73uPW/EGgOCjVWTvNxuGxb6S7f1KMHuKrf4vrjeuO7YfklCldnjhnULLj0SV1LhdmRzkNNAU8WZdw/HCyRKpUmY5aM6UlkayI0x+plFMQE4ODj7yQaJ0r appuser"
  - sudo echo $PUBKEY > ~/.ssh/authorized_keys
  - echo "======Create user======"
  - USERNAME="appuser"
  - adduser --disabled-password --gecos "" $USERNAME
  - echo "$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USERNAM
  - echo "install ruby"
  - sudo apt update
  - sudo apt install -y ruby-full ruby-bundler build-essential
  - echo "install mongo"
  - wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
  - echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
  - sudo apt-get update
  - sudo apt-get install -y mongodb-org
  - sudo systemctl start mongod
  - sudo systemctl enable mongod
  - echo "install reddit"
  - cd ~
  - apt install git
  - git clone -b monolith https://github.com/express42/reddit.git
  - cd reddit && bundle install
  - puma -d
```

Команда создания ВМ (файл yc-create-instance-with-cloud-config.sh):
```
#!/bin/bash
yc compute instance create \
  --name reddit-app2 \
  --hostname reddit-app2 \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --metadata-from-file user-data=cloud-config.yml

```
