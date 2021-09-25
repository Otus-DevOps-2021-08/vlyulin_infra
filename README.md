<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4" />

# vlyulin Infra repository

# Content:
* [Student](#Student)
* [Module hw03-bastion](#Module-hw03-bastion)
* [Module hw04-cloud-testapp](#Module-hw04-cloud-testapp)
* [Module hw05-packer](#Module-hw05-packer)

# Student
`
Student: Vadim Lyulin
Course: DevOps
Group: Otus-DevOps-2021-08
`

## Module hw03-bastion<a name="Module-hw03-bastion"></a>
### Самостоятельное задание
Исследовать способ подключения к someinternalhost в одну команду из вашего рабочего устройства,
проверить работоспособность найденного решения и внести его в README.md в вашем репозитории.

#### Решение
Использовать ключ -J (ssh jump host) для перепрыгивания через hosts.
Команда:
```
ssh -i ~/.ssh/vlyulin_key -J appuser@130.193.38.153 appuser@10.128.0.30
```

### Дополнительное задание:
Предложить вариант решения для подключения из консоли при помощикоманды вида ssh someinternalhost из локальной консоли рабочегоустройства,
чтобы подключение выполнялось по алиасуsomeinternalhost и внести его в README.md в вашем репозитории.

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

Передать файлы в git как выполняемые (+x):
```
git update-index --chmod=+x
```

## Module hw05-packer: Подготовка образов с помощью packer <a name="Module-hw05-packer"></a>

Выполненные работы

1. Создана ветка packer-base
2. Наработки с предыдущего ДЗ перенесены в директорию config-scripts
3. Установлена и проверена установка программы parcker
4. Создан сервисный аккаунт.
   Для этого:

    4.1 Получен folder-id - ID каталога в Yandex.Cloud:
    ```
    yc config list
    ```

    4.2 Создан сервисный аккаунт (скрипт create_service_account.sh)
    ```
    #!/bin/bash
    SVC_ACCT=vl71
    FOLDER_ID=b1g97nk43unle0o4u325
    yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID
    ```

    4.3 Созданному сервисному аккаунту vl71 даны права editor (скрипт grant_rights.sh)
    ```
    #!/bin/bash
    SVC_ACCT=vl71
    FOLDER_ID=b1g97nk43unle0o4u325
    ACCT_ID=$(yc iam service-account get $SVC_ACCT |  grep ^id | awk '{print $2}')
    yc resource-manager folder add-access-binding --id $FOLDER_ID --role editor --service-account-id $ACCT_ID
    ```

5. Создан IAM ключ
```
yc iam key create --service-account-id $ACCT_ID --output /home/appuser/key.json
```

6. Создана директория packer. В директории parker создан Parker шаблон ubuntu16.json, содержащий описание образа VM.

>**_Note_**: Документация https://cloud.yandex.com/en-ru/docs/solutions/infrastructure-management/packer-quickstart

```
{
    "builders": [
        {
            "type": "yandex",
            "service_account_key_file": "../../key.json",
            "folder_id": "b1g97nk43unle0o4u325",
            "zone":      "ru-central1-a",
            "source_image_family": "ubuntu-1604-lts",
            "subnet_id":           "e9be9todt50r72c98ftm",
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "reddit-base",
            "ssh_username": "ubuntu",
            "use_ipv4_nat": "true",
            "platform_id": "standard-v1"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}
```
При этом в последствии была решена проблема:
```
==> yandex: Error creating network: server-request-id = 27eebca8-706f-4212-b2a1-a7948ac8f242 server-trace-id = e5114d186ea652c1:e5196846675842d1:e5114d186ea65
2c1:1 client-request-id = e1f3eb34-35cb-46f1-a0a7-daef57aa620d client-trace-id = c5146722-e94d-41f0-bfa9-b7b6902ea975 rpc error: code = ResourceExhausted desc
 = Quota limit vpc.networks.count exceeded
Build 'yandex' errored after 2 seconds 240 milliseconds: Error creating network: server-request-id = 27eebca8-706f-4212-b2a1-a7948ac8f242 server-trace-id = e5
114d186ea652c1:e5196846675842d1:e5114d186ea652c1:1 client-request-id = e1f3eb34-35cb-46f1-a0a7-daef57aa620d client-trace-id = c5146722-e94d-41f0-bfa9-b7b6902e
a975 rpc error: code = ResourceExhausted desc = Quota limit vpc.networks.count exceeded
```

<b>Решение:</b>
В template в секцию builders добавлены:
```
    zone": "ru-central1-a",
    "subnet_id": "e9be9todt50r72c98ftm",
    "use_ipv4_nat": "true",
```

>**_NOTE_:** Сделано на основе: https://cloud.yandex.com/en-ru/docs/solutions/infrastructure-management/packer-quickstart

7. В директорию scripts были скопированы скрипты install_ruby.sh и install_mongodb.sh из предыдущего ДЗ.

8. Выполнена проперка шаблона командой
```
packer validate ./ubuntu16.json
```
9. Выполнена сборка образа reddit-base
```
packer build ./ubuntu16.json
```

10. Создана ВМ (скрипт yc-create-instance.sh)
```
#!/bin/bash
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=b1g97nk43unle0o4u325,image-family=reddit-base,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --ssh-key ~/.ssh/appuser.pub
```

11. Внешний IP адрес созданной ВМ сделан статическим
>**_NOTE_:** документация https://cloud.yandex.com/en-ru/docs/vpc/operations/set-static-ip
```
yc vpc address list
```
Вывод:
```
+----------------------+------+---------------+----------+------+
|          ID          | NAME |    ADDRESS    | RESERVED | USED |
+----------------------+------+---------------+----------+------+
| e9bqjk6mvujdfci9i68l |      | 62.84.117.216 | true     | true |
+----------------------+------+---------------+----------+------+
```
Установить как статический:
```
yc vpc address update --reserved=true e9bqjk6mvujdfci9i68l
```
Вывод:
```
id: e9bqjk6mvujdfci9i68l
folder_id: b1g97nk43unle0o4u325
created_at: "2021-09-25T07:41:43Z"
external_ipv4_address:
  address: 62.84.117.216
  zone_id: ru-central1-a
  requirements: {}
reserved: true
used: true
type: EXTERNAL
ip_version: IPV4
```

12. Установлен reddit
```
ssh -i ~/.ssh/appuser appuser@62.84.117.216
sudo apt-get update
sudo apt-get install -y
gitgit clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
```

13. Проверена работоспособность reddit: http://62.84.117.216:9292

### Параметризирование шаблона

14. Созданы файлы с переменными variables.json и variables.json.example

15. На базе ubuntu16.json создаем immutable.json
```
{
    "builders": [
        {
            "type": "yandex",
            "service_account_key_file": "{{user `key`}}",
            "folder_id": "{{user `folder_id`}}",
            "zone":      "{{user `zone`}}",
            "source_image_family": "{{user `source_image_family`}}",
            "subnet_id":           "{{user `subnet_id`}}",
            "image_name": "{{user `image_family`}}-{{timestamp}}",
            "image_family": "{{user `image_family`}}",
            "ssh_username": "{{user `ssh_username`}}",
            "use_ipv4_nat": "true",
            "platform_id": "standard-v1"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "file",
            "source": "files/puma.service",
            "destination": "/tmp/puma.service"
        },
        {
            "type": "shell",
            "inline": [
                "sudo mv /tmp/puma.service /etc/systemd/system/puma.service",

                "cd /opt",
                "sudo apt-get install -y git",
                "sudo chmod -R 0777 /opt",
                "git clone -b monolith https://github.com/express42/reddit.git",
                "cd reddit && bundle install",
                "sudo systemctl daemon-reload && sudo systemctl start puma && sudo systemctl enable puma"
            ]
        }
    ]
}
```
где в качестве базового image указан ранее созданный image reddit-base.
Для установки reddit создан скрипт scripts/install_reddit.sh

16. На основе ресурса https://github.com/puma/puma/blob/master/docs/systemd.md в директории files создан файл puma.service

17. Файл puma.service включается в образ с помощью provisioner https://www.packer.io/docs/provisioners/file
Далее уже с помощью provisioner shell при создании image устанавливается из директории /tmp в нужную директорию /etc/systemd/system/

18. Проверка и создание образа reddit-full
```
packer validate -var-file=./variables.json ./immutable.json
packer build -var-file=./variables.json ./immutable.json
```

19. Создан скрипт create-reddit-vm.sh  в  директории config-scripts для создания ВМ из образа reddit-full
```
yc compute instance create --name reddit-full --hostname reddit-full --memory=4 --create-boot-disk image-folder-id=b1g97nk43unle0o4u325,image-family=reddit-full,size=10GB --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 --metadata serial-port-enable=1 --ssh-key C:\Users\vlulin\.ssh\appuser.pub
```
20. Внешний IP адрес созданной ВМ сделан статическим
```
yc vpc address list
yc vpc address update --reserved=true ...
```
21. Проверена работа приложения в ВМ созданного из образа reddit-full: http://62.84.116.36:9292/
